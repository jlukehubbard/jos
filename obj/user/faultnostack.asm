
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
  80003d:	68 82 03 80 00       	push   $0x800382
  800042:	6a 00                	push   $0x0
  800044:	e8 a8 02 00 00       	call   8002f1 <sys_env_set_pgfault_upcall>
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
	thisenv = 0;
  800067:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80006e:	00 00 00 
    envid_t envid = sys_getenvid();
  800071:	e8 d6 00 00 00       	call   80014c <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800076:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 db                	test   %ebx,%ebx
  80008a:	7e 07                	jle    800093 <libmain+0x3b>
		binaryname = argv[0];
  80008c:	8b 06                	mov    (%esi),%eax
  80008e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
  800098:	e8 96 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009d:	e8 0a 00 00 00       	call   8000ac <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	f3 0f 1e fb          	endbr32 
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 4a 00 00 00       	call   800107 <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c2:	f3 0f 1e fb          	endbr32 
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d7:	89 c3                	mov    %eax,%ebx
  8000d9:	89 c7                	mov    %eax,%edi
  8000db:	89 c6                	mov    %eax,%esi
  8000dd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e4:	f3 0f 1e fb          	endbr32 
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	89 d1                	mov    %edx,%ecx
  8000fa:	89 d3                	mov    %edx,%ebx
  8000fc:	89 d7                	mov    %edx,%edi
  8000fe:	89 d6                	mov    %edx,%esi
  800100:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	57                   	push   %edi
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800114:	b9 00 00 00 00       	mov    $0x0,%ecx
  800119:	8b 55 08             	mov    0x8(%ebp),%edx
  80011c:	b8 03 00 00 00       	mov    $0x3,%eax
  800121:	89 cb                	mov    %ecx,%ebx
  800123:	89 cf                	mov    %ecx,%edi
  800125:	89 ce                	mov    %ecx,%esi
  800127:	cd 30                	int    $0x30
	if(check && ret > 0)
  800129:	85 c0                	test   %eax,%eax
  80012b:	7f 08                	jg     800135 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5f                   	pop    %edi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	50                   	push   %eax
  800139:	6a 03                	push   $0x3
  80013b:	68 0a 11 80 00       	push   $0x80110a
  800140:	6a 23                	push   $0x23
  800142:	68 27 11 80 00       	push   $0x801127
  800147:	e8 5c 02 00 00       	call   8003a8 <_panic>

0080014c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014c:	f3 0f 1e fb          	endbr32 
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	asm volatile("int %1\n"
  800156:	ba 00 00 00 00       	mov    $0x0,%edx
  80015b:	b8 02 00 00 00       	mov    $0x2,%eax
  800160:	89 d1                	mov    %edx,%ecx
  800162:	89 d3                	mov    %edx,%ebx
  800164:	89 d7                	mov    %edx,%edi
  800166:	89 d6                	mov    %edx,%esi
  800168:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <sys_yield>:

void
sys_yield(void)
{
  80016f:	f3 0f 1e fb          	endbr32 
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	57                   	push   %edi
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
	asm volatile("int %1\n"
  800179:	ba 00 00 00 00       	mov    $0x0,%edx
  80017e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800183:	89 d1                	mov    %edx,%ecx
  800185:	89 d3                	mov    %edx,%ebx
  800187:	89 d7                	mov    %edx,%edi
  800189:	89 d6                	mov    %edx,%esi
  80018b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018d:	5b                   	pop    %ebx
  80018e:	5e                   	pop    %esi
  80018f:	5f                   	pop    %edi
  800190:	5d                   	pop    %ebp
  800191:	c3                   	ret    

00800192 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800192:	f3 0f 1e fb          	endbr32 
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	57                   	push   %edi
  80019a:	56                   	push   %esi
  80019b:	53                   	push   %ebx
  80019c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019f:	be 00 00 00 00       	mov    $0x0,%esi
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8001af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b2:	89 f7                	mov    %esi,%edi
  8001b4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	7f 08                	jg     8001c2 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bd:	5b                   	pop    %ebx
  8001be:	5e                   	pop    %esi
  8001bf:	5f                   	pop    %edi
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	50                   	push   %eax
  8001c6:	6a 04                	push   $0x4
  8001c8:	68 0a 11 80 00       	push   $0x80110a
  8001cd:	6a 23                	push   $0x23
  8001cf:	68 27 11 80 00       	push   $0x801127
  8001d4:	e8 cf 01 00 00       	call   8003a8 <_panic>

008001d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d9:	f3 0f 1e fb          	endbr32 
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	7f 08                	jg     800208 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5f                   	pop    %edi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	83 ec 0c             	sub    $0xc,%esp
  80020b:	50                   	push   %eax
  80020c:	6a 05                	push   $0x5
  80020e:	68 0a 11 80 00       	push   $0x80110a
  800213:	6a 23                	push   $0x23
  800215:	68 27 11 80 00       	push   $0x801127
  80021a:	e8 89 01 00 00       	call   8003a8 <_panic>

0080021f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021f:	f3 0f 1e fb          	endbr32 
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	8b 55 08             	mov    0x8(%ebp),%edx
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	b8 06 00 00 00       	mov    $0x6,%eax
  80023c:	89 df                	mov    %ebx,%edi
  80023e:	89 de                	mov    %ebx,%esi
  800240:	cd 30                	int    $0x30
	if(check && ret > 0)
  800242:	85 c0                	test   %eax,%eax
  800244:	7f 08                	jg     80024e <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	50                   	push   %eax
  800252:	6a 06                	push   $0x6
  800254:	68 0a 11 80 00       	push   $0x80110a
  800259:	6a 23                	push   $0x23
  80025b:	68 27 11 80 00       	push   $0x801127
  800260:	e8 43 01 00 00       	call   8003a8 <_panic>

00800265 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800265:	f3 0f 1e fb          	endbr32 
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800272:	bb 00 00 00 00       	mov    $0x0,%ebx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	b8 08 00 00 00       	mov    $0x8,%eax
  800282:	89 df                	mov    %ebx,%edi
  800284:	89 de                	mov    %ebx,%esi
  800286:	cd 30                	int    $0x30
	if(check && ret > 0)
  800288:	85 c0                	test   %eax,%eax
  80028a:	7f 08                	jg     800294 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028f:	5b                   	pop    %ebx
  800290:	5e                   	pop    %esi
  800291:	5f                   	pop    %edi
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 08                	push   $0x8
  80029a:	68 0a 11 80 00       	push   $0x80110a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 27 11 80 00       	push   $0x801127
  8002a6:	e8 fd 00 00 00       	call   8003a8 <_panic>

008002ab <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ab:	f3 0f 1e fb          	endbr32 
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7f 08                	jg     8002da <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	50                   	push   %eax
  8002de:	6a 09                	push   $0x9
  8002e0:	68 0a 11 80 00       	push   $0x80110a
  8002e5:	6a 23                	push   $0x23
  8002e7:	68 27 11 80 00       	push   $0x801127
  8002ec:	e8 b7 00 00 00       	call   8003a8 <_panic>

008002f1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f1:	f3 0f 1e fb          	endbr32 
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800309:	b8 0a 00 00 00       	mov    $0xa,%eax
  80030e:	89 df                	mov    %ebx,%edi
  800310:	89 de                	mov    %ebx,%esi
  800312:	cd 30                	int    $0x30
	if(check && ret > 0)
  800314:	85 c0                	test   %eax,%eax
  800316:	7f 08                	jg     800320 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	50                   	push   %eax
  800324:	6a 0a                	push   $0xa
  800326:	68 0a 11 80 00       	push   $0x80110a
  80032b:	6a 23                	push   $0x23
  80032d:	68 27 11 80 00       	push   $0x801127
  800332:	e8 71 00 00 00       	call   8003a8 <_panic>

00800337 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800337:	f3 0f 1e fb          	endbr32 
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
	asm volatile("int %1\n"
  800341:	8b 55 08             	mov    0x8(%ebp),%edx
  800344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800347:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034c:	be 00 00 00 00       	mov    $0x0,%esi
  800351:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800354:	8b 7d 14             	mov    0x14(%ebp),%edi
  800357:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5f                   	pop    %edi
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80035e:	f3 0f 1e fb          	endbr32 
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	57                   	push   %edi
  800366:	56                   	push   %esi
  800367:	53                   	push   %ebx
	asm volatile("int %1\n"
  800368:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036d:	8b 55 08             	mov    0x8(%ebp),%edx
  800370:	b8 0d 00 00 00       	mov    $0xd,%eax
  800375:	89 cb                	mov    %ecx,%ebx
  800377:	89 cf                	mov    %ecx,%edi
  800379:	89 ce                	mov    %ecx,%esi
  80037b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037d:	5b                   	pop    %ebx
  80037e:	5e                   	pop    %esi
  80037f:	5f                   	pop    %edi
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800382:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800383:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800388:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80038a:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  80038d:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  800391:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  800395:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  800398:	83 c4 08             	add    $0x8,%esp
    popa
  80039b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  80039c:	83 c4 04             	add    $0x4,%esp
    popf
  80039f:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8003a0:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8003a3:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  8003a7:	c3                   	ret    

008003a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003a8:	f3 0f 1e fb          	endbr32 
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003b1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003b4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003ba:	e8 8d fd ff ff       	call   80014c <sys_getenvid>
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	ff 75 0c             	pushl  0xc(%ebp)
  8003c5:	ff 75 08             	pushl  0x8(%ebp)
  8003c8:	56                   	push   %esi
  8003c9:	50                   	push   %eax
  8003ca:	68 38 11 80 00       	push   $0x801138
  8003cf:	e8 bb 00 00 00       	call   80048f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d4:	83 c4 18             	add    $0x18,%esp
  8003d7:	53                   	push   %ebx
  8003d8:	ff 75 10             	pushl  0x10(%ebp)
  8003db:	e8 5a 00 00 00       	call   80043a <vcprintf>
	cprintf("\n");
  8003e0:	c7 04 24 6c 14 80 00 	movl   $0x80146c,(%esp)
  8003e7:	e8 a3 00 00 00       	call   80048f <cprintf>
  8003ec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ef:	cc                   	int3   
  8003f0:	eb fd                	jmp    8003ef <_panic+0x47>

008003f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f2:	f3 0f 1e fb          	endbr32 
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	53                   	push   %ebx
  8003fa:	83 ec 04             	sub    $0x4,%esp
  8003fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800400:	8b 13                	mov    (%ebx),%edx
  800402:	8d 42 01             	lea    0x1(%edx),%eax
  800405:	89 03                	mov    %eax,(%ebx)
  800407:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80040e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800413:	74 09                	je     80041e <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800415:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800419:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	68 ff 00 00 00       	push   $0xff
  800426:	8d 43 08             	lea    0x8(%ebx),%eax
  800429:	50                   	push   %eax
  80042a:	e8 93 fc ff ff       	call   8000c2 <sys_cputs>
		b->idx = 0;
  80042f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	eb db                	jmp    800415 <putch+0x23>

0080043a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80043a:	f3 0f 1e fb          	endbr32 
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800447:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80044e:	00 00 00 
	b.cnt = 0;
  800451:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800458:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80045b:	ff 75 0c             	pushl  0xc(%ebp)
  80045e:	ff 75 08             	pushl  0x8(%ebp)
  800461:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800467:	50                   	push   %eax
  800468:	68 f2 03 80 00       	push   $0x8003f2
  80046d:	e8 20 01 00 00       	call   800592 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800472:	83 c4 08             	add    $0x8,%esp
  800475:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80047b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800481:	50                   	push   %eax
  800482:	e8 3b fc ff ff       	call   8000c2 <sys_cputs>

	return b.cnt;
}
  800487:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048d:	c9                   	leave  
  80048e:	c3                   	ret    

0080048f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80048f:	f3 0f 1e fb          	endbr32 
  800493:	55                   	push   %ebp
  800494:	89 e5                	mov    %esp,%ebp
  800496:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800499:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80049c:	50                   	push   %eax
  80049d:	ff 75 08             	pushl  0x8(%ebp)
  8004a0:	e8 95 ff ff ff       	call   80043a <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a5:	c9                   	leave  
  8004a6:	c3                   	ret    

008004a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a7:	55                   	push   %ebp
  8004a8:	89 e5                	mov    %esp,%ebp
  8004aa:	57                   	push   %edi
  8004ab:	56                   	push   %esi
  8004ac:	53                   	push   %ebx
  8004ad:	83 ec 1c             	sub    $0x1c,%esp
  8004b0:	89 c7                	mov    %eax,%edi
  8004b2:	89 d6                	mov    %edx,%esi
  8004b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ba:	89 d1                	mov    %edx,%ecx
  8004bc:	89 c2                	mov    %eax,%edx
  8004be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004d4:	39 c2                	cmp    %eax,%edx
  8004d6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004d9:	72 3e                	jb     800519 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004db:	83 ec 0c             	sub    $0xc,%esp
  8004de:	ff 75 18             	pushl  0x18(%ebp)
  8004e1:	83 eb 01             	sub    $0x1,%ebx
  8004e4:	53                   	push   %ebx
  8004e5:	50                   	push   %eax
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8004f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004f5:	e8 96 09 00 00       	call   800e90 <__udivdi3>
  8004fa:	83 c4 18             	add    $0x18,%esp
  8004fd:	52                   	push   %edx
  8004fe:	50                   	push   %eax
  8004ff:	89 f2                	mov    %esi,%edx
  800501:	89 f8                	mov    %edi,%eax
  800503:	e8 9f ff ff ff       	call   8004a7 <printnum>
  800508:	83 c4 20             	add    $0x20,%esp
  80050b:	eb 13                	jmp    800520 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	56                   	push   %esi
  800511:	ff 75 18             	pushl  0x18(%ebp)
  800514:	ff d7                	call   *%edi
  800516:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800519:	83 eb 01             	sub    $0x1,%ebx
  80051c:	85 db                	test   %ebx,%ebx
  80051e:	7f ed                	jg     80050d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	56                   	push   %esi
  800524:	83 ec 04             	sub    $0x4,%esp
  800527:	ff 75 e4             	pushl  -0x1c(%ebp)
  80052a:	ff 75 e0             	pushl  -0x20(%ebp)
  80052d:	ff 75 dc             	pushl  -0x24(%ebp)
  800530:	ff 75 d8             	pushl  -0x28(%ebp)
  800533:	e8 68 0a 00 00       	call   800fa0 <__umoddi3>
  800538:	83 c4 14             	add    $0x14,%esp
  80053b:	0f be 80 5b 11 80 00 	movsbl 0x80115b(%eax),%eax
  800542:	50                   	push   %eax
  800543:	ff d7                	call   *%edi
}
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80054b:	5b                   	pop    %ebx
  80054c:	5e                   	pop    %esi
  80054d:	5f                   	pop    %edi
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800550:	f3 0f 1e fb          	endbr32 
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80055a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80055e:	8b 10                	mov    (%eax),%edx
  800560:	3b 50 04             	cmp    0x4(%eax),%edx
  800563:	73 0a                	jae    80056f <sprintputch+0x1f>
		*b->buf++ = ch;
  800565:	8d 4a 01             	lea    0x1(%edx),%ecx
  800568:	89 08                	mov    %ecx,(%eax)
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	88 02                	mov    %al,(%edx)
}
  80056f:	5d                   	pop    %ebp
  800570:	c3                   	ret    

00800571 <printfmt>:
{
  800571:	f3 0f 1e fb          	endbr32 
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80057b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80057e:	50                   	push   %eax
  80057f:	ff 75 10             	pushl  0x10(%ebp)
  800582:	ff 75 0c             	pushl  0xc(%ebp)
  800585:	ff 75 08             	pushl  0x8(%ebp)
  800588:	e8 05 00 00 00       	call   800592 <vprintfmt>
}
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	c9                   	leave  
  800591:	c3                   	ret    

00800592 <vprintfmt>:
{
  800592:	f3 0f 1e fb          	endbr32 
  800596:	55                   	push   %ebp
  800597:	89 e5                	mov    %esp,%ebp
  800599:	57                   	push   %edi
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	83 ec 3c             	sub    $0x3c,%esp
  80059f:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005a8:	e9 4a 03 00 00       	jmp    8008f7 <vprintfmt+0x365>
		padc = ' ';
  8005ad:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005bf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005c6:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8d 47 01             	lea    0x1(%edi),%eax
  8005ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d1:	0f b6 17             	movzbl (%edi),%edx
  8005d4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005d7:	3c 55                	cmp    $0x55,%al
  8005d9:	0f 87 de 03 00 00    	ja     8009bd <vprintfmt+0x42b>
  8005df:	0f b6 c0             	movzbl %al,%eax
  8005e2:	3e ff 24 85 a0 12 80 	notrack jmp *0x8012a0(,%eax,4)
  8005e9:	00 
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005ed:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005f1:	eb d8                	jmp    8005cb <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005fa:	eb cf                	jmp    8005cb <vprintfmt+0x39>
  8005fc:	0f b6 d2             	movzbl %dl,%edx
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800602:	b8 00 00 00 00       	mov    $0x0,%eax
  800607:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80060a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80060d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800611:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800614:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800617:	83 f9 09             	cmp    $0x9,%ecx
  80061a:	77 55                	ja     800671 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80061c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80061f:	eb e9                	jmp    80060a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 40 04             	lea    0x4(%eax),%eax
  80062f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800635:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800639:	79 90                	jns    8005cb <vprintfmt+0x39>
				width = precision, precision = -1;
  80063b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800641:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800648:	eb 81                	jmp    8005cb <vprintfmt+0x39>
  80064a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064d:	85 c0                	test   %eax,%eax
  80064f:	ba 00 00 00 00       	mov    $0x0,%edx
  800654:	0f 49 d0             	cmovns %eax,%edx
  800657:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80065d:	e9 69 ff ff ff       	jmp    8005cb <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800665:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80066c:	e9 5a ff ff ff       	jmp    8005cb <vprintfmt+0x39>
  800671:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800674:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800677:	eb bc                	jmp    800635 <vprintfmt+0xa3>
			lflag++;
  800679:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80067f:	e9 47 ff ff ff       	jmp    8005cb <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 78 04             	lea    0x4(%eax),%edi
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	ff 30                	pushl  (%eax)
  800690:	ff d6                	call   *%esi
			break;
  800692:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800695:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800698:	e9 57 02 00 00       	jmp    8008f4 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 78 04             	lea    0x4(%eax),%edi
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	99                   	cltd   
  8006a6:	31 d0                	xor    %edx,%eax
  8006a8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006aa:	83 f8 0f             	cmp    $0xf,%eax
  8006ad:	7f 23                	jg     8006d2 <vprintfmt+0x140>
  8006af:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	74 18                	je     8006d2 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8006ba:	52                   	push   %edx
  8006bb:	68 7c 11 80 00       	push   $0x80117c
  8006c0:	53                   	push   %ebx
  8006c1:	56                   	push   %esi
  8006c2:	e8 aa fe ff ff       	call   800571 <printfmt>
  8006c7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006ca:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006cd:	e9 22 02 00 00       	jmp    8008f4 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006d2:	50                   	push   %eax
  8006d3:	68 73 11 80 00       	push   $0x801173
  8006d8:	53                   	push   %ebx
  8006d9:	56                   	push   %esi
  8006da:	e8 92 fe ff ff       	call   800571 <printfmt>
  8006df:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006e2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006e5:	e9 0a 02 00 00       	jmp    8008f4 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	83 c0 04             	add    $0x4,%eax
  8006f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006f8:	85 d2                	test   %edx,%edx
  8006fa:	b8 6c 11 80 00       	mov    $0x80116c,%eax
  8006ff:	0f 45 c2             	cmovne %edx,%eax
  800702:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800705:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800709:	7e 06                	jle    800711 <vprintfmt+0x17f>
  80070b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80070f:	75 0d                	jne    80071e <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800714:	89 c7                	mov    %eax,%edi
  800716:	03 45 e0             	add    -0x20(%ebp),%eax
  800719:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80071c:	eb 55                	jmp    800773 <vprintfmt+0x1e1>
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 d8             	pushl  -0x28(%ebp)
  800724:	ff 75 cc             	pushl  -0x34(%ebp)
  800727:	e8 45 03 00 00       	call   800a71 <strnlen>
  80072c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80072f:	29 c2                	sub    %eax,%edx
  800731:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800739:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80073d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800740:	85 ff                	test   %edi,%edi
  800742:	7e 11                	jle    800755 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	53                   	push   %ebx
  800748:	ff 75 e0             	pushl  -0x20(%ebp)
  80074b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80074d:	83 ef 01             	sub    $0x1,%edi
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	eb eb                	jmp    800740 <vprintfmt+0x1ae>
  800755:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800758:	85 d2                	test   %edx,%edx
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
  80075f:	0f 49 c2             	cmovns %edx,%eax
  800762:	29 c2                	sub    %eax,%edx
  800764:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800767:	eb a8                	jmp    800711 <vprintfmt+0x17f>
					putch(ch, putdat);
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	53                   	push   %ebx
  80076d:	52                   	push   %edx
  80076e:	ff d6                	call   *%esi
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800776:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800778:	83 c7 01             	add    $0x1,%edi
  80077b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077f:	0f be d0             	movsbl %al,%edx
  800782:	85 d2                	test   %edx,%edx
  800784:	74 4b                	je     8007d1 <vprintfmt+0x23f>
  800786:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80078a:	78 06                	js     800792 <vprintfmt+0x200>
  80078c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800790:	78 1e                	js     8007b0 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800792:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800796:	74 d1                	je     800769 <vprintfmt+0x1d7>
  800798:	0f be c0             	movsbl %al,%eax
  80079b:	83 e8 20             	sub    $0x20,%eax
  80079e:	83 f8 5e             	cmp    $0x5e,%eax
  8007a1:	76 c6                	jbe    800769 <vprintfmt+0x1d7>
					putch('?', putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	6a 3f                	push   $0x3f
  8007a9:	ff d6                	call   *%esi
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	eb c3                	jmp    800773 <vprintfmt+0x1e1>
  8007b0:	89 cf                	mov    %ecx,%edi
  8007b2:	eb 0e                	jmp    8007c2 <vprintfmt+0x230>
				putch(' ', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	6a 20                	push   $0x20
  8007ba:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007bc:	83 ef 01             	sub    $0x1,%edi
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	85 ff                	test   %edi,%edi
  8007c4:	7f ee                	jg     8007b4 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007c6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cc:	e9 23 01 00 00       	jmp    8008f4 <vprintfmt+0x362>
  8007d1:	89 cf                	mov    %ecx,%edi
  8007d3:	eb ed                	jmp    8007c2 <vprintfmt+0x230>
	if (lflag >= 2)
  8007d5:	83 f9 01             	cmp    $0x1,%ecx
  8007d8:	7f 1b                	jg     8007f5 <vprintfmt+0x263>
	else if (lflag)
  8007da:	85 c9                	test   %ecx,%ecx
  8007dc:	74 63                	je     800841 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8b 00                	mov    (%eax),%eax
  8007e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e6:	99                   	cltd   
  8007e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8d 40 04             	lea    0x4(%eax),%eax
  8007f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f3:	eb 17                	jmp    80080c <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8b 50 04             	mov    0x4(%eax),%edx
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800800:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8d 40 08             	lea    0x8(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80080c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80080f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800812:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800817:	85 c9                	test   %ecx,%ecx
  800819:	0f 89 bb 00 00 00    	jns    8008da <vprintfmt+0x348>
				putch('-', putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	6a 2d                	push   $0x2d
  800825:	ff d6                	call   *%esi
				num = -(long long) num;
  800827:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80082a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80082d:	f7 da                	neg    %edx
  80082f:	83 d1 00             	adc    $0x0,%ecx
  800832:	f7 d9                	neg    %ecx
  800834:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800837:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083c:	e9 99 00 00 00       	jmp    8008da <vprintfmt+0x348>
		return va_arg(*ap, int);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8b 00                	mov    (%eax),%eax
  800846:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800849:	99                   	cltd   
  80084a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
  800856:	eb b4                	jmp    80080c <vprintfmt+0x27a>
	if (lflag >= 2)
  800858:	83 f9 01             	cmp    $0x1,%ecx
  80085b:	7f 1b                	jg     800878 <vprintfmt+0x2e6>
	else if (lflag)
  80085d:	85 c9                	test   %ecx,%ecx
  80085f:	74 2c                	je     80088d <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086b:	8d 40 04             	lea    0x4(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800871:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800876:	eb 62                	jmp    8008da <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	8b 48 04             	mov    0x4(%eax),%ecx
  800880:	8d 40 08             	lea    0x8(%eax),%eax
  800883:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800886:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80088b:	eb 4d                	jmp    8008da <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8b 10                	mov    (%eax),%edx
  800892:	b9 00 00 00 00       	mov    $0x0,%ecx
  800897:	8d 40 04             	lea    0x4(%eax),%eax
  80089a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80089d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8008a2:	eb 36                	jmp    8008da <vprintfmt+0x348>
	if (lflag >= 2)
  8008a4:	83 f9 01             	cmp    $0x1,%ecx
  8008a7:	7f 17                	jg     8008c0 <vprintfmt+0x32e>
	else if (lflag)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	74 6e                	je     80091b <vprintfmt+0x389>
		return va_arg(*ap, long);
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8b 10                	mov    (%eax),%edx
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	99                   	cltd   
  8008b5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008b8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008bb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008be:	eb 11                	jmp    8008d1 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c3:	8b 50 04             	mov    0x4(%eax),%edx
  8008c6:	8b 00                	mov    (%eax),%eax
  8008c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008cb:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008d1:	89 d1                	mov    %edx,%ecx
  8008d3:	89 c2                	mov    %eax,%edx
            base = 8;
  8008d5:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008da:	83 ec 0c             	sub    $0xc,%esp
  8008dd:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008e1:	57                   	push   %edi
  8008e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008e5:	50                   	push   %eax
  8008e6:	51                   	push   %ecx
  8008e7:	52                   	push   %edx
  8008e8:	89 da                	mov    %ebx,%edx
  8008ea:	89 f0                	mov    %esi,%eax
  8008ec:	e8 b6 fb ff ff       	call   8004a7 <printnum>
			break;
  8008f1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008f7:	83 c7 01             	add    $0x1,%edi
  8008fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008fe:	83 f8 25             	cmp    $0x25,%eax
  800901:	0f 84 a6 fc ff ff    	je     8005ad <vprintfmt+0x1b>
			if (ch == '\0')
  800907:	85 c0                	test   %eax,%eax
  800909:	0f 84 ce 00 00 00    	je     8009dd <vprintfmt+0x44b>
			putch(ch, putdat);
  80090f:	83 ec 08             	sub    $0x8,%esp
  800912:	53                   	push   %ebx
  800913:	50                   	push   %eax
  800914:	ff d6                	call   *%esi
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb dc                	jmp    8008f7 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80091b:	8b 45 14             	mov    0x14(%ebp),%eax
  80091e:	8b 10                	mov    (%eax),%edx
  800920:	89 d0                	mov    %edx,%eax
  800922:	99                   	cltd   
  800923:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800926:	8d 49 04             	lea    0x4(%ecx),%ecx
  800929:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80092c:	eb a3                	jmp    8008d1 <vprintfmt+0x33f>
			putch('0', putdat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	6a 30                	push   $0x30
  800934:	ff d6                	call   *%esi
			putch('x', putdat);
  800936:	83 c4 08             	add    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 78                	push   $0x78
  80093c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8b 10                	mov    (%eax),%edx
  800943:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800948:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80094b:	8d 40 04             	lea    0x4(%eax),%eax
  80094e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800951:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800956:	eb 82                	jmp    8008da <vprintfmt+0x348>
	if (lflag >= 2)
  800958:	83 f9 01             	cmp    $0x1,%ecx
  80095b:	7f 1e                	jg     80097b <vprintfmt+0x3e9>
	else if (lflag)
  80095d:	85 c9                	test   %ecx,%ecx
  80095f:	74 32                	je     800993 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800961:	8b 45 14             	mov    0x14(%ebp),%eax
  800964:	8b 10                	mov    (%eax),%edx
  800966:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096b:	8d 40 04             	lea    0x4(%eax),%eax
  80096e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800971:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800976:	e9 5f ff ff ff       	jmp    8008da <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80097b:	8b 45 14             	mov    0x14(%ebp),%eax
  80097e:	8b 10                	mov    (%eax),%edx
  800980:	8b 48 04             	mov    0x4(%eax),%ecx
  800983:	8d 40 08             	lea    0x8(%eax),%eax
  800986:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800989:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80098e:	e9 47 ff ff ff       	jmp    8008da <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	8b 10                	mov    (%eax),%edx
  800998:	b9 00 00 00 00       	mov    $0x0,%ecx
  80099d:	8d 40 04             	lea    0x4(%eax),%eax
  8009a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009a3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8009a8:	e9 2d ff ff ff       	jmp    8008da <vprintfmt+0x348>
			putch(ch, putdat);
  8009ad:	83 ec 08             	sub    $0x8,%esp
  8009b0:	53                   	push   %ebx
  8009b1:	6a 25                	push   $0x25
  8009b3:	ff d6                	call   *%esi
			break;
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	e9 37 ff ff ff       	jmp    8008f4 <vprintfmt+0x362>
			putch('%', putdat);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	53                   	push   %ebx
  8009c1:	6a 25                	push   $0x25
  8009c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c5:	83 c4 10             	add    $0x10,%esp
  8009c8:	89 f8                	mov    %edi,%eax
  8009ca:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009ce:	74 05                	je     8009d5 <vprintfmt+0x443>
  8009d0:	83 e8 01             	sub    $0x1,%eax
  8009d3:	eb f5                	jmp    8009ca <vprintfmt+0x438>
  8009d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009d8:	e9 17 ff ff ff       	jmp    8008f4 <vprintfmt+0x362>
}
  8009dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e5:	f3 0f 1e fb          	endbr32 
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	83 ec 18             	sub    $0x18,%esp
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a06:	85 c0                	test   %eax,%eax
  800a08:	74 26                	je     800a30 <vsnprintf+0x4b>
  800a0a:	85 d2                	test   %edx,%edx
  800a0c:	7e 22                	jle    800a30 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a0e:	ff 75 14             	pushl  0x14(%ebp)
  800a11:	ff 75 10             	pushl  0x10(%ebp)
  800a14:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a17:	50                   	push   %eax
  800a18:	68 50 05 80 00       	push   $0x800550
  800a1d:	e8 70 fb ff ff       	call   800592 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a25:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a2b:	83 c4 10             	add    $0x10,%esp
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    
		return -E_INVAL;
  800a30:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a35:	eb f7                	jmp    800a2e <vsnprintf+0x49>

00800a37 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a37:	f3 0f 1e fb          	endbr32 
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a41:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a44:	50                   	push   %eax
  800a45:	ff 75 10             	pushl  0x10(%ebp)
  800a48:	ff 75 0c             	pushl  0xc(%ebp)
  800a4b:	ff 75 08             	pushl  0x8(%ebp)
  800a4e:	e8 92 ff ff ff       	call   8009e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a53:	c9                   	leave  
  800a54:	c3                   	ret    

00800a55 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a55:	f3 0f 1e fb          	endbr32 
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a68:	74 05                	je     800a6f <strlen+0x1a>
		n++;
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	eb f5                	jmp    800a64 <strlen+0xf>
	return n;
}
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a71:	f3 0f 1e fb          	endbr32 
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	39 d0                	cmp    %edx,%eax
  800a85:	74 0d                	je     800a94 <strnlen+0x23>
  800a87:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a8b:	74 05                	je     800a92 <strnlen+0x21>
		n++;
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	eb f1                	jmp    800a83 <strnlen+0x12>
  800a92:	89 c2                	mov    %eax,%edx
	return n;
}
  800a94:	89 d0                	mov    %edx,%eax
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a98:	f3 0f 1e fb          	endbr32 
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	53                   	push   %ebx
  800aa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800aaf:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800ab2:	83 c0 01             	add    $0x1,%eax
  800ab5:	84 d2                	test   %dl,%dl
  800ab7:	75 f2                	jne    800aab <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800ab9:	89 c8                	mov    %ecx,%eax
  800abb:	5b                   	pop    %ebx
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <strcat>:

char *
strcat(char *dst, const char *src)
{
  800abe:	f3 0f 1e fb          	endbr32 
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 10             	sub    $0x10,%esp
  800ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800acc:	53                   	push   %ebx
  800acd:	e8 83 ff ff ff       	call   800a55 <strlen>
  800ad2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ad5:	ff 75 0c             	pushl  0xc(%ebp)
  800ad8:	01 d8                	add    %ebx,%eax
  800ada:	50                   	push   %eax
  800adb:	e8 b8 ff ff ff       	call   800a98 <strcpy>
	return dst;
}
  800ae0:	89 d8                	mov    %ebx,%eax
  800ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae7:	f3 0f 1e fb          	endbr32 
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800afb:	89 f0                	mov    %esi,%eax
  800afd:	39 d8                	cmp    %ebx,%eax
  800aff:	74 11                	je     800b12 <strncpy+0x2b>
		*dst++ = *src;
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	0f b6 0a             	movzbl (%edx),%ecx
  800b07:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b0a:	80 f9 01             	cmp    $0x1,%cl
  800b0d:	83 da ff             	sbb    $0xffffffff,%edx
  800b10:	eb eb                	jmp    800afd <strncpy+0x16>
	}
	return ret;
}
  800b12:	89 f0                	mov    %esi,%eax
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b18:	f3 0f 1e fb          	endbr32 
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	8b 75 08             	mov    0x8(%ebp),%esi
  800b24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b27:	8b 55 10             	mov    0x10(%ebp),%edx
  800b2a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b2c:	85 d2                	test   %edx,%edx
  800b2e:	74 21                	je     800b51 <strlcpy+0x39>
  800b30:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b34:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b36:	39 c2                	cmp    %eax,%edx
  800b38:	74 14                	je     800b4e <strlcpy+0x36>
  800b3a:	0f b6 19             	movzbl (%ecx),%ebx
  800b3d:	84 db                	test   %bl,%bl
  800b3f:	74 0b                	je     800b4c <strlcpy+0x34>
			*dst++ = *src++;
  800b41:	83 c1 01             	add    $0x1,%ecx
  800b44:	83 c2 01             	add    $0x1,%edx
  800b47:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b4a:	eb ea                	jmp    800b36 <strlcpy+0x1e>
  800b4c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b4e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b51:	29 f0                	sub    %esi,%eax
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b57:	f3 0f 1e fb          	endbr32 
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b61:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b64:	0f b6 01             	movzbl (%ecx),%eax
  800b67:	84 c0                	test   %al,%al
  800b69:	74 0c                	je     800b77 <strcmp+0x20>
  800b6b:	3a 02                	cmp    (%edx),%al
  800b6d:	75 08                	jne    800b77 <strcmp+0x20>
		p++, q++;
  800b6f:	83 c1 01             	add    $0x1,%ecx
  800b72:	83 c2 01             	add    $0x1,%edx
  800b75:	eb ed                	jmp    800b64 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b77:	0f b6 c0             	movzbl %al,%eax
  800b7a:	0f b6 12             	movzbl (%edx),%edx
  800b7d:	29 d0                	sub    %edx,%eax
}
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b81:	f3 0f 1e fb          	endbr32 
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	53                   	push   %ebx
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8f:	89 c3                	mov    %eax,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b94:	eb 06                	jmp    800b9c <strncmp+0x1b>
		n--, p++, q++;
  800b96:	83 c0 01             	add    $0x1,%eax
  800b99:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b9c:	39 d8                	cmp    %ebx,%eax
  800b9e:	74 16                	je     800bb6 <strncmp+0x35>
  800ba0:	0f b6 08             	movzbl (%eax),%ecx
  800ba3:	84 c9                	test   %cl,%cl
  800ba5:	74 04                	je     800bab <strncmp+0x2a>
  800ba7:	3a 0a                	cmp    (%edx),%cl
  800ba9:	74 eb                	je     800b96 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bab:	0f b6 00             	movzbl (%eax),%eax
  800bae:	0f b6 12             	movzbl (%edx),%edx
  800bb1:	29 d0                	sub    %edx,%eax
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    
		return 0;
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	eb f6                	jmp    800bb3 <strncmp+0x32>

00800bbd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bbd:	f3 0f 1e fb          	endbr32 
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bcb:	0f b6 10             	movzbl (%eax),%edx
  800bce:	84 d2                	test   %dl,%dl
  800bd0:	74 09                	je     800bdb <strchr+0x1e>
		if (*s == c)
  800bd2:	38 ca                	cmp    %cl,%dl
  800bd4:	74 0a                	je     800be0 <strchr+0x23>
	for (; *s; s++)
  800bd6:	83 c0 01             	add    $0x1,%eax
  800bd9:	eb f0                	jmp    800bcb <strchr+0xe>
			return (char *) s;
	return 0;
  800bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800be2:	f3 0f 1e fb          	endbr32 
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bf0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bf3:	38 ca                	cmp    %cl,%dl
  800bf5:	74 09                	je     800c00 <strfind+0x1e>
  800bf7:	84 d2                	test   %dl,%dl
  800bf9:	74 05                	je     800c00 <strfind+0x1e>
	for (; *s; s++)
  800bfb:	83 c0 01             	add    $0x1,%eax
  800bfe:	eb f0                	jmp    800bf0 <strfind+0xe>
			break;
	return (char *) s;
}
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c02:	f3 0f 1e fb          	endbr32 
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c12:	85 c9                	test   %ecx,%ecx
  800c14:	74 31                	je     800c47 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c16:	89 f8                	mov    %edi,%eax
  800c18:	09 c8                	or     %ecx,%eax
  800c1a:	a8 03                	test   $0x3,%al
  800c1c:	75 23                	jne    800c41 <memset+0x3f>
		c &= 0xFF;
  800c1e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c22:	89 d3                	mov    %edx,%ebx
  800c24:	c1 e3 08             	shl    $0x8,%ebx
  800c27:	89 d0                	mov    %edx,%eax
  800c29:	c1 e0 18             	shl    $0x18,%eax
  800c2c:	89 d6                	mov    %edx,%esi
  800c2e:	c1 e6 10             	shl    $0x10,%esi
  800c31:	09 f0                	or     %esi,%eax
  800c33:	09 c2                	or     %eax,%edx
  800c35:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c37:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c3a:	89 d0                	mov    %edx,%eax
  800c3c:	fc                   	cld    
  800c3d:	f3 ab                	rep stos %eax,%es:(%edi)
  800c3f:	eb 06                	jmp    800c47 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c44:	fc                   	cld    
  800c45:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c47:	89 f8                	mov    %edi,%eax
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c4e:	f3 0f 1e fb          	endbr32 
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c60:	39 c6                	cmp    %eax,%esi
  800c62:	73 32                	jae    800c96 <memmove+0x48>
  800c64:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c67:	39 c2                	cmp    %eax,%edx
  800c69:	76 2b                	jbe    800c96 <memmove+0x48>
		s += n;
		d += n;
  800c6b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6e:	89 fe                	mov    %edi,%esi
  800c70:	09 ce                	or     %ecx,%esi
  800c72:	09 d6                	or     %edx,%esi
  800c74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c7a:	75 0e                	jne    800c8a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c7c:	83 ef 04             	sub    $0x4,%edi
  800c7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c82:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c85:	fd                   	std    
  800c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c88:	eb 09                	jmp    800c93 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c8a:	83 ef 01             	sub    $0x1,%edi
  800c8d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c90:	fd                   	std    
  800c91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c93:	fc                   	cld    
  800c94:	eb 1a                	jmp    800cb0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c96:	89 c2                	mov    %eax,%edx
  800c98:	09 ca                	or     %ecx,%edx
  800c9a:	09 f2                	or     %esi,%edx
  800c9c:	f6 c2 03             	test   $0x3,%dl
  800c9f:	75 0a                	jne    800cab <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ca1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ca4:	89 c7                	mov    %eax,%edi
  800ca6:	fc                   	cld    
  800ca7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca9:	eb 05                	jmp    800cb0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800cab:	89 c7                	mov    %eax,%edi
  800cad:	fc                   	cld    
  800cae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cb4:	f3 0f 1e fb          	endbr32 
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cbe:	ff 75 10             	pushl  0x10(%ebp)
  800cc1:	ff 75 0c             	pushl  0xc(%ebp)
  800cc4:	ff 75 08             	pushl  0x8(%ebp)
  800cc7:	e8 82 ff ff ff       	call   800c4e <memmove>
}
  800ccc:	c9                   	leave  
  800ccd:	c3                   	ret    

00800cce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cce:	f3 0f 1e fb          	endbr32 
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cdd:	89 c6                	mov    %eax,%esi
  800cdf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce2:	39 f0                	cmp    %esi,%eax
  800ce4:	74 1c                	je     800d02 <memcmp+0x34>
		if (*s1 != *s2)
  800ce6:	0f b6 08             	movzbl (%eax),%ecx
  800ce9:	0f b6 1a             	movzbl (%edx),%ebx
  800cec:	38 d9                	cmp    %bl,%cl
  800cee:	75 08                	jne    800cf8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cf0:	83 c0 01             	add    $0x1,%eax
  800cf3:	83 c2 01             	add    $0x1,%edx
  800cf6:	eb ea                	jmp    800ce2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cf8:	0f b6 c1             	movzbl %cl,%eax
  800cfb:	0f b6 db             	movzbl %bl,%ebx
  800cfe:	29 d8                	sub    %ebx,%eax
  800d00:	eb 05                	jmp    800d07 <memcmp+0x39>
	}

	return 0;
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d0b:	f3 0f 1e fb          	endbr32 
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d18:	89 c2                	mov    %eax,%edx
  800d1a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d1d:	39 d0                	cmp    %edx,%eax
  800d1f:	73 09                	jae    800d2a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d21:	38 08                	cmp    %cl,(%eax)
  800d23:	74 05                	je     800d2a <memfind+0x1f>
	for (; s < ends; s++)
  800d25:	83 c0 01             	add    $0x1,%eax
  800d28:	eb f3                	jmp    800d1d <memfind+0x12>
			break;
	return (void *) s;
}
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d2c:	f3 0f 1e fb          	endbr32 
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3c:	eb 03                	jmp    800d41 <strtol+0x15>
		s++;
  800d3e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d41:	0f b6 01             	movzbl (%ecx),%eax
  800d44:	3c 20                	cmp    $0x20,%al
  800d46:	74 f6                	je     800d3e <strtol+0x12>
  800d48:	3c 09                	cmp    $0x9,%al
  800d4a:	74 f2                	je     800d3e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d4c:	3c 2b                	cmp    $0x2b,%al
  800d4e:	74 2a                	je     800d7a <strtol+0x4e>
	int neg = 0;
  800d50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d55:	3c 2d                	cmp    $0x2d,%al
  800d57:	74 2b                	je     800d84 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d5f:	75 0f                	jne    800d70 <strtol+0x44>
  800d61:	80 39 30             	cmpb   $0x30,(%ecx)
  800d64:	74 28                	je     800d8e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d66:	85 db                	test   %ebx,%ebx
  800d68:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6d:	0f 44 d8             	cmove  %eax,%ebx
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
  800d75:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d78:	eb 46                	jmp    800dc0 <strtol+0x94>
		s++;
  800d7a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d82:	eb d5                	jmp    800d59 <strtol+0x2d>
		s++, neg = 1;
  800d84:	83 c1 01             	add    $0x1,%ecx
  800d87:	bf 01 00 00 00       	mov    $0x1,%edi
  800d8c:	eb cb                	jmp    800d59 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d92:	74 0e                	je     800da2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d94:	85 db                	test   %ebx,%ebx
  800d96:	75 d8                	jne    800d70 <strtol+0x44>
		s++, base = 8;
  800d98:	83 c1 01             	add    $0x1,%ecx
  800d9b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800da0:	eb ce                	jmp    800d70 <strtol+0x44>
		s += 2, base = 16;
  800da2:	83 c1 02             	add    $0x2,%ecx
  800da5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800daa:	eb c4                	jmp    800d70 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800dac:	0f be d2             	movsbl %dl,%edx
  800daf:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800db2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800db5:	7d 3a                	jge    800df1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800db7:	83 c1 01             	add    $0x1,%ecx
  800dba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dbe:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800dc0:	0f b6 11             	movzbl (%ecx),%edx
  800dc3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dc6:	89 f3                	mov    %esi,%ebx
  800dc8:	80 fb 09             	cmp    $0x9,%bl
  800dcb:	76 df                	jbe    800dac <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dcd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dd0:	89 f3                	mov    %esi,%ebx
  800dd2:	80 fb 19             	cmp    $0x19,%bl
  800dd5:	77 08                	ja     800ddf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dd7:	0f be d2             	movsbl %dl,%edx
  800dda:	83 ea 57             	sub    $0x57,%edx
  800ddd:	eb d3                	jmp    800db2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ddf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800de2:	89 f3                	mov    %esi,%ebx
  800de4:	80 fb 19             	cmp    $0x19,%bl
  800de7:	77 08                	ja     800df1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800de9:	0f be d2             	movsbl %dl,%edx
  800dec:	83 ea 37             	sub    $0x37,%edx
  800def:	eb c1                	jmp    800db2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800df1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df5:	74 05                	je     800dfc <strtol+0xd0>
		*endptr = (char *) s;
  800df7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dfa:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	f7 da                	neg    %edx
  800e00:	85 ff                	test   %edi,%edi
  800e02:	0f 45 c2             	cmovne %edx,%eax
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e0a:	f3 0f 1e fb          	endbr32 
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e14:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e1b:	74 0a                	je     800e27 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e25:	c9                   	leave  
  800e26:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	68 5f 14 80 00       	push   $0x80145f
  800e2f:	e8 5b f6 ff ff       	call   80048f <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e34:	83 c4 0c             	add    $0xc,%esp
  800e37:	6a 07                	push   $0x7
  800e39:	68 00 f0 bf ee       	push   $0xeebff000
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 4d f3 ff ff       	call   800192 <sys_page_alloc>
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	78 2a                	js     800e76 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800e4c:	83 ec 08             	sub    $0x8,%esp
  800e4f:	68 82 03 80 00       	push   $0x800382
  800e54:	6a 00                	push   $0x0
  800e56:	e8 96 f4 ff ff       	call   8002f1 <sys_env_set_pgfault_upcall>
  800e5b:	83 c4 10             	add    $0x10,%esp
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	79 bb                	jns    800e1d <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	68 9c 14 80 00       	push   $0x80149c
  800e6a:	6a 25                	push   $0x25
  800e6c:	68 8c 14 80 00       	push   $0x80148c
  800e71:	e8 32 f5 ff ff       	call   8003a8 <_panic>
            panic("Allocation of UXSTACK failed!");
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	68 6e 14 80 00       	push   $0x80146e
  800e7e:	6a 22                	push   $0x22
  800e80:	68 8c 14 80 00       	push   $0x80148c
  800e85:	e8 1e f5 ff ff       	call   8003a8 <_panic>
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__udivdi3>:
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 1c             	sub    $0x1c,%esp
  800e9b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e9f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ea3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800eab:	85 d2                	test   %edx,%edx
  800ead:	75 19                	jne    800ec8 <__udivdi3+0x38>
  800eaf:	39 f3                	cmp    %esi,%ebx
  800eb1:	76 4d                	jbe    800f00 <__udivdi3+0x70>
  800eb3:	31 ff                	xor    %edi,%edi
  800eb5:	89 e8                	mov    %ebp,%eax
  800eb7:	89 f2                	mov    %esi,%edx
  800eb9:	f7 f3                	div    %ebx
  800ebb:	89 fa                	mov    %edi,%edx
  800ebd:	83 c4 1c             	add    $0x1c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	39 f2                	cmp    %esi,%edx
  800eca:	76 14                	jbe    800ee0 <__udivdi3+0x50>
  800ecc:	31 ff                	xor    %edi,%edi
  800ece:	31 c0                	xor    %eax,%eax
  800ed0:	89 fa                	mov    %edi,%edx
  800ed2:	83 c4 1c             	add    $0x1c,%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    
  800eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee0:	0f bd fa             	bsr    %edx,%edi
  800ee3:	83 f7 1f             	xor    $0x1f,%edi
  800ee6:	75 48                	jne    800f30 <__udivdi3+0xa0>
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	72 06                	jb     800ef2 <__udivdi3+0x62>
  800eec:	31 c0                	xor    %eax,%eax
  800eee:	39 eb                	cmp    %ebp,%ebx
  800ef0:	77 de                	ja     800ed0 <__udivdi3+0x40>
  800ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef7:	eb d7                	jmp    800ed0 <__udivdi3+0x40>
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d9                	mov    %ebx,%ecx
  800f02:	85 db                	test   %ebx,%ebx
  800f04:	75 0b                	jne    800f11 <__udivdi3+0x81>
  800f06:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	f7 f3                	div    %ebx
  800f0f:	89 c1                	mov    %eax,%ecx
  800f11:	31 d2                	xor    %edx,%edx
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	f7 f1                	div    %ecx
  800f17:	89 c6                	mov    %eax,%esi
  800f19:	89 e8                	mov    %ebp,%eax
  800f1b:	89 f7                	mov    %esi,%edi
  800f1d:	f7 f1                	div    %ecx
  800f1f:	89 fa                	mov    %edi,%edx
  800f21:	83 c4 1c             	add    $0x1c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	89 f9                	mov    %edi,%ecx
  800f32:	b8 20 00 00 00       	mov    $0x20,%eax
  800f37:	29 f8                	sub    %edi,%eax
  800f39:	d3 e2                	shl    %cl,%edx
  800f3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f3f:	89 c1                	mov    %eax,%ecx
  800f41:	89 da                	mov    %ebx,%edx
  800f43:	d3 ea                	shr    %cl,%edx
  800f45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f49:	09 d1                	or     %edx,%ecx
  800f4b:	89 f2                	mov    %esi,%edx
  800f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f51:	89 f9                	mov    %edi,%ecx
  800f53:	d3 e3                	shl    %cl,%ebx
  800f55:	89 c1                	mov    %eax,%ecx
  800f57:	d3 ea                	shr    %cl,%edx
  800f59:	89 f9                	mov    %edi,%ecx
  800f5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f5f:	89 eb                	mov    %ebp,%ebx
  800f61:	d3 e6                	shl    %cl,%esi
  800f63:	89 c1                	mov    %eax,%ecx
  800f65:	d3 eb                	shr    %cl,%ebx
  800f67:	09 de                	or     %ebx,%esi
  800f69:	89 f0                	mov    %esi,%eax
  800f6b:	f7 74 24 08          	divl   0x8(%esp)
  800f6f:	89 d6                	mov    %edx,%esi
  800f71:	89 c3                	mov    %eax,%ebx
  800f73:	f7 64 24 0c          	mull   0xc(%esp)
  800f77:	39 d6                	cmp    %edx,%esi
  800f79:	72 15                	jb     800f90 <__udivdi3+0x100>
  800f7b:	89 f9                	mov    %edi,%ecx
  800f7d:	d3 e5                	shl    %cl,%ebp
  800f7f:	39 c5                	cmp    %eax,%ebp
  800f81:	73 04                	jae    800f87 <__udivdi3+0xf7>
  800f83:	39 d6                	cmp    %edx,%esi
  800f85:	74 09                	je     800f90 <__udivdi3+0x100>
  800f87:	89 d8                	mov    %ebx,%eax
  800f89:	31 ff                	xor    %edi,%edi
  800f8b:	e9 40 ff ff ff       	jmp    800ed0 <__udivdi3+0x40>
  800f90:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f93:	31 ff                	xor    %edi,%edi
  800f95:	e9 36 ff ff ff       	jmp    800ed0 <__udivdi3+0x40>
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <__umoddi3>:
  800fa0:	f3 0f 1e fb          	endbr32 
  800fa4:	55                   	push   %ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 1c             	sub    $0x1c,%esp
  800fab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800faf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fb3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fb7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	75 19                	jne    800fd8 <__umoddi3+0x38>
  800fbf:	39 df                	cmp    %ebx,%edi
  800fc1:	76 5d                	jbe    801020 <__umoddi3+0x80>
  800fc3:	89 f0                	mov    %esi,%eax
  800fc5:	89 da                	mov    %ebx,%edx
  800fc7:	f7 f7                	div    %edi
  800fc9:	89 d0                	mov    %edx,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	83 c4 1c             	add    $0x1c,%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi
  800fd8:	89 f2                	mov    %esi,%edx
  800fda:	39 d8                	cmp    %ebx,%eax
  800fdc:	76 12                	jbe    800ff0 <__umoddi3+0x50>
  800fde:	89 f0                	mov    %esi,%eax
  800fe0:	89 da                	mov    %ebx,%edx
  800fe2:	83 c4 1c             	add    $0x1c,%esp
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    
  800fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ff0:	0f bd e8             	bsr    %eax,%ebp
  800ff3:	83 f5 1f             	xor    $0x1f,%ebp
  800ff6:	75 50                	jne    801048 <__umoddi3+0xa8>
  800ff8:	39 d8                	cmp    %ebx,%eax
  800ffa:	0f 82 e0 00 00 00    	jb     8010e0 <__umoddi3+0x140>
  801000:	89 d9                	mov    %ebx,%ecx
  801002:	39 f7                	cmp    %esi,%edi
  801004:	0f 86 d6 00 00 00    	jbe    8010e0 <__umoddi3+0x140>
  80100a:	89 d0                	mov    %edx,%eax
  80100c:	89 ca                	mov    %ecx,%edx
  80100e:	83 c4 1c             	add    $0x1c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	89 fd                	mov    %edi,%ebp
  801022:	85 ff                	test   %edi,%edi
  801024:	75 0b                	jne    801031 <__umoddi3+0x91>
  801026:	b8 01 00 00 00       	mov    $0x1,%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	f7 f7                	div    %edi
  80102f:	89 c5                	mov    %eax,%ebp
  801031:	89 d8                	mov    %ebx,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	f7 f5                	div    %ebp
  801037:	89 f0                	mov    %esi,%eax
  801039:	f7 f5                	div    %ebp
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	31 d2                	xor    %edx,%edx
  80103f:	eb 8c                	jmp    800fcd <__umoddi3+0x2d>
  801041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801048:	89 e9                	mov    %ebp,%ecx
  80104a:	ba 20 00 00 00       	mov    $0x20,%edx
  80104f:	29 ea                	sub    %ebp,%edx
  801051:	d3 e0                	shl    %cl,%eax
  801053:	89 44 24 08          	mov    %eax,0x8(%esp)
  801057:	89 d1                	mov    %edx,%ecx
  801059:	89 f8                	mov    %edi,%eax
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801061:	89 54 24 04          	mov    %edx,0x4(%esp)
  801065:	8b 54 24 04          	mov    0x4(%esp),%edx
  801069:	09 c1                	or     %eax,%ecx
  80106b:	89 d8                	mov    %ebx,%eax
  80106d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801071:	89 e9                	mov    %ebp,%ecx
  801073:	d3 e7                	shl    %cl,%edi
  801075:	89 d1                	mov    %edx,%ecx
  801077:	d3 e8                	shr    %cl,%eax
  801079:	89 e9                	mov    %ebp,%ecx
  80107b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107f:	d3 e3                	shl    %cl,%ebx
  801081:	89 c7                	mov    %eax,%edi
  801083:	89 d1                	mov    %edx,%ecx
  801085:	89 f0                	mov    %esi,%eax
  801087:	d3 e8                	shr    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	89 fa                	mov    %edi,%edx
  80108d:	d3 e6                	shl    %cl,%esi
  80108f:	09 d8                	or     %ebx,%eax
  801091:	f7 74 24 08          	divl   0x8(%esp)
  801095:	89 d1                	mov    %edx,%ecx
  801097:	89 f3                	mov    %esi,%ebx
  801099:	f7 64 24 0c          	mull   0xc(%esp)
  80109d:	89 c6                	mov    %eax,%esi
  80109f:	89 d7                	mov    %edx,%edi
  8010a1:	39 d1                	cmp    %edx,%ecx
  8010a3:	72 06                	jb     8010ab <__umoddi3+0x10b>
  8010a5:	75 10                	jne    8010b7 <__umoddi3+0x117>
  8010a7:	39 c3                	cmp    %eax,%ebx
  8010a9:	73 0c                	jae    8010b7 <__umoddi3+0x117>
  8010ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8010b3:	89 d7                	mov    %edx,%edi
  8010b5:	89 c6                	mov    %eax,%esi
  8010b7:	89 ca                	mov    %ecx,%edx
  8010b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010be:	29 f3                	sub    %esi,%ebx
  8010c0:	19 fa                	sbb    %edi,%edx
  8010c2:	89 d0                	mov    %edx,%eax
  8010c4:	d3 e0                	shl    %cl,%eax
  8010c6:	89 e9                	mov    %ebp,%ecx
  8010c8:	d3 eb                	shr    %cl,%ebx
  8010ca:	d3 ea                	shr    %cl,%edx
  8010cc:	09 d8                	or     %ebx,%eax
  8010ce:	83 c4 1c             	add    $0x1c,%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
  8010d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	29 fe                	sub    %edi,%esi
  8010e2:	19 c3                	sbb    %eax,%ebx
  8010e4:	89 f2                	mov    %esi,%edx
  8010e6:	89 d9                	mov    %ebx,%ecx
  8010e8:	e9 1d ff ff ff       	jmp    80100a <__umoddi3+0x6a>
