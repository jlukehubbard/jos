
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
  80003d:	68 a3 03 80 00       	push   $0x8003a3
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
  80013b:	68 2a 11 80 00       	push   $0x80112a
  800140:	6a 23                	push   $0x23
  800142:	68 47 11 80 00       	push   $0x801147
  800147:	e8 7d 02 00 00       	call   8003c9 <_panic>

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
  8001c8:	68 2a 11 80 00       	push   $0x80112a
  8001cd:	6a 23                	push   $0x23
  8001cf:	68 47 11 80 00       	push   $0x801147
  8001d4:	e8 f0 01 00 00       	call   8003c9 <_panic>

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
  80020e:	68 2a 11 80 00       	push   $0x80112a
  800213:	6a 23                	push   $0x23
  800215:	68 47 11 80 00       	push   $0x801147
  80021a:	e8 aa 01 00 00       	call   8003c9 <_panic>

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
  800254:	68 2a 11 80 00       	push   $0x80112a
  800259:	6a 23                	push   $0x23
  80025b:	68 47 11 80 00       	push   $0x801147
  800260:	e8 64 01 00 00       	call   8003c9 <_panic>

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
  80029a:	68 2a 11 80 00       	push   $0x80112a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 47 11 80 00       	push   $0x801147
  8002a6:	e8 1e 01 00 00       	call   8003c9 <_panic>

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
  8002e0:	68 2a 11 80 00       	push   $0x80112a
  8002e5:	6a 23                	push   $0x23
  8002e7:	68 47 11 80 00       	push   $0x801147
  8002ec:	e8 d8 00 00 00       	call   8003c9 <_panic>

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
  800326:	68 2a 11 80 00       	push   $0x80112a
  80032b:	6a 23                	push   $0x23
  80032d:	68 47 11 80 00       	push   $0x801147
  800332:	e8 92 00 00 00       	call   8003c9 <_panic>

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
  800368:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800370:	8b 55 08             	mov    0x8(%ebp),%edx
  800373:	b8 0d 00 00 00       	mov    $0xd,%eax
  800378:	89 cb                	mov    %ecx,%ebx
  80037a:	89 cf                	mov    %ecx,%edi
  80037c:	89 ce                	mov    %ecx,%esi
  80037e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800380:	85 c0                	test   %eax,%eax
  800382:	7f 08                	jg     80038c <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800384:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800387:	5b                   	pop    %ebx
  800388:	5e                   	pop    %esi
  800389:	5f                   	pop    %edi
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80038c:	83 ec 0c             	sub    $0xc,%esp
  80038f:	50                   	push   %eax
  800390:	6a 0d                	push   $0xd
  800392:	68 2a 11 80 00       	push   $0x80112a
  800397:	6a 23                	push   $0x23
  800399:	68 47 11 80 00       	push   $0x801147
  80039e:	e8 26 00 00 00       	call   8003c9 <_panic>

008003a3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003a3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003a4:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8003a9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003ab:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    // load trap-time eip to ebp
    mov 40(%esp), %ebp
  8003ae:	8b 6c 24 28          	mov    0x28(%esp),%ebp
    // load trap-time esp to edi
    mov 48(%esp), %edi
  8003b2:	8b 7c 24 30          	mov    0x30(%esp),%edi
    // push trap-time eip to trap-time esp
    mov %ebp, -4(%edi)
  8003b6:	89 6f fc             	mov    %ebp,-0x4(%edi)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
    add $8, %esp
  8003b9:	83 c4 08             	add    $0x8,%esp
    popa
  8003bc:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

    add $0x4, %esp
  8003bd:	83 c4 04             	add    $0x4,%esp
    popf
  8003c0:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    mov (%esp), %esp
  8003c1:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    lea -4(%esp), %esp
  8003c4:	8d 64 24 fc          	lea    -0x4(%esp),%esp
    ret
  8003c8:	c3                   	ret    

008003c9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003c9:	f3 0f 1e fb          	endbr32 
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003d2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003d5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003db:	e8 6c fd ff ff       	call   80014c <sys_getenvid>
  8003e0:	83 ec 0c             	sub    $0xc,%esp
  8003e3:	ff 75 0c             	pushl  0xc(%ebp)
  8003e6:	ff 75 08             	pushl  0x8(%ebp)
  8003e9:	56                   	push   %esi
  8003ea:	50                   	push   %eax
  8003eb:	68 58 11 80 00       	push   $0x801158
  8003f0:	e8 bb 00 00 00       	call   8004b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f5:	83 c4 18             	add    $0x18,%esp
  8003f8:	53                   	push   %ebx
  8003f9:	ff 75 10             	pushl  0x10(%ebp)
  8003fc:	e8 5a 00 00 00       	call   80045b <vcprintf>
	cprintf("\n");
  800401:	c7 04 24 8c 14 80 00 	movl   $0x80148c,(%esp)
  800408:	e8 a3 00 00 00       	call   8004b0 <cprintf>
  80040d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800410:	cc                   	int3   
  800411:	eb fd                	jmp    800410 <_panic+0x47>

00800413 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800413:	f3 0f 1e fb          	endbr32 
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	53                   	push   %ebx
  80041b:	83 ec 04             	sub    $0x4,%esp
  80041e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800421:	8b 13                	mov    (%ebx),%edx
  800423:	8d 42 01             	lea    0x1(%edx),%eax
  800426:	89 03                	mov    %eax,(%ebx)
  800428:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80042f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800434:	74 09                	je     80043f <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800436:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80043a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80043d:	c9                   	leave  
  80043e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	68 ff 00 00 00       	push   $0xff
  800447:	8d 43 08             	lea    0x8(%ebx),%eax
  80044a:	50                   	push   %eax
  80044b:	e8 72 fc ff ff       	call   8000c2 <sys_cputs>
		b->idx = 0;
  800450:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	eb db                	jmp    800436 <putch+0x23>

0080045b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80045b:	f3 0f 1e fb          	endbr32 
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800468:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80046f:	00 00 00 
	b.cnt = 0;
  800472:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800479:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80047c:	ff 75 0c             	pushl  0xc(%ebp)
  80047f:	ff 75 08             	pushl  0x8(%ebp)
  800482:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800488:	50                   	push   %eax
  800489:	68 13 04 80 00       	push   $0x800413
  80048e:	e8 20 01 00 00       	call   8005b3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800493:	83 c4 08             	add    $0x8,%esp
  800496:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80049c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	e8 1a fc ff ff       	call   8000c2 <sys_cputs>

	return b.cnt;
}
  8004a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004b0:	f3 0f 1e fb          	endbr32 
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004bd:	50                   	push   %eax
  8004be:	ff 75 08             	pushl  0x8(%ebp)
  8004c1:	e8 95 ff ff ff       	call   80045b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004c6:	c9                   	leave  
  8004c7:	c3                   	ret    

008004c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	57                   	push   %edi
  8004cc:	56                   	push   %esi
  8004cd:	53                   	push   %ebx
  8004ce:	83 ec 1c             	sub    $0x1c,%esp
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 d6                	mov    %edx,%esi
  8004d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004db:	89 d1                	mov    %edx,%ecx
  8004dd:	89 c2                	mov    %eax,%edx
  8004df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f5:	39 c2                	cmp    %eax,%edx
  8004f7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004fa:	72 3e                	jb     80053a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004fc:	83 ec 0c             	sub    $0xc,%esp
  8004ff:	ff 75 18             	pushl  0x18(%ebp)
  800502:	83 eb 01             	sub    $0x1,%ebx
  800505:	53                   	push   %ebx
  800506:	50                   	push   %eax
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80050d:	ff 75 e0             	pushl  -0x20(%ebp)
  800510:	ff 75 dc             	pushl  -0x24(%ebp)
  800513:	ff 75 d8             	pushl  -0x28(%ebp)
  800516:	e8 95 09 00 00       	call   800eb0 <__udivdi3>
  80051b:	83 c4 18             	add    $0x18,%esp
  80051e:	52                   	push   %edx
  80051f:	50                   	push   %eax
  800520:	89 f2                	mov    %esi,%edx
  800522:	89 f8                	mov    %edi,%eax
  800524:	e8 9f ff ff ff       	call   8004c8 <printnum>
  800529:	83 c4 20             	add    $0x20,%esp
  80052c:	eb 13                	jmp    800541 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	56                   	push   %esi
  800532:	ff 75 18             	pushl  0x18(%ebp)
  800535:	ff d7                	call   *%edi
  800537:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80053a:	83 eb 01             	sub    $0x1,%ebx
  80053d:	85 db                	test   %ebx,%ebx
  80053f:	7f ed                	jg     80052e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	56                   	push   %esi
  800545:	83 ec 04             	sub    $0x4,%esp
  800548:	ff 75 e4             	pushl  -0x1c(%ebp)
  80054b:	ff 75 e0             	pushl  -0x20(%ebp)
  80054e:	ff 75 dc             	pushl  -0x24(%ebp)
  800551:	ff 75 d8             	pushl  -0x28(%ebp)
  800554:	e8 67 0a 00 00       	call   800fc0 <__umoddi3>
  800559:	83 c4 14             	add    $0x14,%esp
  80055c:	0f be 80 7b 11 80 00 	movsbl 0x80117b(%eax),%eax
  800563:	50                   	push   %eax
  800564:	ff d7                	call   *%edi
}
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80056c:	5b                   	pop    %ebx
  80056d:	5e                   	pop    %esi
  80056e:	5f                   	pop    %edi
  80056f:	5d                   	pop    %ebp
  800570:	c3                   	ret    

00800571 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800571:	f3 0f 1e fb          	endbr32 
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80057b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80057f:	8b 10                	mov    (%eax),%edx
  800581:	3b 50 04             	cmp    0x4(%eax),%edx
  800584:	73 0a                	jae    800590 <sprintputch+0x1f>
		*b->buf++ = ch;
  800586:	8d 4a 01             	lea    0x1(%edx),%ecx
  800589:	89 08                	mov    %ecx,(%eax)
  80058b:	8b 45 08             	mov    0x8(%ebp),%eax
  80058e:	88 02                	mov    %al,(%edx)
}
  800590:	5d                   	pop    %ebp
  800591:	c3                   	ret    

00800592 <printfmt>:
{
  800592:	f3 0f 1e fb          	endbr32 
  800596:	55                   	push   %ebp
  800597:	89 e5                	mov    %esp,%ebp
  800599:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80059c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80059f:	50                   	push   %eax
  8005a0:	ff 75 10             	pushl  0x10(%ebp)
  8005a3:	ff 75 0c             	pushl  0xc(%ebp)
  8005a6:	ff 75 08             	pushl  0x8(%ebp)
  8005a9:	e8 05 00 00 00       	call   8005b3 <vprintfmt>
}
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	c9                   	leave  
  8005b2:	c3                   	ret    

008005b3 <vprintfmt>:
{
  8005b3:	f3 0f 1e fb          	endbr32 
  8005b7:	55                   	push   %ebp
  8005b8:	89 e5                	mov    %esp,%ebp
  8005ba:	57                   	push   %edi
  8005bb:	56                   	push   %esi
  8005bc:	53                   	push   %ebx
  8005bd:	83 ec 3c             	sub    $0x3c,%esp
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005c9:	e9 4a 03 00 00       	jmp    800918 <vprintfmt+0x365>
		padc = ' ';
  8005ce:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005d2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005d9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8d 47 01             	lea    0x1(%edi),%eax
  8005ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f2:	0f b6 17             	movzbl (%edi),%edx
  8005f5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005f8:	3c 55                	cmp    $0x55,%al
  8005fa:	0f 87 de 03 00 00    	ja     8009de <vprintfmt+0x42b>
  800600:	0f b6 c0             	movzbl %al,%eax
  800603:	3e ff 24 85 c0 12 80 	notrack jmp *0x8012c0(,%eax,4)
  80060a:	00 
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80060e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800612:	eb d8                	jmp    8005ec <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800617:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80061b:	eb cf                	jmp    8005ec <vprintfmt+0x39>
  80061d:	0f b6 d2             	movzbl %dl,%edx
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800623:	b8 00 00 00 00       	mov    $0x0,%eax
  800628:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80062b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80062e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800632:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800635:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800638:	83 f9 09             	cmp    $0x9,%ecx
  80063b:	77 55                	ja     800692 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80063d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800640:	eb e9                	jmp    80062b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800656:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065a:	79 90                	jns    8005ec <vprintfmt+0x39>
				width = precision, precision = -1;
  80065c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800662:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800669:	eb 81                	jmp    8005ec <vprintfmt+0x39>
  80066b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066e:	85 c0                	test   %eax,%eax
  800670:	ba 00 00 00 00       	mov    $0x0,%edx
  800675:	0f 49 d0             	cmovns %eax,%edx
  800678:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80067e:	e9 69 ff ff ff       	jmp    8005ec <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800686:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80068d:	e9 5a ff ff ff       	jmp    8005ec <vprintfmt+0x39>
  800692:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800695:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800698:	eb bc                	jmp    800656 <vprintfmt+0xa3>
			lflag++;
  80069a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80069d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006a0:	e9 47 ff ff ff       	jmp    8005ec <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 78 04             	lea    0x4(%eax),%edi
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	ff 30                	pushl  (%eax)
  8006b1:	ff d6                	call   *%esi
			break;
  8006b3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006b6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006b9:	e9 57 02 00 00       	jmp    800915 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 78 04             	lea    0x4(%eax),%edi
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	99                   	cltd   
  8006c7:	31 d0                	xor    %edx,%eax
  8006c9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006cb:	83 f8 0f             	cmp    $0xf,%eax
  8006ce:	7f 23                	jg     8006f3 <vprintfmt+0x140>
  8006d0:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	74 18                	je     8006f3 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8006db:	52                   	push   %edx
  8006dc:	68 9c 11 80 00       	push   $0x80119c
  8006e1:	53                   	push   %ebx
  8006e2:	56                   	push   %esi
  8006e3:	e8 aa fe ff ff       	call   800592 <printfmt>
  8006e8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006eb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006ee:	e9 22 02 00 00       	jmp    800915 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006f3:	50                   	push   %eax
  8006f4:	68 93 11 80 00       	push   $0x801193
  8006f9:	53                   	push   %ebx
  8006fa:	56                   	push   %esi
  8006fb:	e8 92 fe ff ff       	call   800592 <printfmt>
  800700:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800703:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800706:	e9 0a 02 00 00       	jmp    800915 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	83 c0 04             	add    $0x4,%eax
  800711:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800719:	85 d2                	test   %edx,%edx
  80071b:	b8 8c 11 80 00       	mov    $0x80118c,%eax
  800720:	0f 45 c2             	cmovne %edx,%eax
  800723:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800726:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80072a:	7e 06                	jle    800732 <vprintfmt+0x17f>
  80072c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800730:	75 0d                	jne    80073f <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800732:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800735:	89 c7                	mov    %eax,%edi
  800737:	03 45 e0             	add    -0x20(%ebp),%eax
  80073a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80073d:	eb 55                	jmp    800794 <vprintfmt+0x1e1>
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	ff 75 d8             	pushl  -0x28(%ebp)
  800745:	ff 75 cc             	pushl  -0x34(%ebp)
  800748:	e8 45 03 00 00       	call   800a92 <strnlen>
  80074d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800750:	29 c2                	sub    %eax,%edx
  800752:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80075a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80075e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800761:	85 ff                	test   %edi,%edi
  800763:	7e 11                	jle    800776 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	ff 75 e0             	pushl  -0x20(%ebp)
  80076c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80076e:	83 ef 01             	sub    $0x1,%edi
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	eb eb                	jmp    800761 <vprintfmt+0x1ae>
  800776:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800779:	85 d2                	test   %edx,%edx
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
  800780:	0f 49 c2             	cmovns %edx,%eax
  800783:	29 c2                	sub    %eax,%edx
  800785:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800788:	eb a8                	jmp    800732 <vprintfmt+0x17f>
					putch(ch, putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	52                   	push   %edx
  80078f:	ff d6                	call   *%esi
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800797:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800799:	83 c7 01             	add    $0x1,%edi
  80079c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a0:	0f be d0             	movsbl %al,%edx
  8007a3:	85 d2                	test   %edx,%edx
  8007a5:	74 4b                	je     8007f2 <vprintfmt+0x23f>
  8007a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ab:	78 06                	js     8007b3 <vprintfmt+0x200>
  8007ad:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8007b1:	78 1e                	js     8007d1 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007b7:	74 d1                	je     80078a <vprintfmt+0x1d7>
  8007b9:	0f be c0             	movsbl %al,%eax
  8007bc:	83 e8 20             	sub    $0x20,%eax
  8007bf:	83 f8 5e             	cmp    $0x5e,%eax
  8007c2:	76 c6                	jbe    80078a <vprintfmt+0x1d7>
					putch('?', putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	6a 3f                	push   $0x3f
  8007ca:	ff d6                	call   *%esi
  8007cc:	83 c4 10             	add    $0x10,%esp
  8007cf:	eb c3                	jmp    800794 <vprintfmt+0x1e1>
  8007d1:	89 cf                	mov    %ecx,%edi
  8007d3:	eb 0e                	jmp    8007e3 <vprintfmt+0x230>
				putch(' ', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	53                   	push   %ebx
  8007d9:	6a 20                	push   $0x20
  8007db:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007dd:	83 ef 01             	sub    $0x1,%edi
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 ff                	test   %edi,%edi
  8007e5:	7f ee                	jg     8007d5 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007e7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ed:	e9 23 01 00 00       	jmp    800915 <vprintfmt+0x362>
  8007f2:	89 cf                	mov    %ecx,%edi
  8007f4:	eb ed                	jmp    8007e3 <vprintfmt+0x230>
	if (lflag >= 2)
  8007f6:	83 f9 01             	cmp    $0x1,%ecx
  8007f9:	7f 1b                	jg     800816 <vprintfmt+0x263>
	else if (lflag)
  8007fb:	85 c9                	test   %ecx,%ecx
  8007fd:	74 63                	je     800862 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800807:	99                   	cltd   
  800808:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 40 04             	lea    0x4(%eax),%eax
  800811:	89 45 14             	mov    %eax,0x14(%ebp)
  800814:	eb 17                	jmp    80082d <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8b 50 04             	mov    0x4(%eax),%edx
  80081c:	8b 00                	mov    (%eax),%eax
  80081e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800821:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8d 40 08             	lea    0x8(%eax),%eax
  80082a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80082d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800830:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800833:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800838:	85 c9                	test   %ecx,%ecx
  80083a:	0f 89 bb 00 00 00    	jns    8008fb <vprintfmt+0x348>
				putch('-', putdat);
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	53                   	push   %ebx
  800844:	6a 2d                	push   $0x2d
  800846:	ff d6                	call   *%esi
				num = -(long long) num;
  800848:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80084b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80084e:	f7 da                	neg    %edx
  800850:	83 d1 00             	adc    $0x0,%ecx
  800853:	f7 d9                	neg    %ecx
  800855:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800858:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085d:	e9 99 00 00 00       	jmp    8008fb <vprintfmt+0x348>
		return va_arg(*ap, int);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8b 00                	mov    (%eax),%eax
  800867:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80086a:	99                   	cltd   
  80086b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8d 40 04             	lea    0x4(%eax),%eax
  800874:	89 45 14             	mov    %eax,0x14(%ebp)
  800877:	eb b4                	jmp    80082d <vprintfmt+0x27a>
	if (lflag >= 2)
  800879:	83 f9 01             	cmp    $0x1,%ecx
  80087c:	7f 1b                	jg     800899 <vprintfmt+0x2e6>
	else if (lflag)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 2c                	je     8008ae <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8b 10                	mov    (%eax),%edx
  800887:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088c:	8d 40 04             	lea    0x4(%eax),%eax
  80088f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800892:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800897:	eb 62                	jmp    8008fb <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8b 10                	mov    (%eax),%edx
  80089e:	8b 48 04             	mov    0x4(%eax),%ecx
  8008a1:	8d 40 08             	lea    0x8(%eax),%eax
  8008a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008a7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8008ac:	eb 4d                	jmp    8008fb <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8b 10                	mov    (%eax),%edx
  8008b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b8:	8d 40 04             	lea    0x4(%eax),%eax
  8008bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008be:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8008c3:	eb 36                	jmp    8008fb <vprintfmt+0x348>
	if (lflag >= 2)
  8008c5:	83 f9 01             	cmp    $0x1,%ecx
  8008c8:	7f 17                	jg     8008e1 <vprintfmt+0x32e>
	else if (lflag)
  8008ca:	85 c9                	test   %ecx,%ecx
  8008cc:	74 6e                	je     80093c <vprintfmt+0x389>
		return va_arg(*ap, long);
  8008ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d1:	8b 10                	mov    (%eax),%edx
  8008d3:	89 d0                	mov    %edx,%eax
  8008d5:	99                   	cltd   
  8008d6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008d9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008dc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008df:	eb 11                	jmp    8008f2 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e4:	8b 50 04             	mov    0x4(%eax),%edx
  8008e7:	8b 00                	mov    (%eax),%eax
  8008e9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008ec:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008ef:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008f2:	89 d1                	mov    %edx,%ecx
  8008f4:	89 c2                	mov    %eax,%edx
            base = 8;
  8008f6:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008fb:	83 ec 0c             	sub    $0xc,%esp
  8008fe:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800902:	57                   	push   %edi
  800903:	ff 75 e0             	pushl  -0x20(%ebp)
  800906:	50                   	push   %eax
  800907:	51                   	push   %ecx
  800908:	52                   	push   %edx
  800909:	89 da                	mov    %ebx,%edx
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	e8 b6 fb ff ff       	call   8004c8 <printnum>
			break;
  800912:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800915:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800918:	83 c7 01             	add    $0x1,%edi
  80091b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80091f:	83 f8 25             	cmp    $0x25,%eax
  800922:	0f 84 a6 fc ff ff    	je     8005ce <vprintfmt+0x1b>
			if (ch == '\0')
  800928:	85 c0                	test   %eax,%eax
  80092a:	0f 84 ce 00 00 00    	je     8009fe <vprintfmt+0x44b>
			putch(ch, putdat);
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	53                   	push   %ebx
  800934:	50                   	push   %eax
  800935:	ff d6                	call   *%esi
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	eb dc                	jmp    800918 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80093c:	8b 45 14             	mov    0x14(%ebp),%eax
  80093f:	8b 10                	mov    (%eax),%edx
  800941:	89 d0                	mov    %edx,%eax
  800943:	99                   	cltd   
  800944:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800947:	8d 49 04             	lea    0x4(%ecx),%ecx
  80094a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80094d:	eb a3                	jmp    8008f2 <vprintfmt+0x33f>
			putch('0', putdat);
  80094f:	83 ec 08             	sub    $0x8,%esp
  800952:	53                   	push   %ebx
  800953:	6a 30                	push   $0x30
  800955:	ff d6                	call   *%esi
			putch('x', putdat);
  800957:	83 c4 08             	add    $0x8,%esp
  80095a:	53                   	push   %ebx
  80095b:	6a 78                	push   $0x78
  80095d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	8b 10                	mov    (%eax),%edx
  800964:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800969:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80096c:	8d 40 04             	lea    0x4(%eax),%eax
  80096f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800972:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800977:	eb 82                	jmp    8008fb <vprintfmt+0x348>
	if (lflag >= 2)
  800979:	83 f9 01             	cmp    $0x1,%ecx
  80097c:	7f 1e                	jg     80099c <vprintfmt+0x3e9>
	else if (lflag)
  80097e:	85 c9                	test   %ecx,%ecx
  800980:	74 32                	je     8009b4 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8b 10                	mov    (%eax),%edx
  800987:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098c:	8d 40 04             	lea    0x4(%eax),%eax
  80098f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800992:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800997:	e9 5f ff ff ff       	jmp    8008fb <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80099c:	8b 45 14             	mov    0x14(%ebp),%eax
  80099f:	8b 10                	mov    (%eax),%edx
  8009a1:	8b 48 04             	mov    0x4(%eax),%ecx
  8009a4:	8d 40 08             	lea    0x8(%eax),%eax
  8009a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009aa:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8009af:	e9 47 ff ff ff       	jmp    8008fb <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8009b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b7:	8b 10                	mov    (%eax),%edx
  8009b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009be:	8d 40 04             	lea    0x4(%eax),%eax
  8009c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009c4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8009c9:	e9 2d ff ff ff       	jmp    8008fb <vprintfmt+0x348>
			putch(ch, putdat);
  8009ce:	83 ec 08             	sub    $0x8,%esp
  8009d1:	53                   	push   %ebx
  8009d2:	6a 25                	push   $0x25
  8009d4:	ff d6                	call   *%esi
			break;
  8009d6:	83 c4 10             	add    $0x10,%esp
  8009d9:	e9 37 ff ff ff       	jmp    800915 <vprintfmt+0x362>
			putch('%', putdat);
  8009de:	83 ec 08             	sub    $0x8,%esp
  8009e1:	53                   	push   %ebx
  8009e2:	6a 25                	push   $0x25
  8009e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	89 f8                	mov    %edi,%eax
  8009eb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009ef:	74 05                	je     8009f6 <vprintfmt+0x443>
  8009f1:	83 e8 01             	sub    $0x1,%eax
  8009f4:	eb f5                	jmp    8009eb <vprintfmt+0x438>
  8009f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009f9:	e9 17 ff ff ff       	jmp    800915 <vprintfmt+0x362>
}
  8009fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5f                   	pop    %edi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a06:	f3 0f 1e fb          	endbr32 
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 18             	sub    $0x18,%esp
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a19:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a1d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a27:	85 c0                	test   %eax,%eax
  800a29:	74 26                	je     800a51 <vsnprintf+0x4b>
  800a2b:	85 d2                	test   %edx,%edx
  800a2d:	7e 22                	jle    800a51 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a2f:	ff 75 14             	pushl  0x14(%ebp)
  800a32:	ff 75 10             	pushl  0x10(%ebp)
  800a35:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a38:	50                   	push   %eax
  800a39:	68 71 05 80 00       	push   $0x800571
  800a3e:	e8 70 fb ff ff       	call   8005b3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a46:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a4c:	83 c4 10             	add    $0x10,%esp
}
  800a4f:	c9                   	leave  
  800a50:	c3                   	ret    
		return -E_INVAL;
  800a51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a56:	eb f7                	jmp    800a4f <vsnprintf+0x49>

00800a58 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a58:	f3 0f 1e fb          	endbr32 
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a62:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a65:	50                   	push   %eax
  800a66:	ff 75 10             	pushl  0x10(%ebp)
  800a69:	ff 75 0c             	pushl  0xc(%ebp)
  800a6c:	ff 75 08             	pushl  0x8(%ebp)
  800a6f:	e8 92 ff ff ff       	call   800a06 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a76:	f3 0f 1e fb          	endbr32 
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
  800a85:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a89:	74 05                	je     800a90 <strlen+0x1a>
		n++;
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	eb f5                	jmp    800a85 <strlen+0xf>
	return n;
}
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a92:	f3 0f 1e fb          	endbr32 
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	74 0d                	je     800ab5 <strnlen+0x23>
  800aa8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aac:	74 05                	je     800ab3 <strnlen+0x21>
		n++;
  800aae:	83 c0 01             	add    $0x1,%eax
  800ab1:	eb f1                	jmp    800aa4 <strnlen+0x12>
  800ab3:	89 c2                	mov    %eax,%edx
	return n;
}
  800ab5:	89 d0                	mov    %edx,%eax
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ab9:	f3 0f 1e fb          	endbr32 
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	53                   	push   %ebx
  800ac1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800ad0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	84 d2                	test   %dl,%dl
  800ad8:	75 f2                	jne    800acc <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800ada:	89 c8                	mov    %ecx,%eax
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strcat>:

char *
strcat(char *dst, const char *src)
{
  800adf:	f3 0f 1e fb          	endbr32 
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 10             	sub    $0x10,%esp
  800aea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aed:	53                   	push   %ebx
  800aee:	e8 83 ff ff ff       	call   800a76 <strlen>
  800af3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	01 d8                	add    %ebx,%eax
  800afb:	50                   	push   %eax
  800afc:	e8 b8 ff ff ff       	call   800ab9 <strcpy>
	return dst;
}
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b06:	c9                   	leave  
  800b07:	c3                   	ret    

00800b08 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b08:	f3 0f 1e fb          	endbr32 
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 75 08             	mov    0x8(%ebp),%esi
  800b14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b17:	89 f3                	mov    %esi,%ebx
  800b19:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b1c:	89 f0                	mov    %esi,%eax
  800b1e:	39 d8                	cmp    %ebx,%eax
  800b20:	74 11                	je     800b33 <strncpy+0x2b>
		*dst++ = *src;
  800b22:	83 c0 01             	add    $0x1,%eax
  800b25:	0f b6 0a             	movzbl (%edx),%ecx
  800b28:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b2b:	80 f9 01             	cmp    $0x1,%cl
  800b2e:	83 da ff             	sbb    $0xffffffff,%edx
  800b31:	eb eb                	jmp    800b1e <strncpy+0x16>
	}
	return ret;
}
  800b33:	89 f0                	mov    %esi,%eax
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b39:	f3 0f 1e fb          	endbr32 
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 75 08             	mov    0x8(%ebp),%esi
  800b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b48:	8b 55 10             	mov    0x10(%ebp),%edx
  800b4b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b4d:	85 d2                	test   %edx,%edx
  800b4f:	74 21                	je     800b72 <strlcpy+0x39>
  800b51:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b55:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b57:	39 c2                	cmp    %eax,%edx
  800b59:	74 14                	je     800b6f <strlcpy+0x36>
  800b5b:	0f b6 19             	movzbl (%ecx),%ebx
  800b5e:	84 db                	test   %bl,%bl
  800b60:	74 0b                	je     800b6d <strlcpy+0x34>
			*dst++ = *src++;
  800b62:	83 c1 01             	add    $0x1,%ecx
  800b65:	83 c2 01             	add    $0x1,%edx
  800b68:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b6b:	eb ea                	jmp    800b57 <strlcpy+0x1e>
  800b6d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b6f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b72:	29 f0                	sub    %esi,%eax
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b78:	f3 0f 1e fb          	endbr32 
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b85:	0f b6 01             	movzbl (%ecx),%eax
  800b88:	84 c0                	test   %al,%al
  800b8a:	74 0c                	je     800b98 <strcmp+0x20>
  800b8c:	3a 02                	cmp    (%edx),%al
  800b8e:	75 08                	jne    800b98 <strcmp+0x20>
		p++, q++;
  800b90:	83 c1 01             	add    $0x1,%ecx
  800b93:	83 c2 01             	add    $0x1,%edx
  800b96:	eb ed                	jmp    800b85 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b98:	0f b6 c0             	movzbl %al,%eax
  800b9b:	0f b6 12             	movzbl (%edx),%edx
  800b9e:	29 d0                	sub    %edx,%eax
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	53                   	push   %ebx
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb0:	89 c3                	mov    %eax,%ebx
  800bb2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bb5:	eb 06                	jmp    800bbd <strncmp+0x1b>
		n--, p++, q++;
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800bbd:	39 d8                	cmp    %ebx,%eax
  800bbf:	74 16                	je     800bd7 <strncmp+0x35>
  800bc1:	0f b6 08             	movzbl (%eax),%ecx
  800bc4:	84 c9                	test   %cl,%cl
  800bc6:	74 04                	je     800bcc <strncmp+0x2a>
  800bc8:	3a 0a                	cmp    (%edx),%cl
  800bca:	74 eb                	je     800bb7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bcc:	0f b6 00             	movzbl (%eax),%eax
  800bcf:	0f b6 12             	movzbl (%edx),%edx
  800bd2:	29 d0                	sub    %edx,%eax
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    
		return 0;
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	eb f6                	jmp    800bd4 <strncmp+0x32>

00800bde <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bde:	f3 0f 1e fb          	endbr32 
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bec:	0f b6 10             	movzbl (%eax),%edx
  800bef:	84 d2                	test   %dl,%dl
  800bf1:	74 09                	je     800bfc <strchr+0x1e>
		if (*s == c)
  800bf3:	38 ca                	cmp    %cl,%dl
  800bf5:	74 0a                	je     800c01 <strchr+0x23>
	for (; *s; s++)
  800bf7:	83 c0 01             	add    $0x1,%eax
  800bfa:	eb f0                	jmp    800bec <strchr+0xe>
			return (char *) s;
	return 0;
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c03:	f3 0f 1e fb          	endbr32 
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c11:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c14:	38 ca                	cmp    %cl,%dl
  800c16:	74 09                	je     800c21 <strfind+0x1e>
  800c18:	84 d2                	test   %dl,%dl
  800c1a:	74 05                	je     800c21 <strfind+0x1e>
	for (; *s; s++)
  800c1c:	83 c0 01             	add    $0x1,%eax
  800c1f:	eb f0                	jmp    800c11 <strfind+0xe>
			break;
	return (char *) s;
}
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c23:	f3 0f 1e fb          	endbr32 
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c33:	85 c9                	test   %ecx,%ecx
  800c35:	74 31                	je     800c68 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c37:	89 f8                	mov    %edi,%eax
  800c39:	09 c8                	or     %ecx,%eax
  800c3b:	a8 03                	test   $0x3,%al
  800c3d:	75 23                	jne    800c62 <memset+0x3f>
		c &= 0xFF;
  800c3f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c43:	89 d3                	mov    %edx,%ebx
  800c45:	c1 e3 08             	shl    $0x8,%ebx
  800c48:	89 d0                	mov    %edx,%eax
  800c4a:	c1 e0 18             	shl    $0x18,%eax
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	c1 e6 10             	shl    $0x10,%esi
  800c52:	09 f0                	or     %esi,%eax
  800c54:	09 c2                	or     %eax,%edx
  800c56:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c58:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c5b:	89 d0                	mov    %edx,%eax
  800c5d:	fc                   	cld    
  800c5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c60:	eb 06                	jmp    800c68 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c65:	fc                   	cld    
  800c66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c68:	89 f8                	mov    %edi,%eax
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6f:	f3 0f 1e fb          	endbr32 
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c81:	39 c6                	cmp    %eax,%esi
  800c83:	73 32                	jae    800cb7 <memmove+0x48>
  800c85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c88:	39 c2                	cmp    %eax,%edx
  800c8a:	76 2b                	jbe    800cb7 <memmove+0x48>
		s += n;
		d += n;
  800c8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8f:	89 fe                	mov    %edi,%esi
  800c91:	09 ce                	or     %ecx,%esi
  800c93:	09 d6                	or     %edx,%esi
  800c95:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c9b:	75 0e                	jne    800cab <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c9d:	83 ef 04             	sub    $0x4,%edi
  800ca0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ca6:	fd                   	std    
  800ca7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca9:	eb 09                	jmp    800cb4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cab:	83 ef 01             	sub    $0x1,%edi
  800cae:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cb1:	fd                   	std    
  800cb2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb4:	fc                   	cld    
  800cb5:	eb 1a                	jmp    800cd1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb7:	89 c2                	mov    %eax,%edx
  800cb9:	09 ca                	or     %ecx,%edx
  800cbb:	09 f2                	or     %esi,%edx
  800cbd:	f6 c2 03             	test   $0x3,%dl
  800cc0:	75 0a                	jne    800ccc <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cc2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800cc5:	89 c7                	mov    %eax,%edi
  800cc7:	fc                   	cld    
  800cc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cca:	eb 05                	jmp    800cd1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ccc:	89 c7                	mov    %eax,%edi
  800cce:	fc                   	cld    
  800ccf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cd5:	f3 0f 1e fb          	endbr32 
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cdf:	ff 75 10             	pushl  0x10(%ebp)
  800ce2:	ff 75 0c             	pushl  0xc(%ebp)
  800ce5:	ff 75 08             	pushl  0x8(%ebp)
  800ce8:	e8 82 ff ff ff       	call   800c6f <memmove>
}
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cef:	f3 0f 1e fb          	endbr32 
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfe:	89 c6                	mov    %eax,%esi
  800d00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d03:	39 f0                	cmp    %esi,%eax
  800d05:	74 1c                	je     800d23 <memcmp+0x34>
		if (*s1 != *s2)
  800d07:	0f b6 08             	movzbl (%eax),%ecx
  800d0a:	0f b6 1a             	movzbl (%edx),%ebx
  800d0d:	38 d9                	cmp    %bl,%cl
  800d0f:	75 08                	jne    800d19 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d11:	83 c0 01             	add    $0x1,%eax
  800d14:	83 c2 01             	add    $0x1,%edx
  800d17:	eb ea                	jmp    800d03 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800d19:	0f b6 c1             	movzbl %cl,%eax
  800d1c:	0f b6 db             	movzbl %bl,%ebx
  800d1f:	29 d8                	sub    %ebx,%eax
  800d21:	eb 05                	jmp    800d28 <memcmp+0x39>
	}

	return 0;
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d2c:	f3 0f 1e fb          	endbr32 
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d39:	89 c2                	mov    %eax,%edx
  800d3b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d3e:	39 d0                	cmp    %edx,%eax
  800d40:	73 09                	jae    800d4b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d42:	38 08                	cmp    %cl,(%eax)
  800d44:	74 05                	je     800d4b <memfind+0x1f>
	for (; s < ends; s++)
  800d46:	83 c0 01             	add    $0x1,%eax
  800d49:	eb f3                	jmp    800d3e <memfind+0x12>
			break;
	return (void *) s;
}
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d4d:	f3 0f 1e fb          	endbr32 
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5d:	eb 03                	jmp    800d62 <strtol+0x15>
		s++;
  800d5f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d62:	0f b6 01             	movzbl (%ecx),%eax
  800d65:	3c 20                	cmp    $0x20,%al
  800d67:	74 f6                	je     800d5f <strtol+0x12>
  800d69:	3c 09                	cmp    $0x9,%al
  800d6b:	74 f2                	je     800d5f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d6d:	3c 2b                	cmp    $0x2b,%al
  800d6f:	74 2a                	je     800d9b <strtol+0x4e>
	int neg = 0;
  800d71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d76:	3c 2d                	cmp    $0x2d,%al
  800d78:	74 2b                	je     800da5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d80:	75 0f                	jne    800d91 <strtol+0x44>
  800d82:	80 39 30             	cmpb   $0x30,(%ecx)
  800d85:	74 28                	je     800daf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d87:	85 db                	test   %ebx,%ebx
  800d89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8e:	0f 44 d8             	cmove  %eax,%ebx
  800d91:	b8 00 00 00 00       	mov    $0x0,%eax
  800d96:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d99:	eb 46                	jmp    800de1 <strtol+0x94>
		s++;
  800d9b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800da3:	eb d5                	jmp    800d7a <strtol+0x2d>
		s++, neg = 1;
  800da5:	83 c1 01             	add    $0x1,%ecx
  800da8:	bf 01 00 00 00       	mov    $0x1,%edi
  800dad:	eb cb                	jmp    800d7a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800daf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800db3:	74 0e                	je     800dc3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800db5:	85 db                	test   %ebx,%ebx
  800db7:	75 d8                	jne    800d91 <strtol+0x44>
		s++, base = 8;
  800db9:	83 c1 01             	add    $0x1,%ecx
  800dbc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800dc1:	eb ce                	jmp    800d91 <strtol+0x44>
		s += 2, base = 16;
  800dc3:	83 c1 02             	add    $0x2,%ecx
  800dc6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dcb:	eb c4                	jmp    800d91 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800dcd:	0f be d2             	movsbl %dl,%edx
  800dd0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800dd3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dd6:	7d 3a                	jge    800e12 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800dd8:	83 c1 01             	add    $0x1,%ecx
  800ddb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ddf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800de1:	0f b6 11             	movzbl (%ecx),%edx
  800de4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800de7:	89 f3                	mov    %esi,%ebx
  800de9:	80 fb 09             	cmp    $0x9,%bl
  800dec:	76 df                	jbe    800dcd <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dee:	8d 72 9f             	lea    -0x61(%edx),%esi
  800df1:	89 f3                	mov    %esi,%ebx
  800df3:	80 fb 19             	cmp    $0x19,%bl
  800df6:	77 08                	ja     800e00 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800df8:	0f be d2             	movsbl %dl,%edx
  800dfb:	83 ea 57             	sub    $0x57,%edx
  800dfe:	eb d3                	jmp    800dd3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800e00:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e03:	89 f3                	mov    %esi,%ebx
  800e05:	80 fb 19             	cmp    $0x19,%bl
  800e08:	77 08                	ja     800e12 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e0a:	0f be d2             	movsbl %dl,%edx
  800e0d:	83 ea 37             	sub    $0x37,%edx
  800e10:	eb c1                	jmp    800dd3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e16:	74 05                	je     800e1d <strtol+0xd0>
		*endptr = (char *) s;
  800e18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e1b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e1d:	89 c2                	mov    %eax,%edx
  800e1f:	f7 da                	neg    %edx
  800e21:	85 ff                	test   %edi,%edi
  800e23:	0f 45 c2             	cmovne %edx,%eax
}
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e2b:	f3 0f 1e fb          	endbr32 
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e35:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e3c:	74 0a                	je     800e48 <set_pgfault_handler+0x1d>
        }
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    
        cprintf("UXSTACK alloc\n");
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	68 7f 14 80 00       	push   $0x80147f
  800e50:	e8 5b f6 ff ff       	call   8004b0 <cprintf>
        if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P) < 0) {
  800e55:	83 c4 0c             	add    $0xc,%esp
  800e58:	6a 07                	push   $0x7
  800e5a:	68 00 f0 bf ee       	push   $0xeebff000
  800e5f:	6a 00                	push   $0x0
  800e61:	e8 2c f3 ff ff       	call   800192 <sys_page_alloc>
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 2a                	js     800e97 <set_pgfault_handler+0x6c>
        if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	68 a3 03 80 00       	push   $0x8003a3
  800e75:	6a 00                	push   $0x0
  800e77:	e8 75 f4 ff ff       	call   8002f1 <sys_env_set_pgfault_upcall>
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	79 bb                	jns    800e3e <set_pgfault_handler+0x13>
            panic("sys_env_set_pgfault_upcall failed!");
  800e83:	83 ec 04             	sub    $0x4,%esp
  800e86:	68 bc 14 80 00       	push   $0x8014bc
  800e8b:	6a 25                	push   $0x25
  800e8d:	68 ac 14 80 00       	push   $0x8014ac
  800e92:	e8 32 f5 ff ff       	call   8003c9 <_panic>
            panic("Allocation of UXSTACK failed!");
  800e97:	83 ec 04             	sub    $0x4,%esp
  800e9a:	68 8e 14 80 00       	push   $0x80148e
  800e9f:	6a 22                	push   $0x22
  800ea1:	68 ac 14 80 00       	push   $0x8014ac
  800ea6:	e8 1e f5 ff ff       	call   8003c9 <_panic>
  800eab:	66 90                	xchg   %ax,%ax
  800ead:	66 90                	xchg   %ax,%ax
  800eaf:	90                   	nop

00800eb0 <__udivdi3>:
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 1c             	sub    $0x1c,%esp
  800ebb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ebf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ec3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ec7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ecb:	85 d2                	test   %edx,%edx
  800ecd:	75 19                	jne    800ee8 <__udivdi3+0x38>
  800ecf:	39 f3                	cmp    %esi,%ebx
  800ed1:	76 4d                	jbe    800f20 <__udivdi3+0x70>
  800ed3:	31 ff                	xor    %edi,%edi
  800ed5:	89 e8                	mov    %ebp,%eax
  800ed7:	89 f2                	mov    %esi,%edx
  800ed9:	f7 f3                	div    %ebx
  800edb:	89 fa                	mov    %edi,%edx
  800edd:	83 c4 1c             	add    $0x1c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	76 14                	jbe    800f00 <__udivdi3+0x50>
  800eec:	31 ff                	xor    %edi,%edi
  800eee:	31 c0                	xor    %eax,%eax
  800ef0:	89 fa                	mov    %edi,%edx
  800ef2:	83 c4 1c             	add    $0x1c,%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    
  800efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f00:	0f bd fa             	bsr    %edx,%edi
  800f03:	83 f7 1f             	xor    $0x1f,%edi
  800f06:	75 48                	jne    800f50 <__udivdi3+0xa0>
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	72 06                	jb     800f12 <__udivdi3+0x62>
  800f0c:	31 c0                	xor    %eax,%eax
  800f0e:	39 eb                	cmp    %ebp,%ebx
  800f10:	77 de                	ja     800ef0 <__udivdi3+0x40>
  800f12:	b8 01 00 00 00       	mov    $0x1,%eax
  800f17:	eb d7                	jmp    800ef0 <__udivdi3+0x40>
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d9                	mov    %ebx,%ecx
  800f22:	85 db                	test   %ebx,%ebx
  800f24:	75 0b                	jne    800f31 <__udivdi3+0x81>
  800f26:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	f7 f3                	div    %ebx
  800f2f:	89 c1                	mov    %eax,%ecx
  800f31:	31 d2                	xor    %edx,%edx
  800f33:	89 f0                	mov    %esi,%eax
  800f35:	f7 f1                	div    %ecx
  800f37:	89 c6                	mov    %eax,%esi
  800f39:	89 e8                	mov    %ebp,%eax
  800f3b:	89 f7                	mov    %esi,%edi
  800f3d:	f7 f1                	div    %ecx
  800f3f:	89 fa                	mov    %edi,%edx
  800f41:	83 c4 1c             	add    $0x1c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	89 f9                	mov    %edi,%ecx
  800f52:	b8 20 00 00 00       	mov    $0x20,%eax
  800f57:	29 f8                	sub    %edi,%eax
  800f59:	d3 e2                	shl    %cl,%edx
  800f5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f5f:	89 c1                	mov    %eax,%ecx
  800f61:	89 da                	mov    %ebx,%edx
  800f63:	d3 ea                	shr    %cl,%edx
  800f65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f69:	09 d1                	or     %edx,%ecx
  800f6b:	89 f2                	mov    %esi,%edx
  800f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f71:	89 f9                	mov    %edi,%ecx
  800f73:	d3 e3                	shl    %cl,%ebx
  800f75:	89 c1                	mov    %eax,%ecx
  800f77:	d3 ea                	shr    %cl,%edx
  800f79:	89 f9                	mov    %edi,%ecx
  800f7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f7f:	89 eb                	mov    %ebp,%ebx
  800f81:	d3 e6                	shl    %cl,%esi
  800f83:	89 c1                	mov    %eax,%ecx
  800f85:	d3 eb                	shr    %cl,%ebx
  800f87:	09 de                	or     %ebx,%esi
  800f89:	89 f0                	mov    %esi,%eax
  800f8b:	f7 74 24 08          	divl   0x8(%esp)
  800f8f:	89 d6                	mov    %edx,%esi
  800f91:	89 c3                	mov    %eax,%ebx
  800f93:	f7 64 24 0c          	mull   0xc(%esp)
  800f97:	39 d6                	cmp    %edx,%esi
  800f99:	72 15                	jb     800fb0 <__udivdi3+0x100>
  800f9b:	89 f9                	mov    %edi,%ecx
  800f9d:	d3 e5                	shl    %cl,%ebp
  800f9f:	39 c5                	cmp    %eax,%ebp
  800fa1:	73 04                	jae    800fa7 <__udivdi3+0xf7>
  800fa3:	39 d6                	cmp    %edx,%esi
  800fa5:	74 09                	je     800fb0 <__udivdi3+0x100>
  800fa7:	89 d8                	mov    %ebx,%eax
  800fa9:	31 ff                	xor    %edi,%edi
  800fab:	e9 40 ff ff ff       	jmp    800ef0 <__udivdi3+0x40>
  800fb0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fb3:	31 ff                	xor    %edi,%edi
  800fb5:	e9 36 ff ff ff       	jmp    800ef0 <__udivdi3+0x40>
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__umoddi3>:
  800fc0:	f3 0f 1e fb          	endbr32 
  800fc4:	55                   	push   %ebp
  800fc5:	57                   	push   %edi
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 1c             	sub    $0x1c,%esp
  800fcb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fcf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fd3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fd7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	75 19                	jne    800ff8 <__umoddi3+0x38>
  800fdf:	39 df                	cmp    %ebx,%edi
  800fe1:	76 5d                	jbe    801040 <__umoddi3+0x80>
  800fe3:	89 f0                	mov    %esi,%eax
  800fe5:	89 da                	mov    %ebx,%edx
  800fe7:	f7 f7                	div    %edi
  800fe9:	89 d0                	mov    %edx,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	83 c4 1c             	add    $0x1c,%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    
  800ff5:	8d 76 00             	lea    0x0(%esi),%esi
  800ff8:	89 f2                	mov    %esi,%edx
  800ffa:	39 d8                	cmp    %ebx,%eax
  800ffc:	76 12                	jbe    801010 <__umoddi3+0x50>
  800ffe:	89 f0                	mov    %esi,%eax
  801000:	89 da                	mov    %ebx,%edx
  801002:	83 c4 1c             	add    $0x1c,%esp
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    
  80100a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801010:	0f bd e8             	bsr    %eax,%ebp
  801013:	83 f5 1f             	xor    $0x1f,%ebp
  801016:	75 50                	jne    801068 <__umoddi3+0xa8>
  801018:	39 d8                	cmp    %ebx,%eax
  80101a:	0f 82 e0 00 00 00    	jb     801100 <__umoddi3+0x140>
  801020:	89 d9                	mov    %ebx,%ecx
  801022:	39 f7                	cmp    %esi,%edi
  801024:	0f 86 d6 00 00 00    	jbe    801100 <__umoddi3+0x140>
  80102a:	89 d0                	mov    %edx,%eax
  80102c:	89 ca                	mov    %ecx,%edx
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	89 fd                	mov    %edi,%ebp
  801042:	85 ff                	test   %edi,%edi
  801044:	75 0b                	jne    801051 <__umoddi3+0x91>
  801046:	b8 01 00 00 00       	mov    $0x1,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	f7 f7                	div    %edi
  80104f:	89 c5                	mov    %eax,%ebp
  801051:	89 d8                	mov    %ebx,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f5                	div    %ebp
  801057:	89 f0                	mov    %esi,%eax
  801059:	f7 f5                	div    %ebp
  80105b:	89 d0                	mov    %edx,%eax
  80105d:	31 d2                	xor    %edx,%edx
  80105f:	eb 8c                	jmp    800fed <__umoddi3+0x2d>
  801061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801068:	89 e9                	mov    %ebp,%ecx
  80106a:	ba 20 00 00 00       	mov    $0x20,%edx
  80106f:	29 ea                	sub    %ebp,%edx
  801071:	d3 e0                	shl    %cl,%eax
  801073:	89 44 24 08          	mov    %eax,0x8(%esp)
  801077:	89 d1                	mov    %edx,%ecx
  801079:	89 f8                	mov    %edi,%eax
  80107b:	d3 e8                	shr    %cl,%eax
  80107d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801081:	89 54 24 04          	mov    %edx,0x4(%esp)
  801085:	8b 54 24 04          	mov    0x4(%esp),%edx
  801089:	09 c1                	or     %eax,%ecx
  80108b:	89 d8                	mov    %ebx,%eax
  80108d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801091:	89 e9                	mov    %ebp,%ecx
  801093:	d3 e7                	shl    %cl,%edi
  801095:	89 d1                	mov    %edx,%ecx
  801097:	d3 e8                	shr    %cl,%eax
  801099:	89 e9                	mov    %ebp,%ecx
  80109b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80109f:	d3 e3                	shl    %cl,%ebx
  8010a1:	89 c7                	mov    %eax,%edi
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	89 f0                	mov    %esi,%eax
  8010a7:	d3 e8                	shr    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	89 fa                	mov    %edi,%edx
  8010ad:	d3 e6                	shl    %cl,%esi
  8010af:	09 d8                	or     %ebx,%eax
  8010b1:	f7 74 24 08          	divl   0x8(%esp)
  8010b5:	89 d1                	mov    %edx,%ecx
  8010b7:	89 f3                	mov    %esi,%ebx
  8010b9:	f7 64 24 0c          	mull   0xc(%esp)
  8010bd:	89 c6                	mov    %eax,%esi
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	39 d1                	cmp    %edx,%ecx
  8010c3:	72 06                	jb     8010cb <__umoddi3+0x10b>
  8010c5:	75 10                	jne    8010d7 <__umoddi3+0x117>
  8010c7:	39 c3                	cmp    %eax,%ebx
  8010c9:	73 0c                	jae    8010d7 <__umoddi3+0x117>
  8010cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8010d3:	89 d7                	mov    %edx,%edi
  8010d5:	89 c6                	mov    %eax,%esi
  8010d7:	89 ca                	mov    %ecx,%edx
  8010d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010de:	29 f3                	sub    %esi,%ebx
  8010e0:	19 fa                	sbb    %edi,%edx
  8010e2:	89 d0                	mov    %edx,%eax
  8010e4:	d3 e0                	shl    %cl,%eax
  8010e6:	89 e9                	mov    %ebp,%ecx
  8010e8:	d3 eb                	shr    %cl,%ebx
  8010ea:	d3 ea                	shr    %cl,%edx
  8010ec:	09 d8                	or     %ebx,%eax
  8010ee:	83 c4 1c             	add    $0x1c,%esp
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
  8010f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010fd:	8d 76 00             	lea    0x0(%esi),%esi
  801100:	29 fe                	sub    %edi,%esi
  801102:	19 c3                	sbb    %eax,%ebx
  801104:	89 f2                	mov    %esi,%edx
  801106:	89 d9                	mov    %ebx,%ecx
  801108:	e9 1d ff ff ff       	jmp    80102a <__umoddi3+0x6a>
