
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
  800044:	e8 6f 00 00 00       	call   8000b8 <sys_cputs>
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
  800131:	68 6a 10 80 00       	push   $0x80106a
  800136:	6a 23                	push   $0x23
  800138:	68 87 10 80 00       	push   $0x801087
  80013d:	e8 57 02 00 00       	call   800399 <_panic>

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
  8001be:	68 6a 10 80 00       	push   $0x80106a
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 87 10 80 00       	push   $0x801087
  8001ca:	e8 ca 01 00 00       	call   800399 <_panic>

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
  800204:	68 6a 10 80 00       	push   $0x80106a
  800209:	6a 23                	push   $0x23
  80020b:	68 87 10 80 00       	push   $0x801087
  800210:	e8 84 01 00 00       	call   800399 <_panic>

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
  80024a:	68 6a 10 80 00       	push   $0x80106a
  80024f:	6a 23                	push   $0x23
  800251:	68 87 10 80 00       	push   $0x801087
  800256:	e8 3e 01 00 00       	call   800399 <_panic>

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
  800290:	68 6a 10 80 00       	push   $0x80106a
  800295:	6a 23                	push   $0x23
  800297:	68 87 10 80 00       	push   $0x801087
  80029c:	e8 f8 00 00 00       	call   800399 <_panic>

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
  8002d6:	68 6a 10 80 00       	push   $0x80106a
  8002db:	6a 23                	push   $0x23
  8002dd:	68 87 10 80 00       	push   $0x801087
  8002e2:	e8 b2 00 00 00       	call   800399 <_panic>

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
  80031c:	68 6a 10 80 00       	push   $0x80106a
  800321:	6a 23                	push   $0x23
  800323:	68 87 10 80 00       	push   $0x801087
  800328:	e8 6c 00 00 00       	call   800399 <_panic>

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
  80035e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800361:	b9 00 00 00 00       	mov    $0x0,%ecx
  800366:	8b 55 08             	mov    0x8(%ebp),%edx
  800369:	b8 0d 00 00 00       	mov    $0xd,%eax
  80036e:	89 cb                	mov    %ecx,%ebx
  800370:	89 cf                	mov    %ecx,%edi
  800372:	89 ce                	mov    %ecx,%esi
  800374:	cd 30                	int    $0x30
	if(check && ret > 0)
  800376:	85 c0                	test   %eax,%eax
  800378:	7f 08                	jg     800382 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037d:	5b                   	pop    %ebx
  80037e:	5e                   	pop    %esi
  80037f:	5f                   	pop    %edi
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	50                   	push   %eax
  800386:	6a 0d                	push   $0xd
  800388:	68 6a 10 80 00       	push   $0x80106a
  80038d:	6a 23                	push   $0x23
  80038f:	68 87 10 80 00       	push   $0x801087
  800394:	e8 00 00 00 00       	call   800399 <_panic>

00800399 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800399:	f3 0f 1e fb          	endbr32 
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	56                   	push   %esi
  8003a1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003a2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003ab:	e8 92 fd ff ff       	call   800142 <sys_getenvid>
  8003b0:	83 ec 0c             	sub    $0xc,%esp
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	56                   	push   %esi
  8003ba:	50                   	push   %eax
  8003bb:	68 98 10 80 00       	push   $0x801098
  8003c0:	e8 bb 00 00 00       	call   800480 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c5:	83 c4 18             	add    $0x18,%esp
  8003c8:	53                   	push   %ebx
  8003c9:	ff 75 10             	pushl  0x10(%ebp)
  8003cc:	e8 5a 00 00 00       	call   80042b <vcprintf>
	cprintf("\n");
  8003d1:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  8003d8:	e8 a3 00 00 00       	call   800480 <cprintf>
  8003dd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e0:	cc                   	int3   
  8003e1:	eb fd                	jmp    8003e0 <_panic+0x47>

008003e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e3:	f3 0f 1e fb          	endbr32 
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	53                   	push   %ebx
  8003eb:	83 ec 04             	sub    $0x4,%esp
  8003ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f1:	8b 13                	mov    (%ebx),%edx
  8003f3:	8d 42 01             	lea    0x1(%edx),%eax
  8003f6:	89 03                	mov    %eax,(%ebx)
  8003f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800404:	74 09                	je     80040f <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800406:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80040a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80040d:	c9                   	leave  
  80040e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	68 ff 00 00 00       	push   $0xff
  800417:	8d 43 08             	lea    0x8(%ebx),%eax
  80041a:	50                   	push   %eax
  80041b:	e8 98 fc ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800420:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	eb db                	jmp    800406 <putch+0x23>

0080042b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042b:	f3 0f 1e fb          	endbr32 
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800438:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043f:	00 00 00 
	b.cnt = 0;
  800442:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800449:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044c:	ff 75 0c             	pushl  0xc(%ebp)
  80044f:	ff 75 08             	pushl  0x8(%ebp)
  800452:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800458:	50                   	push   %eax
  800459:	68 e3 03 80 00       	push   $0x8003e3
  80045e:	e8 20 01 00 00       	call   800583 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800463:	83 c4 08             	add    $0x8,%esp
  800466:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80046c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800472:	50                   	push   %eax
  800473:	e8 40 fc ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800478:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800480:	f3 0f 1e fb          	endbr32 
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048d:	50                   	push   %eax
  80048e:	ff 75 08             	pushl  0x8(%ebp)
  800491:	e8 95 ff ff ff       	call   80042b <vcprintf>
	va_end(ap);

	return cnt;
}
  800496:	c9                   	leave  
  800497:	c3                   	ret    

00800498 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	57                   	push   %edi
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 1c             	sub    $0x1c,%esp
  8004a1:	89 c7                	mov    %eax,%edi
  8004a3:	89 d6                	mov    %edx,%esi
  8004a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ab:	89 d1                	mov    %edx,%ecx
  8004ad:	89 c2                	mov    %eax,%edx
  8004af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004c5:	39 c2                	cmp    %eax,%edx
  8004c7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004ca:	72 3e                	jb     80050a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004cc:	83 ec 0c             	sub    $0xc,%esp
  8004cf:	ff 75 18             	pushl  0x18(%ebp)
  8004d2:	83 eb 01             	sub    $0x1,%ebx
  8004d5:	53                   	push   %ebx
  8004d6:	50                   	push   %eax
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e6:	e8 15 09 00 00       	call   800e00 <__udivdi3>
  8004eb:	83 c4 18             	add    $0x18,%esp
  8004ee:	52                   	push   %edx
  8004ef:	50                   	push   %eax
  8004f0:	89 f2                	mov    %esi,%edx
  8004f2:	89 f8                	mov    %edi,%eax
  8004f4:	e8 9f ff ff ff       	call   800498 <printnum>
  8004f9:	83 c4 20             	add    $0x20,%esp
  8004fc:	eb 13                	jmp    800511 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	56                   	push   %esi
  800502:	ff 75 18             	pushl  0x18(%ebp)
  800505:	ff d7                	call   *%edi
  800507:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80050a:	83 eb 01             	sub    $0x1,%ebx
  80050d:	85 db                	test   %ebx,%ebx
  80050f:	7f ed                	jg     8004fe <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	56                   	push   %esi
  800515:	83 ec 04             	sub    $0x4,%esp
  800518:	ff 75 e4             	pushl  -0x1c(%ebp)
  80051b:	ff 75 e0             	pushl  -0x20(%ebp)
  80051e:	ff 75 dc             	pushl  -0x24(%ebp)
  800521:	ff 75 d8             	pushl  -0x28(%ebp)
  800524:	e8 e7 09 00 00       	call   800f10 <__umoddi3>
  800529:	83 c4 14             	add    $0x14,%esp
  80052c:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  800533:	50                   	push   %eax
  800534:	ff d7                	call   *%edi
}
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80053c:	5b                   	pop    %ebx
  80053d:	5e                   	pop    %esi
  80053e:	5f                   	pop    %edi
  80053f:	5d                   	pop    %ebp
  800540:	c3                   	ret    

00800541 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800541:	f3 0f 1e fb          	endbr32 
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80054f:	8b 10                	mov    (%eax),%edx
  800551:	3b 50 04             	cmp    0x4(%eax),%edx
  800554:	73 0a                	jae    800560 <sprintputch+0x1f>
		*b->buf++ = ch;
  800556:	8d 4a 01             	lea    0x1(%edx),%ecx
  800559:	89 08                	mov    %ecx,(%eax)
  80055b:	8b 45 08             	mov    0x8(%ebp),%eax
  80055e:	88 02                	mov    %al,(%edx)
}
  800560:	5d                   	pop    %ebp
  800561:	c3                   	ret    

00800562 <printfmt>:
{
  800562:	f3 0f 1e fb          	endbr32 
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80056c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056f:	50                   	push   %eax
  800570:	ff 75 10             	pushl  0x10(%ebp)
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	ff 75 08             	pushl  0x8(%ebp)
  800579:	e8 05 00 00 00       	call   800583 <vprintfmt>
}
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	c9                   	leave  
  800582:	c3                   	ret    

00800583 <vprintfmt>:
{
  800583:	f3 0f 1e fb          	endbr32 
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  80058a:	57                   	push   %edi
  80058b:	56                   	push   %esi
  80058c:	53                   	push   %ebx
  80058d:	83 ec 3c             	sub    $0x3c,%esp
  800590:	8b 75 08             	mov    0x8(%ebp),%esi
  800593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800596:	8b 7d 10             	mov    0x10(%ebp),%edi
  800599:	e9 4a 03 00 00       	jmp    8008e8 <vprintfmt+0x365>
		padc = ' ';
  80059e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005a2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005a9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005b0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005b7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8d 47 01             	lea    0x1(%edi),%eax
  8005bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c2:	0f b6 17             	movzbl (%edi),%edx
  8005c5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005c8:	3c 55                	cmp    $0x55,%al
  8005ca:	0f 87 de 03 00 00    	ja     8009ae <vprintfmt+0x42b>
  8005d0:	0f b6 c0             	movzbl %al,%eax
  8005d3:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005da:	00 
  8005db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005de:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005e2:	eb d8                	jmp    8005bc <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005eb:	eb cf                	jmp    8005bc <vprintfmt+0x39>
  8005ed:	0f b6 d2             	movzbl %dl,%edx
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005fe:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800602:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800605:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800608:	83 f9 09             	cmp    $0x9,%ecx
  80060b:	77 55                	ja     800662 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80060d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800610:	eb e9                	jmp    8005fb <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 40 04             	lea    0x4(%eax),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800626:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80062a:	79 90                	jns    8005bc <vprintfmt+0x39>
				width = precision, precision = -1;
  80062c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800632:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800639:	eb 81                	jmp    8005bc <vprintfmt+0x39>
  80063b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063e:	85 c0                	test   %eax,%eax
  800640:	ba 00 00 00 00       	mov    $0x0,%edx
  800645:	0f 49 d0             	cmovns %eax,%edx
  800648:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80064e:	e9 69 ff ff ff       	jmp    8005bc <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800656:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80065d:	e9 5a ff ff ff       	jmp    8005bc <vprintfmt+0x39>
  800662:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800665:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800668:	eb bc                	jmp    800626 <vprintfmt+0xa3>
			lflag++;
  80066a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800670:	e9 47 ff ff ff       	jmp    8005bc <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 78 04             	lea    0x4(%eax),%edi
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	ff 30                	pushl  (%eax)
  800681:	ff d6                	call   *%esi
			break;
  800683:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800686:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800689:	e9 57 02 00 00       	jmp    8008e5 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 78 04             	lea    0x4(%eax),%edi
  800694:	8b 00                	mov    (%eax),%eax
  800696:	99                   	cltd   
  800697:	31 d0                	xor    %edx,%eax
  800699:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80069b:	83 f8 0f             	cmp    $0xf,%eax
  80069e:	7f 23                	jg     8006c3 <vprintfmt+0x140>
  8006a0:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  8006a7:	85 d2                	test   %edx,%edx
  8006a9:	74 18                	je     8006c3 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8006ab:	52                   	push   %edx
  8006ac:	68 de 10 80 00       	push   $0x8010de
  8006b1:	53                   	push   %ebx
  8006b2:	56                   	push   %esi
  8006b3:	e8 aa fe ff ff       	call   800562 <printfmt>
  8006b8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006bb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006be:	e9 22 02 00 00       	jmp    8008e5 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006c3:	50                   	push   %eax
  8006c4:	68 d5 10 80 00       	push   $0x8010d5
  8006c9:	53                   	push   %ebx
  8006ca:	56                   	push   %esi
  8006cb:	e8 92 fe ff ff       	call   800562 <printfmt>
  8006d0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006d3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006d6:	e9 0a 02 00 00       	jmp    8008e5 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	83 c0 04             	add    $0x4,%eax
  8006e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006f0:	0f 45 c2             	cmovne %edx,%eax
  8006f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006fa:	7e 06                	jle    800702 <vprintfmt+0x17f>
  8006fc:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800700:	75 0d                	jne    80070f <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800702:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800705:	89 c7                	mov    %eax,%edi
  800707:	03 45 e0             	add    -0x20(%ebp),%eax
  80070a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070d:	eb 55                	jmp    800764 <vprintfmt+0x1e1>
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	ff 75 d8             	pushl  -0x28(%ebp)
  800715:	ff 75 cc             	pushl  -0x34(%ebp)
  800718:	e8 45 03 00 00       	call   800a62 <strnlen>
  80071d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800720:	29 c2                	sub    %eax,%edx
  800722:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80072a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80072e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800731:	85 ff                	test   %edi,%edi
  800733:	7e 11                	jle    800746 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	53                   	push   %ebx
  800739:	ff 75 e0             	pushl  -0x20(%ebp)
  80073c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80073e:	83 ef 01             	sub    $0x1,%edi
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	eb eb                	jmp    800731 <vprintfmt+0x1ae>
  800746:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800749:	85 d2                	test   %edx,%edx
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	0f 49 c2             	cmovns %edx,%eax
  800753:	29 c2                	sub    %eax,%edx
  800755:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800758:	eb a8                	jmp    800702 <vprintfmt+0x17f>
					putch(ch, putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	52                   	push   %edx
  80075f:	ff d6                	call   *%esi
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800767:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800769:	83 c7 01             	add    $0x1,%edi
  80076c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800770:	0f be d0             	movsbl %al,%edx
  800773:	85 d2                	test   %edx,%edx
  800775:	74 4b                	je     8007c2 <vprintfmt+0x23f>
  800777:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80077b:	78 06                	js     800783 <vprintfmt+0x200>
  80077d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800781:	78 1e                	js     8007a1 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800783:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800787:	74 d1                	je     80075a <vprintfmt+0x1d7>
  800789:	0f be c0             	movsbl %al,%eax
  80078c:	83 e8 20             	sub    $0x20,%eax
  80078f:	83 f8 5e             	cmp    $0x5e,%eax
  800792:	76 c6                	jbe    80075a <vprintfmt+0x1d7>
					putch('?', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 3f                	push   $0x3f
  80079a:	ff d6                	call   *%esi
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	eb c3                	jmp    800764 <vprintfmt+0x1e1>
  8007a1:	89 cf                	mov    %ecx,%edi
  8007a3:	eb 0e                	jmp    8007b3 <vprintfmt+0x230>
				putch(' ', putdat);
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	53                   	push   %ebx
  8007a9:	6a 20                	push   $0x20
  8007ab:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007ad:	83 ef 01             	sub    $0x1,%edi
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	85 ff                	test   %edi,%edi
  8007b5:	7f ee                	jg     8007a5 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007b7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bd:	e9 23 01 00 00       	jmp    8008e5 <vprintfmt+0x362>
  8007c2:	89 cf                	mov    %ecx,%edi
  8007c4:	eb ed                	jmp    8007b3 <vprintfmt+0x230>
	if (lflag >= 2)
  8007c6:	83 f9 01             	cmp    $0x1,%ecx
  8007c9:	7f 1b                	jg     8007e6 <vprintfmt+0x263>
	else if (lflag)
  8007cb:	85 c9                	test   %ecx,%ecx
  8007cd:	74 63                	je     800832 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d7:	99                   	cltd   
  8007d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 40 04             	lea    0x4(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e4:	eb 17                	jmp    8007fd <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 50 04             	mov    0x4(%eax),%edx
  8007ec:	8b 00                	mov    (%eax),%eax
  8007ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8d 40 08             	lea    0x8(%eax),%eax
  8007fa:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800800:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800803:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800808:	85 c9                	test   %ecx,%ecx
  80080a:	0f 89 bb 00 00 00    	jns    8008cb <vprintfmt+0x348>
				putch('-', putdat);
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	53                   	push   %ebx
  800814:	6a 2d                	push   $0x2d
  800816:	ff d6                	call   *%esi
				num = -(long long) num;
  800818:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80081b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80081e:	f7 da                	neg    %edx
  800820:	83 d1 00             	adc    $0x0,%ecx
  800823:	f7 d9                	neg    %ecx
  800825:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800828:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082d:	e9 99 00 00 00       	jmp    8008cb <vprintfmt+0x348>
		return va_arg(*ap, int);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8b 00                	mov    (%eax),%eax
  800837:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083a:	99                   	cltd   
  80083b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8d 40 04             	lea    0x4(%eax),%eax
  800844:	89 45 14             	mov    %eax,0x14(%ebp)
  800847:	eb b4                	jmp    8007fd <vprintfmt+0x27a>
	if (lflag >= 2)
  800849:	83 f9 01             	cmp    $0x1,%ecx
  80084c:	7f 1b                	jg     800869 <vprintfmt+0x2e6>
	else if (lflag)
  80084e:	85 c9                	test   %ecx,%ecx
  800850:	74 2c                	je     80087e <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	8b 10                	mov    (%eax),%edx
  800857:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085c:	8d 40 04             	lea    0x4(%eax),%eax
  80085f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800862:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800867:	eb 62                	jmp    8008cb <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8b 10                	mov    (%eax),%edx
  80086e:	8b 48 04             	mov    0x4(%eax),%ecx
  800871:	8d 40 08             	lea    0x8(%eax),%eax
  800874:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800877:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80087c:	eb 4d                	jmp    8008cb <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8b 10                	mov    (%eax),%edx
  800883:	b9 00 00 00 00       	mov    $0x0,%ecx
  800888:	8d 40 04             	lea    0x4(%eax),%eax
  80088b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80088e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800893:	eb 36                	jmp    8008cb <vprintfmt+0x348>
	if (lflag >= 2)
  800895:	83 f9 01             	cmp    $0x1,%ecx
  800898:	7f 17                	jg     8008b1 <vprintfmt+0x32e>
	else if (lflag)
  80089a:	85 c9                	test   %ecx,%ecx
  80089c:	74 6e                	je     80090c <vprintfmt+0x389>
		return va_arg(*ap, long);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8b 10                	mov    (%eax),%edx
  8008a3:	89 d0                	mov    %edx,%eax
  8008a5:	99                   	cltd   
  8008a6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008a9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008ac:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008af:	eb 11                	jmp    8008c2 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b4:	8b 50 04             	mov    0x4(%eax),%edx
  8008b7:	8b 00                	mov    (%eax),%eax
  8008b9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008bc:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008bf:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008c2:	89 d1                	mov    %edx,%ecx
  8008c4:	89 c2                	mov    %eax,%edx
            base = 8;
  8008c6:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008cb:	83 ec 0c             	sub    $0xc,%esp
  8008ce:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008d2:	57                   	push   %edi
  8008d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d6:	50                   	push   %eax
  8008d7:	51                   	push   %ecx
  8008d8:	52                   	push   %edx
  8008d9:	89 da                	mov    %ebx,%edx
  8008db:	89 f0                	mov    %esi,%eax
  8008dd:	e8 b6 fb ff ff       	call   800498 <printnum>
			break;
  8008e2:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e8:	83 c7 01             	add    $0x1,%edi
  8008eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ef:	83 f8 25             	cmp    $0x25,%eax
  8008f2:	0f 84 a6 fc ff ff    	je     80059e <vprintfmt+0x1b>
			if (ch == '\0')
  8008f8:	85 c0                	test   %eax,%eax
  8008fa:	0f 84 ce 00 00 00    	je     8009ce <vprintfmt+0x44b>
			putch(ch, putdat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	53                   	push   %ebx
  800904:	50                   	push   %eax
  800905:	ff d6                	call   *%esi
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	eb dc                	jmp    8008e8 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8b 10                	mov    (%eax),%edx
  800911:	89 d0                	mov    %edx,%eax
  800913:	99                   	cltd   
  800914:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800917:	8d 49 04             	lea    0x4(%ecx),%ecx
  80091a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80091d:	eb a3                	jmp    8008c2 <vprintfmt+0x33f>
			putch('0', putdat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	53                   	push   %ebx
  800923:	6a 30                	push   $0x30
  800925:	ff d6                	call   *%esi
			putch('x', putdat);
  800927:	83 c4 08             	add    $0x8,%esp
  80092a:	53                   	push   %ebx
  80092b:	6a 78                	push   $0x78
  80092d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	8b 10                	mov    (%eax),%edx
  800934:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800939:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80093c:	8d 40 04             	lea    0x4(%eax),%eax
  80093f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800942:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800947:	eb 82                	jmp    8008cb <vprintfmt+0x348>
	if (lflag >= 2)
  800949:	83 f9 01             	cmp    $0x1,%ecx
  80094c:	7f 1e                	jg     80096c <vprintfmt+0x3e9>
	else if (lflag)
  80094e:	85 c9                	test   %ecx,%ecx
  800950:	74 32                	je     800984 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800952:	8b 45 14             	mov    0x14(%ebp),%eax
  800955:	8b 10                	mov    (%eax),%edx
  800957:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095c:	8d 40 04             	lea    0x4(%eax),%eax
  80095f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800962:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800967:	e9 5f ff ff ff       	jmp    8008cb <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80096c:	8b 45 14             	mov    0x14(%ebp),%eax
  80096f:	8b 10                	mov    (%eax),%edx
  800971:	8b 48 04             	mov    0x4(%eax),%ecx
  800974:	8d 40 08             	lea    0x8(%eax),%eax
  800977:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80097a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80097f:	e9 47 ff ff ff       	jmp    8008cb <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800984:	8b 45 14             	mov    0x14(%ebp),%eax
  800987:	8b 10                	mov    (%eax),%edx
  800989:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098e:	8d 40 04             	lea    0x4(%eax),%eax
  800991:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800994:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800999:	e9 2d ff ff ff       	jmp    8008cb <vprintfmt+0x348>
			putch(ch, putdat);
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	53                   	push   %ebx
  8009a2:	6a 25                	push   $0x25
  8009a4:	ff d6                	call   *%esi
			break;
  8009a6:	83 c4 10             	add    $0x10,%esp
  8009a9:	e9 37 ff ff ff       	jmp    8008e5 <vprintfmt+0x362>
			putch('%', putdat);
  8009ae:	83 ec 08             	sub    $0x8,%esp
  8009b1:	53                   	push   %ebx
  8009b2:	6a 25                	push   $0x25
  8009b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b6:	83 c4 10             	add    $0x10,%esp
  8009b9:	89 f8                	mov    %edi,%eax
  8009bb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009bf:	74 05                	je     8009c6 <vprintfmt+0x443>
  8009c1:	83 e8 01             	sub    $0x1,%eax
  8009c4:	eb f5                	jmp    8009bb <vprintfmt+0x438>
  8009c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009c9:	e9 17 ff ff ff       	jmp    8008e5 <vprintfmt+0x362>
}
  8009ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d6:	f3 0f 1e fb          	endbr32 
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 18             	sub    $0x18,%esp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	74 26                	je     800a21 <vsnprintf+0x4b>
  8009fb:	85 d2                	test   %edx,%edx
  8009fd:	7e 22                	jle    800a21 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ff:	ff 75 14             	pushl  0x14(%ebp)
  800a02:	ff 75 10             	pushl  0x10(%ebp)
  800a05:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a08:	50                   	push   %eax
  800a09:	68 41 05 80 00       	push   $0x800541
  800a0e:	e8 70 fb ff ff       	call   800583 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a16:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a1c:	83 c4 10             	add    $0x10,%esp
}
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    
		return -E_INVAL;
  800a21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a26:	eb f7                	jmp    800a1f <vsnprintf+0x49>

00800a28 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a28:	f3 0f 1e fb          	endbr32 
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a32:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a35:	50                   	push   %eax
  800a36:	ff 75 10             	pushl  0x10(%ebp)
  800a39:	ff 75 0c             	pushl  0xc(%ebp)
  800a3c:	ff 75 08             	pushl  0x8(%ebp)
  800a3f:	e8 92 ff ff ff       	call   8009d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a46:	f3 0f 1e fb          	endbr32 
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a59:	74 05                	je     800a60 <strlen+0x1a>
		n++;
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	eb f5                	jmp    800a55 <strlen+0xf>
	return n;
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a62:	f3 0f 1e fb          	endbr32 
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	74 0d                	je     800a85 <strnlen+0x23>
  800a78:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a7c:	74 05                	je     800a83 <strnlen+0x21>
		n++;
  800a7e:	83 c0 01             	add    $0x1,%eax
  800a81:	eb f1                	jmp    800a74 <strnlen+0x12>
  800a83:	89 c2                	mov    %eax,%edx
	return n;
}
  800a85:	89 d0                	mov    %edx,%eax
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a89:	f3 0f 1e fb          	endbr32 
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	53                   	push   %ebx
  800a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800aa0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800aa3:	83 c0 01             	add    $0x1,%eax
  800aa6:	84 d2                	test   %dl,%dl
  800aa8:	75 f2                	jne    800a9c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800aaa:	89 c8                	mov    %ecx,%eax
  800aac:	5b                   	pop    %ebx
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aaf:	f3 0f 1e fb          	endbr32 
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 10             	sub    $0x10,%esp
  800aba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800abd:	53                   	push   %ebx
  800abe:	e8 83 ff ff ff       	call   800a46 <strlen>
  800ac3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ac6:	ff 75 0c             	pushl  0xc(%ebp)
  800ac9:	01 d8                	add    %ebx,%eax
  800acb:	50                   	push   %eax
  800acc:	e8 b8 ff ff ff       	call   800a89 <strcpy>
	return dst;
}
  800ad1:	89 d8                	mov    %ebx,%eax
  800ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ad8:	f3 0f 1e fb          	endbr32 
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aec:	89 f0                	mov    %esi,%eax
  800aee:	39 d8                	cmp    %ebx,%eax
  800af0:	74 11                	je     800b03 <strncpy+0x2b>
		*dst++ = *src;
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	0f b6 0a             	movzbl (%edx),%ecx
  800af8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800afb:	80 f9 01             	cmp    $0x1,%cl
  800afe:	83 da ff             	sbb    $0xffffffff,%edx
  800b01:	eb eb                	jmp    800aee <strncpy+0x16>
	}
	return ret;
}
  800b03:	89 f0                	mov    %esi,%eax
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b09:	f3 0f 1e fb          	endbr32 
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 75 08             	mov    0x8(%ebp),%esi
  800b15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b18:	8b 55 10             	mov    0x10(%ebp),%edx
  800b1b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b1d:	85 d2                	test   %edx,%edx
  800b1f:	74 21                	je     800b42 <strlcpy+0x39>
  800b21:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b25:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b27:	39 c2                	cmp    %eax,%edx
  800b29:	74 14                	je     800b3f <strlcpy+0x36>
  800b2b:	0f b6 19             	movzbl (%ecx),%ebx
  800b2e:	84 db                	test   %bl,%bl
  800b30:	74 0b                	je     800b3d <strlcpy+0x34>
			*dst++ = *src++;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	83 c2 01             	add    $0x1,%edx
  800b38:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b3b:	eb ea                	jmp    800b27 <strlcpy+0x1e>
  800b3d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b3f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b42:	29 f0                	sub    %esi,%eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b48:	f3 0f 1e fb          	endbr32 
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b55:	0f b6 01             	movzbl (%ecx),%eax
  800b58:	84 c0                	test   %al,%al
  800b5a:	74 0c                	je     800b68 <strcmp+0x20>
  800b5c:	3a 02                	cmp    (%edx),%al
  800b5e:	75 08                	jne    800b68 <strcmp+0x20>
		p++, q++;
  800b60:	83 c1 01             	add    $0x1,%ecx
  800b63:	83 c2 01             	add    $0x1,%edx
  800b66:	eb ed                	jmp    800b55 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b68:	0f b6 c0             	movzbl %al,%eax
  800b6b:	0f b6 12             	movzbl (%edx),%edx
  800b6e:	29 d0                	sub    %edx,%eax
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b72:	f3 0f 1e fb          	endbr32 
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	53                   	push   %ebx
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b80:	89 c3                	mov    %eax,%ebx
  800b82:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b85:	eb 06                	jmp    800b8d <strncmp+0x1b>
		n--, p++, q++;
  800b87:	83 c0 01             	add    $0x1,%eax
  800b8a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b8d:	39 d8                	cmp    %ebx,%eax
  800b8f:	74 16                	je     800ba7 <strncmp+0x35>
  800b91:	0f b6 08             	movzbl (%eax),%ecx
  800b94:	84 c9                	test   %cl,%cl
  800b96:	74 04                	je     800b9c <strncmp+0x2a>
  800b98:	3a 0a                	cmp    (%edx),%cl
  800b9a:	74 eb                	je     800b87 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b9c:	0f b6 00             	movzbl (%eax),%eax
  800b9f:	0f b6 12             	movzbl (%edx),%edx
  800ba2:	29 d0                	sub    %edx,%eax
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    
		return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	eb f6                	jmp    800ba4 <strncmp+0x32>

00800bae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bae:	f3 0f 1e fb          	endbr32 
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bbc:	0f b6 10             	movzbl (%eax),%edx
  800bbf:	84 d2                	test   %dl,%dl
  800bc1:	74 09                	je     800bcc <strchr+0x1e>
		if (*s == c)
  800bc3:	38 ca                	cmp    %cl,%dl
  800bc5:	74 0a                	je     800bd1 <strchr+0x23>
	for (; *s; s++)
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	eb f0                	jmp    800bbc <strchr+0xe>
			return (char *) s;
	return 0;
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd3:	f3 0f 1e fb          	endbr32 
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be4:	38 ca                	cmp    %cl,%dl
  800be6:	74 09                	je     800bf1 <strfind+0x1e>
  800be8:	84 d2                	test   %dl,%dl
  800bea:	74 05                	je     800bf1 <strfind+0x1e>
	for (; *s; s++)
  800bec:	83 c0 01             	add    $0x1,%eax
  800bef:	eb f0                	jmp    800be1 <strfind+0xe>
			break;
	return (char *) s;
}
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf3:	f3 0f 1e fb          	endbr32 
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c03:	85 c9                	test   %ecx,%ecx
  800c05:	74 31                	je     800c38 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c07:	89 f8                	mov    %edi,%eax
  800c09:	09 c8                	or     %ecx,%eax
  800c0b:	a8 03                	test   $0x3,%al
  800c0d:	75 23                	jne    800c32 <memset+0x3f>
		c &= 0xFF;
  800c0f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c13:	89 d3                	mov    %edx,%ebx
  800c15:	c1 e3 08             	shl    $0x8,%ebx
  800c18:	89 d0                	mov    %edx,%eax
  800c1a:	c1 e0 18             	shl    $0x18,%eax
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	c1 e6 10             	shl    $0x10,%esi
  800c22:	09 f0                	or     %esi,%eax
  800c24:	09 c2                	or     %eax,%edx
  800c26:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c28:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c2b:	89 d0                	mov    %edx,%eax
  800c2d:	fc                   	cld    
  800c2e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c30:	eb 06                	jmp    800c38 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c35:	fc                   	cld    
  800c36:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c38:	89 f8                	mov    %edi,%eax
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c3f:	f3 0f 1e fb          	endbr32 
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c51:	39 c6                	cmp    %eax,%esi
  800c53:	73 32                	jae    800c87 <memmove+0x48>
  800c55:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c58:	39 c2                	cmp    %eax,%edx
  800c5a:	76 2b                	jbe    800c87 <memmove+0x48>
		s += n;
		d += n;
  800c5c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5f:	89 fe                	mov    %edi,%esi
  800c61:	09 ce                	or     %ecx,%esi
  800c63:	09 d6                	or     %edx,%esi
  800c65:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c6b:	75 0e                	jne    800c7b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c6d:	83 ef 04             	sub    $0x4,%edi
  800c70:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c73:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c76:	fd                   	std    
  800c77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c79:	eb 09                	jmp    800c84 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c7b:	83 ef 01             	sub    $0x1,%edi
  800c7e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c81:	fd                   	std    
  800c82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c84:	fc                   	cld    
  800c85:	eb 1a                	jmp    800ca1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c87:	89 c2                	mov    %eax,%edx
  800c89:	09 ca                	or     %ecx,%edx
  800c8b:	09 f2                	or     %esi,%edx
  800c8d:	f6 c2 03             	test   $0x3,%dl
  800c90:	75 0a                	jne    800c9c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c92:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c95:	89 c7                	mov    %eax,%edi
  800c97:	fc                   	cld    
  800c98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c9a:	eb 05                	jmp    800ca1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	fc                   	cld    
  800c9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800caf:	ff 75 10             	pushl  0x10(%ebp)
  800cb2:	ff 75 0c             	pushl  0xc(%ebp)
  800cb5:	ff 75 08             	pushl  0x8(%ebp)
  800cb8:	e8 82 ff ff ff       	call   800c3f <memmove>
}
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    

00800cbf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cbf:	f3 0f 1e fb          	endbr32 
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cce:	89 c6                	mov    %eax,%esi
  800cd0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd3:	39 f0                	cmp    %esi,%eax
  800cd5:	74 1c                	je     800cf3 <memcmp+0x34>
		if (*s1 != *s2)
  800cd7:	0f b6 08             	movzbl (%eax),%ecx
  800cda:	0f b6 1a             	movzbl (%edx),%ebx
  800cdd:	38 d9                	cmp    %bl,%cl
  800cdf:	75 08                	jne    800ce9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ce1:	83 c0 01             	add    $0x1,%eax
  800ce4:	83 c2 01             	add    $0x1,%edx
  800ce7:	eb ea                	jmp    800cd3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ce9:	0f b6 c1             	movzbl %cl,%eax
  800cec:	0f b6 db             	movzbl %bl,%ebx
  800cef:	29 d8                	sub    %ebx,%eax
  800cf1:	eb 05                	jmp    800cf8 <memcmp+0x39>
	}

	return 0;
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cfc:	f3 0f 1e fb          	endbr32 
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d09:	89 c2                	mov    %eax,%edx
  800d0b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d0e:	39 d0                	cmp    %edx,%eax
  800d10:	73 09                	jae    800d1b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d12:	38 08                	cmp    %cl,(%eax)
  800d14:	74 05                	je     800d1b <memfind+0x1f>
	for (; s < ends; s++)
  800d16:	83 c0 01             	add    $0x1,%eax
  800d19:	eb f3                	jmp    800d0e <memfind+0x12>
			break;
	return (void *) s;
}
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d1d:	f3 0f 1e fb          	endbr32 
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2d:	eb 03                	jmp    800d32 <strtol+0x15>
		s++;
  800d2f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d32:	0f b6 01             	movzbl (%ecx),%eax
  800d35:	3c 20                	cmp    $0x20,%al
  800d37:	74 f6                	je     800d2f <strtol+0x12>
  800d39:	3c 09                	cmp    $0x9,%al
  800d3b:	74 f2                	je     800d2f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d3d:	3c 2b                	cmp    $0x2b,%al
  800d3f:	74 2a                	je     800d6b <strtol+0x4e>
	int neg = 0;
  800d41:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d46:	3c 2d                	cmp    $0x2d,%al
  800d48:	74 2b                	je     800d75 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d50:	75 0f                	jne    800d61 <strtol+0x44>
  800d52:	80 39 30             	cmpb   $0x30,(%ecx)
  800d55:	74 28                	je     800d7f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d57:	85 db                	test   %ebx,%ebx
  800d59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5e:	0f 44 d8             	cmove  %eax,%ebx
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
  800d66:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d69:	eb 46                	jmp    800db1 <strtol+0x94>
		s++;
  800d6b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d73:	eb d5                	jmp    800d4a <strtol+0x2d>
		s++, neg = 1;
  800d75:	83 c1 01             	add    $0x1,%ecx
  800d78:	bf 01 00 00 00       	mov    $0x1,%edi
  800d7d:	eb cb                	jmp    800d4a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d83:	74 0e                	je     800d93 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d85:	85 db                	test   %ebx,%ebx
  800d87:	75 d8                	jne    800d61 <strtol+0x44>
		s++, base = 8;
  800d89:	83 c1 01             	add    $0x1,%ecx
  800d8c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d91:	eb ce                	jmp    800d61 <strtol+0x44>
		s += 2, base = 16;
  800d93:	83 c1 02             	add    $0x2,%ecx
  800d96:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d9b:	eb c4                	jmp    800d61 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d9d:	0f be d2             	movsbl %dl,%edx
  800da0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800da6:	7d 3a                	jge    800de2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800da8:	83 c1 01             	add    $0x1,%ecx
  800dab:	0f af 45 10          	imul   0x10(%ebp),%eax
  800daf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800db1:	0f b6 11             	movzbl (%ecx),%edx
  800db4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db7:	89 f3                	mov    %esi,%ebx
  800db9:	80 fb 09             	cmp    $0x9,%bl
  800dbc:	76 df                	jbe    800d9d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dbe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dc1:	89 f3                	mov    %esi,%ebx
  800dc3:	80 fb 19             	cmp    $0x19,%bl
  800dc6:	77 08                	ja     800dd0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dc8:	0f be d2             	movsbl %dl,%edx
  800dcb:	83 ea 57             	sub    $0x57,%edx
  800dce:	eb d3                	jmp    800da3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dd0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dd3:	89 f3                	mov    %esi,%ebx
  800dd5:	80 fb 19             	cmp    $0x19,%bl
  800dd8:	77 08                	ja     800de2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dda:	0f be d2             	movsbl %dl,%edx
  800ddd:	83 ea 37             	sub    $0x37,%edx
  800de0:	eb c1                	jmp    800da3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800de2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de6:	74 05                	je     800ded <strtol+0xd0>
		*endptr = (char *) s;
  800de8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800deb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ded:	89 c2                	mov    %eax,%edx
  800def:	f7 da                	neg    %edx
  800df1:	85 ff                	test   %edi,%edi
  800df3:	0f 45 c2             	cmovne %edx,%eax
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    
  800dfb:	66 90                	xchg   %ax,%ax
  800dfd:	66 90                	xchg   %ax,%ax
  800dff:	90                   	nop

00800e00 <__udivdi3>:
  800e00:	f3 0f 1e fb          	endbr32 
  800e04:	55                   	push   %ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 1c             	sub    $0x1c,%esp
  800e0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e1b:	85 d2                	test   %edx,%edx
  800e1d:	75 19                	jne    800e38 <__udivdi3+0x38>
  800e1f:	39 f3                	cmp    %esi,%ebx
  800e21:	76 4d                	jbe    800e70 <__udivdi3+0x70>
  800e23:	31 ff                	xor    %edi,%edi
  800e25:	89 e8                	mov    %ebp,%eax
  800e27:	89 f2                	mov    %esi,%edx
  800e29:	f7 f3                	div    %ebx
  800e2b:	89 fa                	mov    %edi,%edx
  800e2d:	83 c4 1c             	add    $0x1c,%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	76 14                	jbe    800e50 <__udivdi3+0x50>
  800e3c:	31 ff                	xor    %edi,%edi
  800e3e:	31 c0                	xor    %eax,%eax
  800e40:	89 fa                	mov    %edi,%edx
  800e42:	83 c4 1c             	add    $0x1c,%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    
  800e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e50:	0f bd fa             	bsr    %edx,%edi
  800e53:	83 f7 1f             	xor    $0x1f,%edi
  800e56:	75 48                	jne    800ea0 <__udivdi3+0xa0>
  800e58:	39 f2                	cmp    %esi,%edx
  800e5a:	72 06                	jb     800e62 <__udivdi3+0x62>
  800e5c:	31 c0                	xor    %eax,%eax
  800e5e:	39 eb                	cmp    %ebp,%ebx
  800e60:	77 de                	ja     800e40 <__udivdi3+0x40>
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  800e67:	eb d7                	jmp    800e40 <__udivdi3+0x40>
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 d9                	mov    %ebx,%ecx
  800e72:	85 db                	test   %ebx,%ebx
  800e74:	75 0b                	jne    800e81 <__udivdi3+0x81>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f3                	div    %ebx
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	31 d2                	xor    %edx,%edx
  800e83:	89 f0                	mov    %esi,%eax
  800e85:	f7 f1                	div    %ecx
  800e87:	89 c6                	mov    %eax,%esi
  800e89:	89 e8                	mov    %ebp,%eax
  800e8b:	89 f7                	mov    %esi,%edi
  800e8d:	f7 f1                	div    %ecx
  800e8f:	89 fa                	mov    %edi,%edx
  800e91:	83 c4 1c             	add    $0x1c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 f9                	mov    %edi,%ecx
  800ea2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea7:	29 f8                	sub    %edi,%eax
  800ea9:	d3 e2                	shl    %cl,%edx
  800eab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	89 da                	mov    %ebx,%edx
  800eb3:	d3 ea                	shr    %cl,%edx
  800eb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800eb9:	09 d1                	or     %edx,%ecx
  800ebb:	89 f2                	mov    %esi,%edx
  800ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec1:	89 f9                	mov    %edi,%ecx
  800ec3:	d3 e3                	shl    %cl,%ebx
  800ec5:	89 c1                	mov    %eax,%ecx
  800ec7:	d3 ea                	shr    %cl,%edx
  800ec9:	89 f9                	mov    %edi,%ecx
  800ecb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ecf:	89 eb                	mov    %ebp,%ebx
  800ed1:	d3 e6                	shl    %cl,%esi
  800ed3:	89 c1                	mov    %eax,%ecx
  800ed5:	d3 eb                	shr    %cl,%ebx
  800ed7:	09 de                	or     %ebx,%esi
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	f7 74 24 08          	divl   0x8(%esp)
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	89 c3                	mov    %eax,%ebx
  800ee3:	f7 64 24 0c          	mull   0xc(%esp)
  800ee7:	39 d6                	cmp    %edx,%esi
  800ee9:	72 15                	jb     800f00 <__udivdi3+0x100>
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	d3 e5                	shl    %cl,%ebp
  800eef:	39 c5                	cmp    %eax,%ebp
  800ef1:	73 04                	jae    800ef7 <__udivdi3+0xf7>
  800ef3:	39 d6                	cmp    %edx,%esi
  800ef5:	74 09                	je     800f00 <__udivdi3+0x100>
  800ef7:	89 d8                	mov    %ebx,%eax
  800ef9:	31 ff                	xor    %edi,%edi
  800efb:	e9 40 ff ff ff       	jmp    800e40 <__udivdi3+0x40>
  800f00:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f03:	31 ff                	xor    %edi,%edi
  800f05:	e9 36 ff ff ff       	jmp    800e40 <__udivdi3+0x40>
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	f3 0f 1e fb          	endbr32 
  800f14:	55                   	push   %ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 1c             	sub    $0x1c,%esp
  800f1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f1f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f27:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	75 19                	jne    800f48 <__umoddi3+0x38>
  800f2f:	39 df                	cmp    %ebx,%edi
  800f31:	76 5d                	jbe    800f90 <__umoddi3+0x80>
  800f33:	89 f0                	mov    %esi,%eax
  800f35:	89 da                	mov    %ebx,%edx
  800f37:	f7 f7                	div    %edi
  800f39:	89 d0                	mov    %edx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	89 f2                	mov    %esi,%edx
  800f4a:	39 d8                	cmp    %ebx,%eax
  800f4c:	76 12                	jbe    800f60 <__umoddi3+0x50>
  800f4e:	89 f0                	mov    %esi,%eax
  800f50:	89 da                	mov    %ebx,%edx
  800f52:	83 c4 1c             	add    $0x1c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	0f bd e8             	bsr    %eax,%ebp
  800f63:	83 f5 1f             	xor    $0x1f,%ebp
  800f66:	75 50                	jne    800fb8 <__umoddi3+0xa8>
  800f68:	39 d8                	cmp    %ebx,%eax
  800f6a:	0f 82 e0 00 00 00    	jb     801050 <__umoddi3+0x140>
  800f70:	89 d9                	mov    %ebx,%ecx
  800f72:	39 f7                	cmp    %esi,%edi
  800f74:	0f 86 d6 00 00 00    	jbe    801050 <__umoddi3+0x140>
  800f7a:	89 d0                	mov    %edx,%eax
  800f7c:	89 ca                	mov    %ecx,%edx
  800f7e:	83 c4 1c             	add    $0x1c,%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    
  800f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	89 fd                	mov    %edi,%ebp
  800f92:	85 ff                	test   %edi,%edi
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f7                	div    %edi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	89 d8                	mov    %ebx,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f5                	div    %ebp
  800fa7:	89 f0                	mov    %esi,%eax
  800fa9:	f7 f5                	div    %ebp
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	eb 8c                	jmp    800f3d <__umoddi3+0x2d>
  800fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	ba 20 00 00 00       	mov    $0x20,%edx
  800fbf:	29 ea                	sub    %ebp,%edx
  800fc1:	d3 e0                	shl    %cl,%eax
  800fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc7:	89 d1                	mov    %edx,%ecx
  800fc9:	89 f8                	mov    %edi,%eax
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd9:	09 c1                	or     %eax,%ecx
  800fdb:	89 d8                	mov    %ebx,%eax
  800fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe1:	89 e9                	mov    %ebp,%ecx
  800fe3:	d3 e7                	shl    %cl,%edi
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fef:	d3 e3                	shl    %cl,%ebx
  800ff1:	89 c7                	mov    %eax,%edi
  800ff3:	89 d1                	mov    %edx,%ecx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	89 fa                	mov    %edi,%edx
  800ffd:	d3 e6                	shl    %cl,%esi
  800fff:	09 d8                	or     %ebx,%eax
  801001:	f7 74 24 08          	divl   0x8(%esp)
  801005:	89 d1                	mov    %edx,%ecx
  801007:	89 f3                	mov    %esi,%ebx
  801009:	f7 64 24 0c          	mull   0xc(%esp)
  80100d:	89 c6                	mov    %eax,%esi
  80100f:	89 d7                	mov    %edx,%edi
  801011:	39 d1                	cmp    %edx,%ecx
  801013:	72 06                	jb     80101b <__umoddi3+0x10b>
  801015:	75 10                	jne    801027 <__umoddi3+0x117>
  801017:	39 c3                	cmp    %eax,%ebx
  801019:	73 0c                	jae    801027 <__umoddi3+0x117>
  80101b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80101f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801023:	89 d7                	mov    %edx,%edi
  801025:	89 c6                	mov    %eax,%esi
  801027:	89 ca                	mov    %ecx,%edx
  801029:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80102e:	29 f3                	sub    %esi,%ebx
  801030:	19 fa                	sbb    %edi,%edx
  801032:	89 d0                	mov    %edx,%eax
  801034:	d3 e0                	shl    %cl,%eax
  801036:	89 e9                	mov    %ebp,%ecx
  801038:	d3 eb                	shr    %cl,%ebx
  80103a:	d3 ea                	shr    %cl,%edx
  80103c:	09 d8                	or     %ebx,%eax
  80103e:	83 c4 1c             	add    $0x1c,%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
  801046:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	29 fe                	sub    %edi,%esi
  801052:	19 c3                	sbb    %eax,%ebx
  801054:	89 f2                	mov    %esi,%edx
  801056:	89 d9                	mov    %ebx,%ecx
  801058:	e9 1d ff ff ff       	jmp    800f7a <__umoddi3+0x6a>
