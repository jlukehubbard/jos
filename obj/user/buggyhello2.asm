
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003d:	68 00 00 10 00       	push   $0x100000
  800042:	ff 35 00 20 80 00    	pushl  0x802000
  800048:	e8 6f 00 00 00       	call   8000bc <sys_cputs>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800061:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800068:	00 00 00 
    envid_t envid = sys_getenvid();
  80006b:	e8 d6 00 00 00       	call   800146 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x3b>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	f3 0f 1e fb          	endbr32 
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000b0:	6a 00                	push   $0x0
  8000b2:	e8 4a 00 00 00       	call   800101 <sys_env_destroy>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	f3 0f 1e fb          	endbr32 
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d1:	89 c3                	mov    %eax,%ebx
  8000d3:	89 c7                	mov    %eax,%edi
  8000d5:	89 c6                	mov    %eax,%esi
  8000d7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_cgetc>:

int
sys_cgetc(void)
{
  8000de:	f3 0f 1e fb          	endbr32 
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800101:	f3 0f 1e fb          	endbr32 
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	8b 55 08             	mov    0x8(%ebp),%edx
  800116:	b8 03 00 00 00       	mov    $0x3,%eax
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7f 08                	jg     80012f <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	50                   	push   %eax
  800133:	6a 03                	push   $0x3
  800135:	68 78 10 80 00       	push   $0x801078
  80013a:	6a 23                	push   $0x23
  80013c:	68 95 10 80 00       	push   $0x801095
  800141:	e8 57 02 00 00       	call   80039d <_panic>

00800146 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800146:	f3 0f 1e fb          	endbr32 
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800150:	ba 00 00 00 00       	mov    $0x0,%edx
  800155:	b8 02 00 00 00       	mov    $0x2,%eax
  80015a:	89 d1                	mov    %edx,%ecx
  80015c:	89 d3                	mov    %edx,%ebx
  80015e:	89 d7                	mov    %edx,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800164:	5b                   	pop    %ebx
  800165:	5e                   	pop    %esi
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <sys_yield>:

void
sys_yield(void)
{
  800169:	f3 0f 1e fb          	endbr32 
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
	asm volatile("int %1\n"
  800173:	ba 00 00 00 00       	mov    $0x0,%edx
  800178:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017d:	89 d1                	mov    %edx,%ecx
  80017f:	89 d3                	mov    %edx,%ebx
  800181:	89 d7                	mov    %edx,%edi
  800183:	89 d6                	mov    %edx,%esi
  800185:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800187:	5b                   	pop    %ebx
  800188:	5e                   	pop    %esi
  800189:	5f                   	pop    %edi
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018c:	f3 0f 1e fb          	endbr32 
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800199:	be 00 00 00 00       	mov    $0x0,%esi
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	89 f7                	mov    %esi,%edi
  8001ae:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7f 08                	jg     8001bc <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 04                	push   $0x4
  8001c2:	68 78 10 80 00       	push   $0x801078
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 95 10 80 00       	push   $0x801095
  8001ce:	e8 ca 01 00 00       	call   80039d <_panic>

008001d3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d3:	f3 0f 1e fb          	endbr32 
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7f 08                	jg     800202 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5e                   	pop    %esi
  8001ff:	5f                   	pop    %edi
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 05                	push   $0x5
  800208:	68 78 10 80 00       	push   $0x801078
  80020d:	6a 23                	push   $0x23
  80020f:	68 95 10 80 00       	push   $0x801095
  800214:	e8 84 01 00 00       	call   80039d <_panic>

00800219 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800219:	f3 0f 1e fb          	endbr32 
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800231:	b8 06 00 00 00       	mov    $0x6,%eax
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7f 08                	jg     800248 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 06                	push   $0x6
  80024e:	68 78 10 80 00       	push   $0x801078
  800253:	6a 23                	push   $0x23
  800255:	68 95 10 80 00       	push   $0x801095
  80025a:	e8 3e 01 00 00       	call   80039d <_panic>

0080025f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025f:	f3 0f 1e fb          	endbr32 
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	b8 08 00 00 00       	mov    $0x8,%eax
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7f 08                	jg     80028e <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 08                	push   $0x8
  800294:	68 78 10 80 00       	push   $0x801078
  800299:	6a 23                	push   $0x23
  80029b:	68 95 10 80 00       	push   $0x801095
  8002a0:	e8 f8 00 00 00       	call   80039d <_panic>

008002a5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002a5:	f3 0f 1e fb          	endbr32 
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7f 08                	jg     8002d4 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 09                	push   $0x9
  8002da:	68 78 10 80 00       	push   $0x801078
  8002df:	6a 23                	push   $0x23
  8002e1:	68 95 10 80 00       	push   $0x801095
  8002e6:	e8 b2 00 00 00       	call   80039d <_panic>

008002eb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002eb:	f3 0f 1e fb          	endbr32 
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	b8 0a 00 00 00       	mov    $0xa,%eax
  800308:	89 df                	mov    %ebx,%edi
  80030a:	89 de                	mov    %ebx,%esi
  80030c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80030e:	85 c0                	test   %eax,%eax
  800310:	7f 08                	jg     80031a <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	50                   	push   %eax
  80031e:	6a 0a                	push   $0xa
  800320:	68 78 10 80 00       	push   $0x801078
  800325:	6a 23                	push   $0x23
  800327:	68 95 10 80 00       	push   $0x801095
  80032c:	e8 6c 00 00 00       	call   80039d <_panic>

00800331 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800331:	f3 0f 1e fb          	endbr32 
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800341:	b8 0c 00 00 00       	mov    $0xc,%eax
  800346:	be 00 00 00 00       	mov    $0x0,%esi
  80034b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800351:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800353:	5b                   	pop    %ebx
  800354:	5e                   	pop    %esi
  800355:	5f                   	pop    %edi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800358:	f3 0f 1e fb          	endbr32 
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
  800362:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800365:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036a:	8b 55 08             	mov    0x8(%ebp),%edx
  80036d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800372:	89 cb                	mov    %ecx,%ebx
  800374:	89 cf                	mov    %ecx,%edi
  800376:	89 ce                	mov    %ecx,%esi
  800378:	cd 30                	int    $0x30
	if(check && ret > 0)
  80037a:	85 c0                	test   %eax,%eax
  80037c:	7f 08                	jg     800386 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800386:	83 ec 0c             	sub    $0xc,%esp
  800389:	50                   	push   %eax
  80038a:	6a 0d                	push   $0xd
  80038c:	68 78 10 80 00       	push   $0x801078
  800391:	6a 23                	push   $0x23
  800393:	68 95 10 80 00       	push   $0x801095
  800398:	e8 00 00 00 00       	call   80039d <_panic>

0080039d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80039d:	f3 0f 1e fb          	endbr32 
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003a6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a9:	8b 35 04 20 80 00    	mov    0x802004,%esi
  8003af:	e8 92 fd ff ff       	call   800146 <sys_getenvid>
  8003b4:	83 ec 0c             	sub    $0xc,%esp
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	56                   	push   %esi
  8003be:	50                   	push   %eax
  8003bf:	68 a4 10 80 00       	push   $0x8010a4
  8003c4:	e8 bb 00 00 00       	call   800484 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c9:	83 c4 18             	add    $0x18,%esp
  8003cc:	53                   	push   %ebx
  8003cd:	ff 75 10             	pushl  0x10(%ebp)
  8003d0:	e8 5a 00 00 00       	call   80042f <vcprintf>
	cprintf("\n");
  8003d5:	c7 04 24 6c 10 80 00 	movl   $0x80106c,(%esp)
  8003dc:	e8 a3 00 00 00       	call   800484 <cprintf>
  8003e1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e4:	cc                   	int3   
  8003e5:	eb fd                	jmp    8003e4 <_panic+0x47>

008003e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e7:	f3 0f 1e fb          	endbr32 
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 04             	sub    $0x4,%esp
  8003f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f5:	8b 13                	mov    (%ebx),%edx
  8003f7:	8d 42 01             	lea    0x1(%edx),%eax
  8003fa:	89 03                	mov    %eax,(%ebx)
  8003fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800403:	3d ff 00 00 00       	cmp    $0xff,%eax
  800408:	74 09                	je     800413 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80040a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80040e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800411:	c9                   	leave  
  800412:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	68 ff 00 00 00       	push   $0xff
  80041b:	8d 43 08             	lea    0x8(%ebx),%eax
  80041e:	50                   	push   %eax
  80041f:	e8 98 fc ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  800424:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	eb db                	jmp    80040a <putch+0x23>

0080042f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042f:	f3 0f 1e fb          	endbr32 
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80043c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800443:	00 00 00 
	b.cnt = 0;
  800446:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80044d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800450:	ff 75 0c             	pushl  0xc(%ebp)
  800453:	ff 75 08             	pushl  0x8(%ebp)
  800456:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80045c:	50                   	push   %eax
  80045d:	68 e7 03 80 00       	push   $0x8003e7
  800462:	e8 20 01 00 00       	call   800587 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800467:	83 c4 08             	add    $0x8,%esp
  80046a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800470:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800476:	50                   	push   %eax
  800477:	e8 40 fc ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  80047c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800484:	f3 0f 1e fb          	endbr32 
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800491:	50                   	push   %eax
  800492:	ff 75 08             	pushl  0x8(%ebp)
  800495:	e8 95 ff ff ff       	call   80042f <vcprintf>
	va_end(ap);

	return cnt;
}
  80049a:	c9                   	leave  
  80049b:	c3                   	ret    

0080049c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 1c             	sub    $0x1c,%esp
  8004a5:	89 c7                	mov    %eax,%edi
  8004a7:	89 d6                	mov    %edx,%esi
  8004a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004af:	89 d1                	mov    %edx,%ecx
  8004b1:	89 c2                	mov    %eax,%edx
  8004b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004c9:	39 c2                	cmp    %eax,%edx
  8004cb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004ce:	72 3e                	jb     80050e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d0:	83 ec 0c             	sub    $0xc,%esp
  8004d3:	ff 75 18             	pushl  0x18(%ebp)
  8004d6:	83 eb 01             	sub    $0x1,%ebx
  8004d9:	53                   	push   %ebx
  8004da:	50                   	push   %eax
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ea:	e8 11 09 00 00       	call   800e00 <__udivdi3>
  8004ef:	83 c4 18             	add    $0x18,%esp
  8004f2:	52                   	push   %edx
  8004f3:	50                   	push   %eax
  8004f4:	89 f2                	mov    %esi,%edx
  8004f6:	89 f8                	mov    %edi,%eax
  8004f8:	e8 9f ff ff ff       	call   80049c <printnum>
  8004fd:	83 c4 20             	add    $0x20,%esp
  800500:	eb 13                	jmp    800515 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	56                   	push   %esi
  800506:	ff 75 18             	pushl  0x18(%ebp)
  800509:	ff d7                	call   *%edi
  80050b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80050e:	83 eb 01             	sub    $0x1,%ebx
  800511:	85 db                	test   %ebx,%ebx
  800513:	7f ed                	jg     800502 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	56                   	push   %esi
  800519:	83 ec 04             	sub    $0x4,%esp
  80051c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80051f:	ff 75 e0             	pushl  -0x20(%ebp)
  800522:	ff 75 dc             	pushl  -0x24(%ebp)
  800525:	ff 75 d8             	pushl  -0x28(%ebp)
  800528:	e8 e3 09 00 00       	call   800f10 <__umoddi3>
  80052d:	83 c4 14             	add    $0x14,%esp
  800530:	0f be 80 c7 10 80 00 	movsbl 0x8010c7(%eax),%eax
  800537:	50                   	push   %eax
  800538:	ff d7                	call   *%edi
}
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800540:	5b                   	pop    %ebx
  800541:	5e                   	pop    %esi
  800542:	5f                   	pop    %edi
  800543:	5d                   	pop    %ebp
  800544:	c3                   	ret    

00800545 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800545:	f3 0f 1e fb          	endbr32 
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800553:	8b 10                	mov    (%eax),%edx
  800555:	3b 50 04             	cmp    0x4(%eax),%edx
  800558:	73 0a                	jae    800564 <sprintputch+0x1f>
		*b->buf++ = ch;
  80055a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80055d:	89 08                	mov    %ecx,(%eax)
  80055f:	8b 45 08             	mov    0x8(%ebp),%eax
  800562:	88 02                	mov    %al,(%edx)
}
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <printfmt>:
{
  800566:	f3 0f 1e fb          	endbr32 
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800570:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800573:	50                   	push   %eax
  800574:	ff 75 10             	pushl  0x10(%ebp)
  800577:	ff 75 0c             	pushl  0xc(%ebp)
  80057a:	ff 75 08             	pushl  0x8(%ebp)
  80057d:	e8 05 00 00 00       	call   800587 <vprintfmt>
}
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	c9                   	leave  
  800586:	c3                   	ret    

00800587 <vprintfmt>:
{
  800587:	f3 0f 1e fb          	endbr32 
  80058b:	55                   	push   %ebp
  80058c:	89 e5                	mov    %esp,%ebp
  80058e:	57                   	push   %edi
  80058f:	56                   	push   %esi
  800590:	53                   	push   %ebx
  800591:	83 ec 3c             	sub    $0x3c,%esp
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80059d:	e9 4a 03 00 00       	jmp    8008ec <vprintfmt+0x365>
		padc = ' ';
  8005a2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005a6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005ad:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005bb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8d 47 01             	lea    0x1(%edi),%eax
  8005c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005c6:	0f b6 17             	movzbl (%edi),%edx
  8005c9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005cc:	3c 55                	cmp    $0x55,%al
  8005ce:	0f 87 de 03 00 00    	ja     8009b2 <vprintfmt+0x42b>
  8005d4:	0f b6 c0             	movzbl %al,%eax
  8005d7:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005de:	00 
  8005df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005e2:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005e6:	eb d8                	jmp    8005c0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005eb:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005ef:	eb cf                	jmp    8005c0 <vprintfmt+0x39>
  8005f1:	0f b6 d2             	movzbl %dl,%edx
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800602:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800606:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800609:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80060c:	83 f9 09             	cmp    $0x9,%ecx
  80060f:	77 55                	ja     800666 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800611:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800614:	eb e9                	jmp    8005ff <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80062a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80062e:	79 90                	jns    8005c0 <vprintfmt+0x39>
				width = precision, precision = -1;
  800630:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800633:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800636:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80063d:	eb 81                	jmp    8005c0 <vprintfmt+0x39>
  80063f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800642:	85 c0                	test   %eax,%eax
  800644:	ba 00 00 00 00       	mov    $0x0,%edx
  800649:	0f 49 d0             	cmovns %eax,%edx
  80064c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800652:	e9 69 ff ff ff       	jmp    8005c0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80065a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800661:	e9 5a ff ff ff       	jmp    8005c0 <vprintfmt+0x39>
  800666:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	eb bc                	jmp    80062a <vprintfmt+0xa3>
			lflag++;
  80066e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800674:	e9 47 ff ff ff       	jmp    8005c0 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 78 04             	lea    0x4(%eax),%edi
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	ff 30                	pushl  (%eax)
  800685:	ff d6                	call   *%esi
			break;
  800687:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80068a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80068d:	e9 57 02 00 00       	jmp    8008e9 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 78 04             	lea    0x4(%eax),%edi
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	99                   	cltd   
  80069b:	31 d0                	xor    %edx,%eax
  80069d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80069f:	83 f8 0f             	cmp    $0xf,%eax
  8006a2:	7f 23                	jg     8006c7 <vprintfmt+0x140>
  8006a4:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	74 18                	je     8006c7 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8006af:	52                   	push   %edx
  8006b0:	68 e8 10 80 00       	push   $0x8010e8
  8006b5:	53                   	push   %ebx
  8006b6:	56                   	push   %esi
  8006b7:	e8 aa fe ff ff       	call   800566 <printfmt>
  8006bc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006bf:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006c2:	e9 22 02 00 00       	jmp    8008e9 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006c7:	50                   	push   %eax
  8006c8:	68 df 10 80 00       	push   $0x8010df
  8006cd:	53                   	push   %ebx
  8006ce:	56                   	push   %esi
  8006cf:	e8 92 fe ff ff       	call   800566 <printfmt>
  8006d4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006d7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006da:	e9 0a 02 00 00       	jmp    8008e9 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	83 c0 04             	add    $0x4,%eax
  8006e5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006ed:	85 d2                	test   %edx,%edx
  8006ef:	b8 d8 10 80 00       	mov    $0x8010d8,%eax
  8006f4:	0f 45 c2             	cmovne %edx,%eax
  8006f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006fe:	7e 06                	jle    800706 <vprintfmt+0x17f>
  800700:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800704:	75 0d                	jne    800713 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800706:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800709:	89 c7                	mov    %eax,%edi
  80070b:	03 45 e0             	add    -0x20(%ebp),%eax
  80070e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800711:	eb 55                	jmp    800768 <vprintfmt+0x1e1>
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	ff 75 d8             	pushl  -0x28(%ebp)
  800719:	ff 75 cc             	pushl  -0x34(%ebp)
  80071c:	e8 45 03 00 00       	call   800a66 <strnlen>
  800721:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800724:	29 c2                	sub    %eax,%edx
  800726:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80072e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800732:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800735:	85 ff                	test   %edi,%edi
  800737:	7e 11                	jle    80074a <vprintfmt+0x1c3>
					putch(padc, putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	ff 75 e0             	pushl  -0x20(%ebp)
  800740:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800742:	83 ef 01             	sub    $0x1,%edi
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb eb                	jmp    800735 <vprintfmt+0x1ae>
  80074a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80074d:	85 d2                	test   %edx,%edx
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	0f 49 c2             	cmovns %edx,%eax
  800757:	29 c2                	sub    %eax,%edx
  800759:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80075c:	eb a8                	jmp    800706 <vprintfmt+0x17f>
					putch(ch, putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	52                   	push   %edx
  800763:	ff d6                	call   *%esi
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80076b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076d:	83 c7 01             	add    $0x1,%edi
  800770:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800774:	0f be d0             	movsbl %al,%edx
  800777:	85 d2                	test   %edx,%edx
  800779:	74 4b                	je     8007c6 <vprintfmt+0x23f>
  80077b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80077f:	78 06                	js     800787 <vprintfmt+0x200>
  800781:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800785:	78 1e                	js     8007a5 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800787:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80078b:	74 d1                	je     80075e <vprintfmt+0x1d7>
  80078d:	0f be c0             	movsbl %al,%eax
  800790:	83 e8 20             	sub    $0x20,%eax
  800793:	83 f8 5e             	cmp    $0x5e,%eax
  800796:	76 c6                	jbe    80075e <vprintfmt+0x1d7>
					putch('?', putdat);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	53                   	push   %ebx
  80079c:	6a 3f                	push   $0x3f
  80079e:	ff d6                	call   *%esi
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	eb c3                	jmp    800768 <vprintfmt+0x1e1>
  8007a5:	89 cf                	mov    %ecx,%edi
  8007a7:	eb 0e                	jmp    8007b7 <vprintfmt+0x230>
				putch(' ', putdat);
  8007a9:	83 ec 08             	sub    $0x8,%esp
  8007ac:	53                   	push   %ebx
  8007ad:	6a 20                	push   $0x20
  8007af:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007b1:	83 ef 01             	sub    $0x1,%edi
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	85 ff                	test   %edi,%edi
  8007b9:	7f ee                	jg     8007a9 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007be:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c1:	e9 23 01 00 00       	jmp    8008e9 <vprintfmt+0x362>
  8007c6:	89 cf                	mov    %ecx,%edi
  8007c8:	eb ed                	jmp    8007b7 <vprintfmt+0x230>
	if (lflag >= 2)
  8007ca:	83 f9 01             	cmp    $0x1,%ecx
  8007cd:	7f 1b                	jg     8007ea <vprintfmt+0x263>
	else if (lflag)
  8007cf:	85 c9                	test   %ecx,%ecx
  8007d1:	74 63                	je     800836 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 00                	mov    (%eax),%eax
  8007d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007db:	99                   	cltd   
  8007dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 40 04             	lea    0x4(%eax),%eax
  8007e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e8:	eb 17                	jmp    800801 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8b 50 04             	mov    0x4(%eax),%edx
  8007f0:	8b 00                	mov    (%eax),%eax
  8007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 40 08             	lea    0x8(%eax),%eax
  8007fe:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800801:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800804:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	0f 89 bb 00 00 00    	jns    8008cf <vprintfmt+0x348>
				putch('-', putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	6a 2d                	push   $0x2d
  80081a:	ff d6                	call   *%esi
				num = -(long long) num;
  80081c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80081f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800822:	f7 da                	neg    %edx
  800824:	83 d1 00             	adc    $0x0,%ecx
  800827:	f7 d9                	neg    %ecx
  800829:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80082c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800831:	e9 99 00 00 00       	jmp    8008cf <vprintfmt+0x348>
		return va_arg(*ap, int);
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8b 00                	mov    (%eax),%eax
  80083b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083e:	99                   	cltd   
  80083f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8d 40 04             	lea    0x4(%eax),%eax
  800848:	89 45 14             	mov    %eax,0x14(%ebp)
  80084b:	eb b4                	jmp    800801 <vprintfmt+0x27a>
	if (lflag >= 2)
  80084d:	83 f9 01             	cmp    $0x1,%ecx
  800850:	7f 1b                	jg     80086d <vprintfmt+0x2e6>
	else if (lflag)
  800852:	85 c9                	test   %ecx,%ecx
  800854:	74 2c                	je     800882 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800856:	8b 45 14             	mov    0x14(%ebp),%eax
  800859:	8b 10                	mov    (%eax),%edx
  80085b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800860:	8d 40 04             	lea    0x4(%eax),%eax
  800863:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800866:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80086b:	eb 62                	jmp    8008cf <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8b 10                	mov    (%eax),%edx
  800872:	8b 48 04             	mov    0x4(%eax),%ecx
  800875:	8d 40 08             	lea    0x8(%eax),%eax
  800878:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80087b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800880:	eb 4d                	jmp    8008cf <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8b 10                	mov    (%eax),%edx
  800887:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088c:	8d 40 04             	lea    0x4(%eax),%eax
  80088f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800892:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800897:	eb 36                	jmp    8008cf <vprintfmt+0x348>
	if (lflag >= 2)
  800899:	83 f9 01             	cmp    $0x1,%ecx
  80089c:	7f 17                	jg     8008b5 <vprintfmt+0x32e>
	else if (lflag)
  80089e:	85 c9                	test   %ecx,%ecx
  8008a0:	74 6e                	je     800910 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	8b 10                	mov    (%eax),%edx
  8008a7:	89 d0                	mov    %edx,%eax
  8008a9:	99                   	cltd   
  8008aa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008ad:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008b0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b3:	eb 11                	jmp    8008c6 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	8b 50 04             	mov    0x4(%eax),%edx
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008c0:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008c3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008c6:	89 d1                	mov    %edx,%ecx
  8008c8:	89 c2                	mov    %eax,%edx
            base = 8;
  8008ca:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008cf:	83 ec 0c             	sub    $0xc,%esp
  8008d2:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008d6:	57                   	push   %edi
  8008d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8008da:	50                   	push   %eax
  8008db:	51                   	push   %ecx
  8008dc:	52                   	push   %edx
  8008dd:	89 da                	mov    %ebx,%edx
  8008df:	89 f0                	mov    %esi,%eax
  8008e1:	e8 b6 fb ff ff       	call   80049c <printnum>
			break;
  8008e6:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ec:	83 c7 01             	add    $0x1,%edi
  8008ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008f3:	83 f8 25             	cmp    $0x25,%eax
  8008f6:	0f 84 a6 fc ff ff    	je     8005a2 <vprintfmt+0x1b>
			if (ch == '\0')
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	0f 84 ce 00 00 00    	je     8009d2 <vprintfmt+0x44b>
			putch(ch, putdat);
  800904:	83 ec 08             	sub    $0x8,%esp
  800907:	53                   	push   %ebx
  800908:	50                   	push   %eax
  800909:	ff d6                	call   *%esi
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	eb dc                	jmp    8008ec <vprintfmt+0x365>
		return va_arg(*ap, int);
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	8b 10                	mov    (%eax),%edx
  800915:	89 d0                	mov    %edx,%eax
  800917:	99                   	cltd   
  800918:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80091b:	8d 49 04             	lea    0x4(%ecx),%ecx
  80091e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800921:	eb a3                	jmp    8008c6 <vprintfmt+0x33f>
			putch('0', putdat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	53                   	push   %ebx
  800927:	6a 30                	push   $0x30
  800929:	ff d6                	call   *%esi
			putch('x', putdat);
  80092b:	83 c4 08             	add    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	6a 78                	push   $0x78
  800931:	ff d6                	call   *%esi
			num = (unsigned long long)
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8b 10                	mov    (%eax),%edx
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80093d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800940:	8d 40 04             	lea    0x4(%eax),%eax
  800943:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800946:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80094b:	eb 82                	jmp    8008cf <vprintfmt+0x348>
	if (lflag >= 2)
  80094d:	83 f9 01             	cmp    $0x1,%ecx
  800950:	7f 1e                	jg     800970 <vprintfmt+0x3e9>
	else if (lflag)
  800952:	85 c9                	test   %ecx,%ecx
  800954:	74 32                	je     800988 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800956:	8b 45 14             	mov    0x14(%ebp),%eax
  800959:	8b 10                	mov    (%eax),%edx
  80095b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800960:	8d 40 04             	lea    0x4(%eax),%eax
  800963:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800966:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80096b:	e9 5f ff ff ff       	jmp    8008cf <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800970:	8b 45 14             	mov    0x14(%ebp),%eax
  800973:	8b 10                	mov    (%eax),%edx
  800975:	8b 48 04             	mov    0x4(%eax),%ecx
  800978:	8d 40 08             	lea    0x8(%eax),%eax
  80097b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80097e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800983:	e9 47 ff ff ff       	jmp    8008cf <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800988:	8b 45 14             	mov    0x14(%ebp),%eax
  80098b:	8b 10                	mov    (%eax),%edx
  80098d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800992:	8d 40 04             	lea    0x4(%eax),%eax
  800995:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800998:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80099d:	e9 2d ff ff ff       	jmp    8008cf <vprintfmt+0x348>
			putch(ch, putdat);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	53                   	push   %ebx
  8009a6:	6a 25                	push   $0x25
  8009a8:	ff d6                	call   *%esi
			break;
  8009aa:	83 c4 10             	add    $0x10,%esp
  8009ad:	e9 37 ff ff ff       	jmp    8008e9 <vprintfmt+0x362>
			putch('%', putdat);
  8009b2:	83 ec 08             	sub    $0x8,%esp
  8009b5:	53                   	push   %ebx
  8009b6:	6a 25                	push   $0x25
  8009b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009ba:	83 c4 10             	add    $0x10,%esp
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009c3:	74 05                	je     8009ca <vprintfmt+0x443>
  8009c5:	83 e8 01             	sub    $0x1,%eax
  8009c8:	eb f5                	jmp    8009bf <vprintfmt+0x438>
  8009ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009cd:	e9 17 ff ff ff       	jmp    8008e9 <vprintfmt+0x362>
}
  8009d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009da:	f3 0f 1e fb          	endbr32 
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 18             	sub    $0x18,%esp
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009fb:	85 c0                	test   %eax,%eax
  8009fd:	74 26                	je     800a25 <vsnprintf+0x4b>
  8009ff:	85 d2                	test   %edx,%edx
  800a01:	7e 22                	jle    800a25 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a03:	ff 75 14             	pushl  0x14(%ebp)
  800a06:	ff 75 10             	pushl  0x10(%ebp)
  800a09:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a0c:	50                   	push   %eax
  800a0d:	68 45 05 80 00       	push   $0x800545
  800a12:	e8 70 fb ff ff       	call   800587 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a20:	83 c4 10             	add    $0x10,%esp
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    
		return -E_INVAL;
  800a25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a2a:	eb f7                	jmp    800a23 <vsnprintf+0x49>

00800a2c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a2c:	f3 0f 1e fb          	endbr32 
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a36:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a39:	50                   	push   %eax
  800a3a:	ff 75 10             	pushl  0x10(%ebp)
  800a3d:	ff 75 0c             	pushl  0xc(%ebp)
  800a40:	ff 75 08             	pushl  0x8(%ebp)
  800a43:	e8 92 ff ff ff       	call   8009da <vsnprintf>
	va_end(ap);

	return rc;
}
  800a48:	c9                   	leave  
  800a49:	c3                   	ret    

00800a4a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a4a:	f3 0f 1e fb          	endbr32 
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a5d:	74 05                	je     800a64 <strlen+0x1a>
		n++;
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	eb f5                	jmp    800a59 <strlen+0xf>
	return n;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a66:	f3 0f 1e fb          	endbr32 
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	39 d0                	cmp    %edx,%eax
  800a7a:	74 0d                	je     800a89 <strnlen+0x23>
  800a7c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a80:	74 05                	je     800a87 <strnlen+0x21>
		n++;
  800a82:	83 c0 01             	add    $0x1,%eax
  800a85:	eb f1                	jmp    800a78 <strnlen+0x12>
  800a87:	89 c2                	mov    %eax,%edx
	return n;
}
  800a89:	89 d0                	mov    %edx,%eax
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a8d:	f3 0f 1e fb          	endbr32 
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	53                   	push   %ebx
  800a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800aa4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800aa7:	83 c0 01             	add    $0x1,%eax
  800aaa:	84 d2                	test   %dl,%dl
  800aac:	75 f2                	jne    800aa0 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800aae:	89 c8                	mov    %ecx,%eax
  800ab0:	5b                   	pop    %ebx
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ab3:	f3 0f 1e fb          	endbr32 
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	83 ec 10             	sub    $0x10,%esp
  800abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac1:	53                   	push   %ebx
  800ac2:	e8 83 ff ff ff       	call   800a4a <strlen>
  800ac7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aca:	ff 75 0c             	pushl  0xc(%ebp)
  800acd:	01 d8                	add    %ebx,%eax
  800acf:	50                   	push   %eax
  800ad0:	e8 b8 ff ff ff       	call   800a8d <strcpy>
	return dst;
}
  800ad5:	89 d8                	mov    %ebx,%eax
  800ad7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ada:	c9                   	leave  
  800adb:	c3                   	ret    

00800adc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800adc:	f3 0f 1e fb          	endbr32 
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af0:	89 f0                	mov    %esi,%eax
  800af2:	39 d8                	cmp    %ebx,%eax
  800af4:	74 11                	je     800b07 <strncpy+0x2b>
		*dst++ = *src;
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	0f b6 0a             	movzbl (%edx),%ecx
  800afc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aff:	80 f9 01             	cmp    $0x1,%cl
  800b02:	83 da ff             	sbb    $0xffffffff,%edx
  800b05:	eb eb                	jmp    800af2 <strncpy+0x16>
	}
	return ret;
}
  800b07:	89 f0                	mov    %esi,%eax
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b0d:	f3 0f 1e fb          	endbr32 
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	8b 75 08             	mov    0x8(%ebp),%esi
  800b19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1c:	8b 55 10             	mov    0x10(%ebp),%edx
  800b1f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b21:	85 d2                	test   %edx,%edx
  800b23:	74 21                	je     800b46 <strlcpy+0x39>
  800b25:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b29:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b2b:	39 c2                	cmp    %eax,%edx
  800b2d:	74 14                	je     800b43 <strlcpy+0x36>
  800b2f:	0f b6 19             	movzbl (%ecx),%ebx
  800b32:	84 db                	test   %bl,%bl
  800b34:	74 0b                	je     800b41 <strlcpy+0x34>
			*dst++ = *src++;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	83 c2 01             	add    $0x1,%edx
  800b3c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b3f:	eb ea                	jmp    800b2b <strlcpy+0x1e>
  800b41:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b43:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b46:	29 f0                	sub    %esi,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b4c:	f3 0f 1e fb          	endbr32 
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b56:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b59:	0f b6 01             	movzbl (%ecx),%eax
  800b5c:	84 c0                	test   %al,%al
  800b5e:	74 0c                	je     800b6c <strcmp+0x20>
  800b60:	3a 02                	cmp    (%edx),%al
  800b62:	75 08                	jne    800b6c <strcmp+0x20>
		p++, q++;
  800b64:	83 c1 01             	add    $0x1,%ecx
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	eb ed                	jmp    800b59 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6c:	0f b6 c0             	movzbl %al,%eax
  800b6f:	0f b6 12             	movzbl (%edx),%edx
  800b72:	29 d0                	sub    %edx,%eax
}
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b76:	f3 0f 1e fb          	endbr32 
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b84:	89 c3                	mov    %eax,%ebx
  800b86:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b89:	eb 06                	jmp    800b91 <strncmp+0x1b>
		n--, p++, q++;
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b91:	39 d8                	cmp    %ebx,%eax
  800b93:	74 16                	je     800bab <strncmp+0x35>
  800b95:	0f b6 08             	movzbl (%eax),%ecx
  800b98:	84 c9                	test   %cl,%cl
  800b9a:	74 04                	je     800ba0 <strncmp+0x2a>
  800b9c:	3a 0a                	cmp    (%edx),%cl
  800b9e:	74 eb                	je     800b8b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba0:	0f b6 00             	movzbl (%eax),%eax
  800ba3:	0f b6 12             	movzbl (%edx),%edx
  800ba6:	29 d0                	sub    %edx,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    
		return 0;
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb0:	eb f6                	jmp    800ba8 <strncmp+0x32>

00800bb2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bb2:	f3 0f 1e fb          	endbr32 
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc0:	0f b6 10             	movzbl (%eax),%edx
  800bc3:	84 d2                	test   %dl,%dl
  800bc5:	74 09                	je     800bd0 <strchr+0x1e>
		if (*s == c)
  800bc7:	38 ca                	cmp    %cl,%dl
  800bc9:	74 0a                	je     800bd5 <strchr+0x23>
	for (; *s; s++)
  800bcb:	83 c0 01             	add    $0x1,%eax
  800bce:	eb f0                	jmp    800bc0 <strchr+0xe>
			return (char *) s;
	return 0;
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd7:	f3 0f 1e fb          	endbr32 
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be8:	38 ca                	cmp    %cl,%dl
  800bea:	74 09                	je     800bf5 <strfind+0x1e>
  800bec:	84 d2                	test   %dl,%dl
  800bee:	74 05                	je     800bf5 <strfind+0x1e>
	for (; *s; s++)
  800bf0:	83 c0 01             	add    $0x1,%eax
  800bf3:	eb f0                	jmp    800be5 <strfind+0xe>
			break;
	return (char *) s;
}
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf7:	f3 0f 1e fb          	endbr32 
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c07:	85 c9                	test   %ecx,%ecx
  800c09:	74 31                	je     800c3c <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c0b:	89 f8                	mov    %edi,%eax
  800c0d:	09 c8                	or     %ecx,%eax
  800c0f:	a8 03                	test   $0x3,%al
  800c11:	75 23                	jne    800c36 <memset+0x3f>
		c &= 0xFF;
  800c13:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c17:	89 d3                	mov    %edx,%ebx
  800c19:	c1 e3 08             	shl    $0x8,%ebx
  800c1c:	89 d0                	mov    %edx,%eax
  800c1e:	c1 e0 18             	shl    $0x18,%eax
  800c21:	89 d6                	mov    %edx,%esi
  800c23:	c1 e6 10             	shl    $0x10,%esi
  800c26:	09 f0                	or     %esi,%eax
  800c28:	09 c2                	or     %eax,%edx
  800c2a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c2c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c2f:	89 d0                	mov    %edx,%eax
  800c31:	fc                   	cld    
  800c32:	f3 ab                	rep stos %eax,%es:(%edi)
  800c34:	eb 06                	jmp    800c3c <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c39:	fc                   	cld    
  800c3a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c3c:	89 f8                	mov    %edi,%eax
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c43:	f3 0f 1e fb          	endbr32 
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c55:	39 c6                	cmp    %eax,%esi
  800c57:	73 32                	jae    800c8b <memmove+0x48>
  800c59:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c5c:	39 c2                	cmp    %eax,%edx
  800c5e:	76 2b                	jbe    800c8b <memmove+0x48>
		s += n;
		d += n;
  800c60:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c63:	89 fe                	mov    %edi,%esi
  800c65:	09 ce                	or     %ecx,%esi
  800c67:	09 d6                	or     %edx,%esi
  800c69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c6f:	75 0e                	jne    800c7f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c71:	83 ef 04             	sub    $0x4,%edi
  800c74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c77:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c7a:	fd                   	std    
  800c7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7d:	eb 09                	jmp    800c88 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c7f:	83 ef 01             	sub    $0x1,%edi
  800c82:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c85:	fd                   	std    
  800c86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c88:	fc                   	cld    
  800c89:	eb 1a                	jmp    800ca5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8b:	89 c2                	mov    %eax,%edx
  800c8d:	09 ca                	or     %ecx,%edx
  800c8f:	09 f2                	or     %esi,%edx
  800c91:	f6 c2 03             	test   $0x3,%dl
  800c94:	75 0a                	jne    800ca0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c96:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c99:	89 c7                	mov    %eax,%edi
  800c9b:	fc                   	cld    
  800c9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c9e:	eb 05                	jmp    800ca5 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ca0:	89 c7                	mov    %eax,%edi
  800ca2:	fc                   	cld    
  800ca3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ca9:	f3 0f 1e fb          	endbr32 
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb3:	ff 75 10             	pushl  0x10(%ebp)
  800cb6:	ff 75 0c             	pushl  0xc(%ebp)
  800cb9:	ff 75 08             	pushl  0x8(%ebp)
  800cbc:	e8 82 ff ff ff       	call   800c43 <memmove>
}
  800cc1:	c9                   	leave  
  800cc2:	c3                   	ret    

00800cc3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cc3:	f3 0f 1e fb          	endbr32 
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd2:	89 c6                	mov    %eax,%esi
  800cd4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd7:	39 f0                	cmp    %esi,%eax
  800cd9:	74 1c                	je     800cf7 <memcmp+0x34>
		if (*s1 != *s2)
  800cdb:	0f b6 08             	movzbl (%eax),%ecx
  800cde:	0f b6 1a             	movzbl (%edx),%ebx
  800ce1:	38 d9                	cmp    %bl,%cl
  800ce3:	75 08                	jne    800ced <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ce5:	83 c0 01             	add    $0x1,%eax
  800ce8:	83 c2 01             	add    $0x1,%edx
  800ceb:	eb ea                	jmp    800cd7 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ced:	0f b6 c1             	movzbl %cl,%eax
  800cf0:	0f b6 db             	movzbl %bl,%ebx
  800cf3:	29 d8                	sub    %ebx,%eax
  800cf5:	eb 05                	jmp    800cfc <memcmp+0x39>
	}

	return 0;
  800cf7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d0d:	89 c2                	mov    %eax,%edx
  800d0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d12:	39 d0                	cmp    %edx,%eax
  800d14:	73 09                	jae    800d1f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d16:	38 08                	cmp    %cl,(%eax)
  800d18:	74 05                	je     800d1f <memfind+0x1f>
	for (; s < ends; s++)
  800d1a:	83 c0 01             	add    $0x1,%eax
  800d1d:	eb f3                	jmp    800d12 <memfind+0x12>
			break;
	return (void *) s;
}
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d21:	f3 0f 1e fb          	endbr32 
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d31:	eb 03                	jmp    800d36 <strtol+0x15>
		s++;
  800d33:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d36:	0f b6 01             	movzbl (%ecx),%eax
  800d39:	3c 20                	cmp    $0x20,%al
  800d3b:	74 f6                	je     800d33 <strtol+0x12>
  800d3d:	3c 09                	cmp    $0x9,%al
  800d3f:	74 f2                	je     800d33 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d41:	3c 2b                	cmp    $0x2b,%al
  800d43:	74 2a                	je     800d6f <strtol+0x4e>
	int neg = 0;
  800d45:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d4a:	3c 2d                	cmp    $0x2d,%al
  800d4c:	74 2b                	je     800d79 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d54:	75 0f                	jne    800d65 <strtol+0x44>
  800d56:	80 39 30             	cmpb   $0x30,(%ecx)
  800d59:	74 28                	je     800d83 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d5b:	85 db                	test   %ebx,%ebx
  800d5d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d62:	0f 44 d8             	cmove  %eax,%ebx
  800d65:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d6d:	eb 46                	jmp    800db5 <strtol+0x94>
		s++;
  800d6f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d72:	bf 00 00 00 00       	mov    $0x0,%edi
  800d77:	eb d5                	jmp    800d4e <strtol+0x2d>
		s++, neg = 1;
  800d79:	83 c1 01             	add    $0x1,%ecx
  800d7c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d81:	eb cb                	jmp    800d4e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d83:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d87:	74 0e                	je     800d97 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d89:	85 db                	test   %ebx,%ebx
  800d8b:	75 d8                	jne    800d65 <strtol+0x44>
		s++, base = 8;
  800d8d:	83 c1 01             	add    $0x1,%ecx
  800d90:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d95:	eb ce                	jmp    800d65 <strtol+0x44>
		s += 2, base = 16;
  800d97:	83 c1 02             	add    $0x2,%ecx
  800d9a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d9f:	eb c4                	jmp    800d65 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800da1:	0f be d2             	movsbl %dl,%edx
  800da4:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800daa:	7d 3a                	jge    800de6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800dac:	83 c1 01             	add    $0x1,%ecx
  800daf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800db3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800db5:	0f b6 11             	movzbl (%ecx),%edx
  800db8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dbb:	89 f3                	mov    %esi,%ebx
  800dbd:	80 fb 09             	cmp    $0x9,%bl
  800dc0:	76 df                	jbe    800da1 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dc2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dc5:	89 f3                	mov    %esi,%ebx
  800dc7:	80 fb 19             	cmp    $0x19,%bl
  800dca:	77 08                	ja     800dd4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dcc:	0f be d2             	movsbl %dl,%edx
  800dcf:	83 ea 57             	sub    $0x57,%edx
  800dd2:	eb d3                	jmp    800da7 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dd4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dd7:	89 f3                	mov    %esi,%ebx
  800dd9:	80 fb 19             	cmp    $0x19,%bl
  800ddc:	77 08                	ja     800de6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dde:	0f be d2             	movsbl %dl,%edx
  800de1:	83 ea 37             	sub    $0x37,%edx
  800de4:	eb c1                	jmp    800da7 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800de6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dea:	74 05                	je     800df1 <strtol+0xd0>
		*endptr = (char *) s;
  800dec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800def:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	f7 da                	neg    %edx
  800df5:	85 ff                	test   %edi,%edi
  800df7:	0f 45 c2             	cmovne %edx,%eax
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    
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
