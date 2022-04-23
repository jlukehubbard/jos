
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
  800135:	68 58 10 80 00       	push   $0x801058
  80013a:	6a 23                	push   $0x23
  80013c:	68 75 10 80 00       	push   $0x801075
  800141:	e8 36 02 00 00       	call   80037c <_panic>

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
  8001c2:	68 58 10 80 00       	push   $0x801058
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 75 10 80 00       	push   $0x801075
  8001ce:	e8 a9 01 00 00       	call   80037c <_panic>

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
  800208:	68 58 10 80 00       	push   $0x801058
  80020d:	6a 23                	push   $0x23
  80020f:	68 75 10 80 00       	push   $0x801075
  800214:	e8 63 01 00 00       	call   80037c <_panic>

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
  80024e:	68 58 10 80 00       	push   $0x801058
  800253:	6a 23                	push   $0x23
  800255:	68 75 10 80 00       	push   $0x801075
  80025a:	e8 1d 01 00 00       	call   80037c <_panic>

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
  800294:	68 58 10 80 00       	push   $0x801058
  800299:	6a 23                	push   $0x23
  80029b:	68 75 10 80 00       	push   $0x801075
  8002a0:	e8 d7 00 00 00       	call   80037c <_panic>

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
  8002da:	68 58 10 80 00       	push   $0x801058
  8002df:	6a 23                	push   $0x23
  8002e1:	68 75 10 80 00       	push   $0x801075
  8002e6:	e8 91 00 00 00       	call   80037c <_panic>

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
  800320:	68 58 10 80 00       	push   $0x801058
  800325:	6a 23                	push   $0x23
  800327:	68 75 10 80 00       	push   $0x801075
  80032c:	e8 4b 00 00 00       	call   80037c <_panic>

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
	asm volatile("int %1\n"
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
  800367:	8b 55 08             	mov    0x8(%ebp),%edx
  80036a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80036f:	89 cb                	mov    %ecx,%ebx
  800371:	89 cf                	mov    %ecx,%edi
  800373:	89 ce                	mov    %ecx,%esi
  800375:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80037c:	f3 0f 1e fb          	endbr32 
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800385:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800388:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80038e:	e8 b3 fd ff ff       	call   800146 <sys_getenvid>
  800393:	83 ec 0c             	sub    $0xc,%esp
  800396:	ff 75 0c             	pushl  0xc(%ebp)
  800399:	ff 75 08             	pushl  0x8(%ebp)
  80039c:	56                   	push   %esi
  80039d:	50                   	push   %eax
  80039e:	68 84 10 80 00       	push   $0x801084
  8003a3:	e8 bb 00 00 00       	call   800463 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a8:	83 c4 18             	add    $0x18,%esp
  8003ab:	53                   	push   %ebx
  8003ac:	ff 75 10             	pushl  0x10(%ebp)
  8003af:	e8 5a 00 00 00       	call   80040e <vcprintf>
	cprintf("\n");
  8003b4:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  8003bb:	e8 a3 00 00 00       	call   800463 <cprintf>
  8003c0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c3:	cc                   	int3   
  8003c4:	eb fd                	jmp    8003c3 <_panic+0x47>

008003c6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c6:	f3 0f 1e fb          	endbr32 
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	53                   	push   %ebx
  8003ce:	83 ec 04             	sub    $0x4,%esp
  8003d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d4:	8b 13                	mov    (%ebx),%edx
  8003d6:	8d 42 01             	lea    0x1(%edx),%eax
  8003d9:	89 03                	mov    %eax,(%ebx)
  8003db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e7:	74 09                	je     8003f2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003f2:	83 ec 08             	sub    $0x8,%esp
  8003f5:	68 ff 00 00 00       	push   $0xff
  8003fa:	8d 43 08             	lea    0x8(%ebx),%eax
  8003fd:	50                   	push   %eax
  8003fe:	e8 b9 fc ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  800403:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	eb db                	jmp    8003e9 <putch+0x23>

0080040e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040e:	f3 0f 1e fb          	endbr32 
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80041b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800422:	00 00 00 
	b.cnt = 0;
  800425:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80042c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042f:	ff 75 0c             	pushl  0xc(%ebp)
  800432:	ff 75 08             	pushl  0x8(%ebp)
  800435:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80043b:	50                   	push   %eax
  80043c:	68 c6 03 80 00       	push   $0x8003c6
  800441:	e8 20 01 00 00       	call   800566 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800446:	83 c4 08             	add    $0x8,%esp
  800449:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80044f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800455:	50                   	push   %eax
  800456:	e8 61 fc ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  80045b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800461:	c9                   	leave  
  800462:	c3                   	ret    

00800463 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800463:	f3 0f 1e fb          	endbr32 
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80046d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800470:	50                   	push   %eax
  800471:	ff 75 08             	pushl  0x8(%ebp)
  800474:	e8 95 ff ff ff       	call   80040e <vcprintf>
	va_end(ap);

	return cnt;
}
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	57                   	push   %edi
  80047f:	56                   	push   %esi
  800480:	53                   	push   %ebx
  800481:	83 ec 1c             	sub    $0x1c,%esp
  800484:	89 c7                	mov    %eax,%edi
  800486:	89 d6                	mov    %edx,%esi
  800488:	8b 45 08             	mov    0x8(%ebp),%eax
  80048b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048e:	89 d1                	mov    %edx,%ecx
  800490:	89 c2                	mov    %eax,%edx
  800492:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800495:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800498:	8b 45 10             	mov    0x10(%ebp),%eax
  80049b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004a8:	39 c2                	cmp    %eax,%edx
  8004aa:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004ad:	72 3e                	jb     8004ed <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004af:	83 ec 0c             	sub    $0xc,%esp
  8004b2:	ff 75 18             	pushl  0x18(%ebp)
  8004b5:	83 eb 01             	sub    $0x1,%ebx
  8004b8:	53                   	push   %ebx
  8004b9:	50                   	push   %eax
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c9:	e8 12 09 00 00       	call   800de0 <__udivdi3>
  8004ce:	83 c4 18             	add    $0x18,%esp
  8004d1:	52                   	push   %edx
  8004d2:	50                   	push   %eax
  8004d3:	89 f2                	mov    %esi,%edx
  8004d5:	89 f8                	mov    %edi,%eax
  8004d7:	e8 9f ff ff ff       	call   80047b <printnum>
  8004dc:	83 c4 20             	add    $0x20,%esp
  8004df:	eb 13                	jmp    8004f4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	56                   	push   %esi
  8004e5:	ff 75 18             	pushl  0x18(%ebp)
  8004e8:	ff d7                	call   *%edi
  8004ea:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004ed:	83 eb 01             	sub    $0x1,%ebx
  8004f0:	85 db                	test   %ebx,%ebx
  8004f2:	7f ed                	jg     8004e1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	56                   	push   %esi
  8004f8:	83 ec 04             	sub    $0x4,%esp
  8004fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff 75 dc             	pushl  -0x24(%ebp)
  800504:	ff 75 d8             	pushl  -0x28(%ebp)
  800507:	e8 e4 09 00 00       	call   800ef0 <__umoddi3>
  80050c:	83 c4 14             	add    $0x14,%esp
  80050f:	0f be 80 a7 10 80 00 	movsbl 0x8010a7(%eax),%eax
  800516:	50                   	push   %eax
  800517:	ff d7                	call   *%edi
}
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051f:	5b                   	pop    %ebx
  800520:	5e                   	pop    %esi
  800521:	5f                   	pop    %edi
  800522:	5d                   	pop    %ebp
  800523:	c3                   	ret    

00800524 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800524:	f3 0f 1e fb          	endbr32 
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80052e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800532:	8b 10                	mov    (%eax),%edx
  800534:	3b 50 04             	cmp    0x4(%eax),%edx
  800537:	73 0a                	jae    800543 <sprintputch+0x1f>
		*b->buf++ = ch;
  800539:	8d 4a 01             	lea    0x1(%edx),%ecx
  80053c:	89 08                	mov    %ecx,(%eax)
  80053e:	8b 45 08             	mov    0x8(%ebp),%eax
  800541:	88 02                	mov    %al,(%edx)
}
  800543:	5d                   	pop    %ebp
  800544:	c3                   	ret    

00800545 <printfmt>:
{
  800545:	f3 0f 1e fb          	endbr32 
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80054f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800552:	50                   	push   %eax
  800553:	ff 75 10             	pushl  0x10(%ebp)
  800556:	ff 75 0c             	pushl  0xc(%ebp)
  800559:	ff 75 08             	pushl  0x8(%ebp)
  80055c:	e8 05 00 00 00       	call   800566 <vprintfmt>
}
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	c9                   	leave  
  800565:	c3                   	ret    

00800566 <vprintfmt>:
{
  800566:	f3 0f 1e fb          	endbr32 
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	57                   	push   %edi
  80056e:	56                   	push   %esi
  80056f:	53                   	push   %ebx
  800570:	83 ec 3c             	sub    $0x3c,%esp
  800573:	8b 75 08             	mov    0x8(%ebp),%esi
  800576:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800579:	8b 7d 10             	mov    0x10(%ebp),%edi
  80057c:	e9 4a 03 00 00       	jmp    8008cb <vprintfmt+0x365>
		padc = ' ';
  800581:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800585:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80058c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800593:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80059a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8d 47 01             	lea    0x1(%edi),%eax
  8005a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a5:	0f b6 17             	movzbl (%edi),%edx
  8005a8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005ab:	3c 55                	cmp    $0x55,%al
  8005ad:	0f 87 de 03 00 00    	ja     800991 <vprintfmt+0x42b>
  8005b3:	0f b6 c0             	movzbl %al,%eax
  8005b6:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8005bd:	00 
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005c1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005c5:	eb d8                	jmp    80059f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ca:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005ce:	eb cf                	jmp    80059f <vprintfmt+0x39>
  8005d0:	0f b6 d2             	movzbl %dl,%edx
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005db:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005e5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005e8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005eb:	83 f9 09             	cmp    $0x9,%ecx
  8005ee:	77 55                	ja     800645 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005f3:	eb e9                	jmp    8005de <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800609:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060d:	79 90                	jns    80059f <vprintfmt+0x39>
				width = precision, precision = -1;
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800615:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80061c:	eb 81                	jmp    80059f <vprintfmt+0x39>
  80061e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800621:	85 c0                	test   %eax,%eax
  800623:	ba 00 00 00 00       	mov    $0x0,%edx
  800628:	0f 49 d0             	cmovns %eax,%edx
  80062b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800631:	e9 69 ff ff ff       	jmp    80059f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800639:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800640:	e9 5a ff ff ff       	jmp    80059f <vprintfmt+0x39>
  800645:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800648:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064b:	eb bc                	jmp    800609 <vprintfmt+0xa3>
			lflag++;
  80064d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800653:	e9 47 ff ff ff       	jmp    80059f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 78 04             	lea    0x4(%eax),%edi
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	ff 30                	pushl  (%eax)
  800664:	ff d6                	call   *%esi
			break;
  800666:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800669:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80066c:	e9 57 02 00 00       	jmp    8008c8 <vprintfmt+0x362>
			err = va_arg(ap, int);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 78 04             	lea    0x4(%eax),%edi
  800677:	8b 00                	mov    (%eax),%eax
  800679:	99                   	cltd   
  80067a:	31 d0                	xor    %edx,%eax
  80067c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067e:	83 f8 0f             	cmp    $0xf,%eax
  800681:	7f 23                	jg     8006a6 <vprintfmt+0x140>
  800683:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  80068a:	85 d2                	test   %edx,%edx
  80068c:	74 18                	je     8006a6 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 c8 10 80 00       	push   $0x8010c8
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 aa fe ff ff       	call   800545 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069e:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006a1:	e9 22 02 00 00       	jmp    8008c8 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006a6:	50                   	push   %eax
  8006a7:	68 bf 10 80 00       	push   $0x8010bf
  8006ac:	53                   	push   %ebx
  8006ad:	56                   	push   %esi
  8006ae:	e8 92 fe ff ff       	call   800545 <printfmt>
  8006b3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006b6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006b9:	e9 0a 02 00 00       	jmp    8008c8 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	83 c0 04             	add    $0x4,%eax
  8006c4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006cc:	85 d2                	test   %edx,%edx
  8006ce:	b8 b8 10 80 00       	mov    $0x8010b8,%eax
  8006d3:	0f 45 c2             	cmovne %edx,%eax
  8006d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006dd:	7e 06                	jle    8006e5 <vprintfmt+0x17f>
  8006df:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006e3:	75 0d                	jne    8006f2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006e8:	89 c7                	mov    %eax,%edi
  8006ea:	03 45 e0             	add    -0x20(%ebp),%eax
  8006ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f0:	eb 55                	jmp    800747 <vprintfmt+0x1e1>
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f8:	ff 75 cc             	pushl  -0x34(%ebp)
  8006fb:	e8 45 03 00 00       	call   800a45 <strnlen>
  800700:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800703:	29 c2                	sub    %eax,%edx
  800705:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80070d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800711:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800714:	85 ff                	test   %edi,%edi
  800716:	7e 11                	jle    800729 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	53                   	push   %ebx
  80071c:	ff 75 e0             	pushl  -0x20(%ebp)
  80071f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800721:	83 ef 01             	sub    $0x1,%edi
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb eb                	jmp    800714 <vprintfmt+0x1ae>
  800729:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80072c:	85 d2                	test   %edx,%edx
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
  800733:	0f 49 c2             	cmovns %edx,%eax
  800736:	29 c2                	sub    %eax,%edx
  800738:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80073b:	eb a8                	jmp    8006e5 <vprintfmt+0x17f>
					putch(ch, putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	53                   	push   %ebx
  800741:	52                   	push   %edx
  800742:	ff d6                	call   *%esi
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80074a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074c:	83 c7 01             	add    $0x1,%edi
  80074f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800753:	0f be d0             	movsbl %al,%edx
  800756:	85 d2                	test   %edx,%edx
  800758:	74 4b                	je     8007a5 <vprintfmt+0x23f>
  80075a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075e:	78 06                	js     800766 <vprintfmt+0x200>
  800760:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800764:	78 1e                	js     800784 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800766:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80076a:	74 d1                	je     80073d <vprintfmt+0x1d7>
  80076c:	0f be c0             	movsbl %al,%eax
  80076f:	83 e8 20             	sub    $0x20,%eax
  800772:	83 f8 5e             	cmp    $0x5e,%eax
  800775:	76 c6                	jbe    80073d <vprintfmt+0x1d7>
					putch('?', putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	6a 3f                	push   $0x3f
  80077d:	ff d6                	call   *%esi
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	eb c3                	jmp    800747 <vprintfmt+0x1e1>
  800784:	89 cf                	mov    %ecx,%edi
  800786:	eb 0e                	jmp    800796 <vprintfmt+0x230>
				putch(' ', putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	6a 20                	push   $0x20
  80078e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800790:	83 ef 01             	sub    $0x1,%edi
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	85 ff                	test   %edi,%edi
  800798:	7f ee                	jg     800788 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80079a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a0:	e9 23 01 00 00       	jmp    8008c8 <vprintfmt+0x362>
  8007a5:	89 cf                	mov    %ecx,%edi
  8007a7:	eb ed                	jmp    800796 <vprintfmt+0x230>
	if (lflag >= 2)
  8007a9:	83 f9 01             	cmp    $0x1,%ecx
  8007ac:	7f 1b                	jg     8007c9 <vprintfmt+0x263>
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 63                	je     800815 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ba:	99                   	cltd   
  8007bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8d 40 04             	lea    0x4(%eax),%eax
  8007c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c7:	eb 17                	jmp    8007e0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8b 50 04             	mov    0x4(%eax),%edx
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 40 08             	lea    0x8(%eax),%eax
  8007dd:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007e0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007e6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	0f 89 bb 00 00 00    	jns    8008ae <vprintfmt+0x348>
				putch('-', putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	6a 2d                	push   $0x2d
  8007f9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800801:	f7 da                	neg    %edx
  800803:	83 d1 00             	adc    $0x0,%ecx
  800806:	f7 d9                	neg    %ecx
  800808:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80080b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800810:	e9 99 00 00 00       	jmp    8008ae <vprintfmt+0x348>
		return va_arg(*ap, int);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081d:	99                   	cltd   
  80081e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8d 40 04             	lea    0x4(%eax),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
  80082a:	eb b4                	jmp    8007e0 <vprintfmt+0x27a>
	if (lflag >= 2)
  80082c:	83 f9 01             	cmp    $0x1,%ecx
  80082f:	7f 1b                	jg     80084c <vprintfmt+0x2e6>
	else if (lflag)
  800831:	85 c9                	test   %ecx,%ecx
  800833:	74 2c                	je     800861 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083f:	8d 40 04             	lea    0x4(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800845:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80084a:	eb 62                	jmp    8008ae <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	8b 48 04             	mov    0x4(%eax),%ecx
  800854:	8d 40 08             	lea    0x8(%eax),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80085a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80085f:	eb 4d                	jmp    8008ae <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086b:	8d 40 04             	lea    0x4(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800871:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800876:	eb 36                	jmp    8008ae <vprintfmt+0x348>
	if (lflag >= 2)
  800878:	83 f9 01             	cmp    $0x1,%ecx
  80087b:	7f 17                	jg     800894 <vprintfmt+0x32e>
	else if (lflag)
  80087d:	85 c9                	test   %ecx,%ecx
  80087f:	74 6e                	je     8008ef <vprintfmt+0x389>
		return va_arg(*ap, long);
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	8b 10                	mov    (%eax),%edx
  800886:	89 d0                	mov    %edx,%eax
  800888:	99                   	cltd   
  800889:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80088c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80088f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800892:	eb 11                	jmp    8008a5 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8b 50 04             	mov    0x4(%eax),%edx
  80089a:	8b 00                	mov    (%eax),%eax
  80089c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80089f:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008a2:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008a5:	89 d1                	mov    %edx,%ecx
  8008a7:	89 c2                	mov    %eax,%edx
            base = 8;
  8008a9:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008ae:	83 ec 0c             	sub    $0xc,%esp
  8008b1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008b5:	57                   	push   %edi
  8008b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b9:	50                   	push   %eax
  8008ba:	51                   	push   %ecx
  8008bb:	52                   	push   %edx
  8008bc:	89 da                	mov    %ebx,%edx
  8008be:	89 f0                	mov    %esi,%eax
  8008c0:	e8 b6 fb ff ff       	call   80047b <printnum>
			break;
  8008c5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008cb:	83 c7 01             	add    $0x1,%edi
  8008ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d2:	83 f8 25             	cmp    $0x25,%eax
  8008d5:	0f 84 a6 fc ff ff    	je     800581 <vprintfmt+0x1b>
			if (ch == '\0')
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	0f 84 ce 00 00 00    	je     8009b1 <vprintfmt+0x44b>
			putch(ch, putdat);
  8008e3:	83 ec 08             	sub    $0x8,%esp
  8008e6:	53                   	push   %ebx
  8008e7:	50                   	push   %eax
  8008e8:	ff d6                	call   *%esi
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	eb dc                	jmp    8008cb <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f2:	8b 10                	mov    (%eax),%edx
  8008f4:	89 d0                	mov    %edx,%eax
  8008f6:	99                   	cltd   
  8008f7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008fa:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800900:	eb a3                	jmp    8008a5 <vprintfmt+0x33f>
			putch('0', putdat);
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	53                   	push   %ebx
  800906:	6a 30                	push   $0x30
  800908:	ff d6                	call   *%esi
			putch('x', putdat);
  80090a:	83 c4 08             	add    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	6a 78                	push   $0x78
  800910:	ff d6                	call   *%esi
			num = (unsigned long long)
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8b 10                	mov    (%eax),%edx
  800917:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80091c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80091f:	8d 40 04             	lea    0x4(%eax),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800925:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80092a:	eb 82                	jmp    8008ae <vprintfmt+0x348>
	if (lflag >= 2)
  80092c:	83 f9 01             	cmp    $0x1,%ecx
  80092f:	7f 1e                	jg     80094f <vprintfmt+0x3e9>
	else if (lflag)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	74 32                	je     800967 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800935:	8b 45 14             	mov    0x14(%ebp),%eax
  800938:	8b 10                	mov    (%eax),%edx
  80093a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093f:	8d 40 04             	lea    0x4(%eax),%eax
  800942:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800945:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80094a:	e9 5f ff ff ff       	jmp    8008ae <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8b 10                	mov    (%eax),%edx
  800954:	8b 48 04             	mov    0x4(%eax),%ecx
  800957:	8d 40 08             	lea    0x8(%eax),%eax
  80095a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800962:	e9 47 ff ff ff       	jmp    8008ae <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800967:	8b 45 14             	mov    0x14(%ebp),%eax
  80096a:	8b 10                	mov    (%eax),%edx
  80096c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800971:	8d 40 04             	lea    0x4(%eax),%eax
  800974:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800977:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80097c:	e9 2d ff ff ff       	jmp    8008ae <vprintfmt+0x348>
			putch(ch, putdat);
  800981:	83 ec 08             	sub    $0x8,%esp
  800984:	53                   	push   %ebx
  800985:	6a 25                	push   $0x25
  800987:	ff d6                	call   *%esi
			break;
  800989:	83 c4 10             	add    $0x10,%esp
  80098c:	e9 37 ff ff ff       	jmp    8008c8 <vprintfmt+0x362>
			putch('%', putdat);
  800991:	83 ec 08             	sub    $0x8,%esp
  800994:	53                   	push   %ebx
  800995:	6a 25                	push   $0x25
  800997:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800999:	83 c4 10             	add    $0x10,%esp
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009a2:	74 05                	je     8009a9 <vprintfmt+0x443>
  8009a4:	83 e8 01             	sub    $0x1,%eax
  8009a7:	eb f5                	jmp    80099e <vprintfmt+0x438>
  8009a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009ac:	e9 17 ff ff ff       	jmp    8008c8 <vprintfmt+0x362>
}
  8009b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5f                   	pop    %edi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b9:	f3 0f 1e fb          	endbr32 
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 18             	sub    $0x18,%esp
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009da:	85 c0                	test   %eax,%eax
  8009dc:	74 26                	je     800a04 <vsnprintf+0x4b>
  8009de:	85 d2                	test   %edx,%edx
  8009e0:	7e 22                	jle    800a04 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e2:	ff 75 14             	pushl  0x14(%ebp)
  8009e5:	ff 75 10             	pushl  0x10(%ebp)
  8009e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009eb:	50                   	push   %eax
  8009ec:	68 24 05 80 00       	push   $0x800524
  8009f1:	e8 70 fb ff ff       	call   800566 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ff:	83 c4 10             	add    $0x10,%esp
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    
		return -E_INVAL;
  800a04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a09:	eb f7                	jmp    800a02 <vsnprintf+0x49>

00800a0b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0b:	f3 0f 1e fb          	endbr32 
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a15:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a18:	50                   	push   %eax
  800a19:	ff 75 10             	pushl  0x10(%ebp)
  800a1c:	ff 75 0c             	pushl  0xc(%ebp)
  800a1f:	ff 75 08             	pushl  0x8(%ebp)
  800a22:	e8 92 ff ff ff       	call   8009b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a27:	c9                   	leave  
  800a28:	c3                   	ret    

00800a29 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a29:	f3 0f 1e fb          	endbr32 
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
  800a38:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a3c:	74 05                	je     800a43 <strlen+0x1a>
		n++;
  800a3e:	83 c0 01             	add    $0x1,%eax
  800a41:	eb f5                	jmp    800a38 <strlen+0xf>
	return n;
}
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a45:	f3 0f 1e fb          	endbr32 
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	74 0d                	je     800a68 <strnlen+0x23>
  800a5b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a5f:	74 05                	je     800a66 <strnlen+0x21>
		n++;
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	eb f1                	jmp    800a57 <strnlen+0x12>
  800a66:	89 c2                	mov    %eax,%edx
	return n;
}
  800a68:	89 d0                	mov    %edx,%eax
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a6c:	f3 0f 1e fb          	endbr32 
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a83:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a86:	83 c0 01             	add    $0x1,%eax
  800a89:	84 d2                	test   %dl,%dl
  800a8b:	75 f2                	jne    800a7f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a8d:	89 c8                	mov    %ecx,%eax
  800a8f:	5b                   	pop    %ebx
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a92:	f3 0f 1e fb          	endbr32 
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 10             	sub    $0x10,%esp
  800a9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa0:	53                   	push   %ebx
  800aa1:	e8 83 ff ff ff       	call   800a29 <strlen>
  800aa6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aa9:	ff 75 0c             	pushl  0xc(%ebp)
  800aac:	01 d8                	add    %ebx,%eax
  800aae:	50                   	push   %eax
  800aaf:	e8 b8 ff ff ff       	call   800a6c <strcpy>
	return dst;
}
  800ab4:	89 d8                	mov    %ebx,%eax
  800ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    

00800abb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800abb:	f3 0f 1e fb          	endbr32 
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acf:	89 f0                	mov    %esi,%eax
  800ad1:	39 d8                	cmp    %ebx,%eax
  800ad3:	74 11                	je     800ae6 <strncpy+0x2b>
		*dst++ = *src;
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	0f b6 0a             	movzbl (%edx),%ecx
  800adb:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ade:	80 f9 01             	cmp    $0x1,%cl
  800ae1:	83 da ff             	sbb    $0xffffffff,%edx
  800ae4:	eb eb                	jmp    800ad1 <strncpy+0x16>
	}
	return ret;
}
  800ae6:	89 f0                	mov    %esi,%eax
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aec:	f3 0f 1e fb          	endbr32 
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 75 08             	mov    0x8(%ebp),%esi
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	8b 55 10             	mov    0x10(%ebp),%edx
  800afe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b00:	85 d2                	test   %edx,%edx
  800b02:	74 21                	je     800b25 <strlcpy+0x39>
  800b04:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b08:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b0a:	39 c2                	cmp    %eax,%edx
  800b0c:	74 14                	je     800b22 <strlcpy+0x36>
  800b0e:	0f b6 19             	movzbl (%ecx),%ebx
  800b11:	84 db                	test   %bl,%bl
  800b13:	74 0b                	je     800b20 <strlcpy+0x34>
			*dst++ = *src++;
  800b15:	83 c1 01             	add    $0x1,%ecx
  800b18:	83 c2 01             	add    $0x1,%edx
  800b1b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1e:	eb ea                	jmp    800b0a <strlcpy+0x1e>
  800b20:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b22:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b25:	29 f0                	sub    %esi,%eax
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2b:	f3 0f 1e fb          	endbr32 
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b35:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b38:	0f b6 01             	movzbl (%ecx),%eax
  800b3b:	84 c0                	test   %al,%al
  800b3d:	74 0c                	je     800b4b <strcmp+0x20>
  800b3f:	3a 02                	cmp    (%edx),%al
  800b41:	75 08                	jne    800b4b <strcmp+0x20>
		p++, q++;
  800b43:	83 c1 01             	add    $0x1,%ecx
  800b46:	83 c2 01             	add    $0x1,%edx
  800b49:	eb ed                	jmp    800b38 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4b:	0f b6 c0             	movzbl %al,%eax
  800b4e:	0f b6 12             	movzbl (%edx),%edx
  800b51:	29 d0                	sub    %edx,%eax
}
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b55:	f3 0f 1e fb          	endbr32 
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	53                   	push   %ebx
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b63:	89 c3                	mov    %eax,%ebx
  800b65:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b68:	eb 06                	jmp    800b70 <strncmp+0x1b>
		n--, p++, q++;
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b70:	39 d8                	cmp    %ebx,%eax
  800b72:	74 16                	je     800b8a <strncmp+0x35>
  800b74:	0f b6 08             	movzbl (%eax),%ecx
  800b77:	84 c9                	test   %cl,%cl
  800b79:	74 04                	je     800b7f <strncmp+0x2a>
  800b7b:	3a 0a                	cmp    (%edx),%cl
  800b7d:	74 eb                	je     800b6a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b7f:	0f b6 00             	movzbl (%eax),%eax
  800b82:	0f b6 12             	movzbl (%edx),%edx
  800b85:	29 d0                	sub    %edx,%eax
}
  800b87:	5b                   	pop    %ebx
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    
		return 0;
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8f:	eb f6                	jmp    800b87 <strncmp+0x32>

00800b91 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b91:	f3 0f 1e fb          	endbr32 
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9f:	0f b6 10             	movzbl (%eax),%edx
  800ba2:	84 d2                	test   %dl,%dl
  800ba4:	74 09                	je     800baf <strchr+0x1e>
		if (*s == c)
  800ba6:	38 ca                	cmp    %cl,%dl
  800ba8:	74 0a                	je     800bb4 <strchr+0x23>
	for (; *s; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	eb f0                	jmp    800b9f <strchr+0xe>
			return (char *) s;
	return 0;
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb6:	f3 0f 1e fb          	endbr32 
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc7:	38 ca                	cmp    %cl,%dl
  800bc9:	74 09                	je     800bd4 <strfind+0x1e>
  800bcb:	84 d2                	test   %dl,%dl
  800bcd:	74 05                	je     800bd4 <strfind+0x1e>
	for (; *s; s++)
  800bcf:	83 c0 01             	add    $0x1,%eax
  800bd2:	eb f0                	jmp    800bc4 <strfind+0xe>
			break;
	return (char *) s;
}
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd6:	f3 0f 1e fb          	endbr32 
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be6:	85 c9                	test   %ecx,%ecx
  800be8:	74 31                	je     800c1b <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bea:	89 f8                	mov    %edi,%eax
  800bec:	09 c8                	or     %ecx,%eax
  800bee:	a8 03                	test   $0x3,%al
  800bf0:	75 23                	jne    800c15 <memset+0x3f>
		c &= 0xFF;
  800bf2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	c1 e3 08             	shl    $0x8,%ebx
  800bfb:	89 d0                	mov    %edx,%eax
  800bfd:	c1 e0 18             	shl    $0x18,%eax
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	c1 e6 10             	shl    $0x10,%esi
  800c05:	09 f0                	or     %esi,%eax
  800c07:	09 c2                	or     %eax,%edx
  800c09:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c0b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c0e:	89 d0                	mov    %edx,%eax
  800c10:	fc                   	cld    
  800c11:	f3 ab                	rep stos %eax,%es:(%edi)
  800c13:	eb 06                	jmp    800c1b <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c18:	fc                   	cld    
  800c19:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c1b:	89 f8                	mov    %edi,%eax
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c22:	f3 0f 1e fb          	endbr32 
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c34:	39 c6                	cmp    %eax,%esi
  800c36:	73 32                	jae    800c6a <memmove+0x48>
  800c38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3b:	39 c2                	cmp    %eax,%edx
  800c3d:	76 2b                	jbe    800c6a <memmove+0x48>
		s += n;
		d += n;
  800c3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c42:	89 fe                	mov    %edi,%esi
  800c44:	09 ce                	or     %ecx,%esi
  800c46:	09 d6                	or     %edx,%esi
  800c48:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4e:	75 0e                	jne    800c5e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c50:	83 ef 04             	sub    $0x4,%edi
  800c53:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c56:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c59:	fd                   	std    
  800c5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5c:	eb 09                	jmp    800c67 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5e:	83 ef 01             	sub    $0x1,%edi
  800c61:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c64:	fd                   	std    
  800c65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c67:	fc                   	cld    
  800c68:	eb 1a                	jmp    800c84 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6a:	89 c2                	mov    %eax,%edx
  800c6c:	09 ca                	or     %ecx,%edx
  800c6e:	09 f2                	or     %esi,%edx
  800c70:	f6 c2 03             	test   $0x3,%dl
  800c73:	75 0a                	jne    800c7f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c75:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c78:	89 c7                	mov    %eax,%edi
  800c7a:	fc                   	cld    
  800c7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7d:	eb 05                	jmp    800c84 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c7f:	89 c7                	mov    %eax,%edi
  800c81:	fc                   	cld    
  800c82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c88:	f3 0f 1e fb          	endbr32 
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c92:	ff 75 10             	pushl  0x10(%ebp)
  800c95:	ff 75 0c             	pushl  0xc(%ebp)
  800c98:	ff 75 08             	pushl  0x8(%ebp)
  800c9b:	e8 82 ff ff ff       	call   800c22 <memmove>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb1:	89 c6                	mov    %eax,%esi
  800cb3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb6:	39 f0                	cmp    %esi,%eax
  800cb8:	74 1c                	je     800cd6 <memcmp+0x34>
		if (*s1 != *s2)
  800cba:	0f b6 08             	movzbl (%eax),%ecx
  800cbd:	0f b6 1a             	movzbl (%edx),%ebx
  800cc0:	38 d9                	cmp    %bl,%cl
  800cc2:	75 08                	jne    800ccc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc4:	83 c0 01             	add    $0x1,%eax
  800cc7:	83 c2 01             	add    $0x1,%edx
  800cca:	eb ea                	jmp    800cb6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ccc:	0f b6 c1             	movzbl %cl,%eax
  800ccf:	0f b6 db             	movzbl %bl,%ebx
  800cd2:	29 d8                	sub    %ebx,%eax
  800cd4:	eb 05                	jmp    800cdb <memcmp+0x39>
	}

	return 0;
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cdf:	f3 0f 1e fb          	endbr32 
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cec:	89 c2                	mov    %eax,%edx
  800cee:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf1:	39 d0                	cmp    %edx,%eax
  800cf3:	73 09                	jae    800cfe <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf5:	38 08                	cmp    %cl,(%eax)
  800cf7:	74 05                	je     800cfe <memfind+0x1f>
	for (; s < ends; s++)
  800cf9:	83 c0 01             	add    $0x1,%eax
  800cfc:	eb f3                	jmp    800cf1 <memfind+0x12>
			break;
	return (void *) s;
}
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d10:	eb 03                	jmp    800d15 <strtol+0x15>
		s++;
  800d12:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d15:	0f b6 01             	movzbl (%ecx),%eax
  800d18:	3c 20                	cmp    $0x20,%al
  800d1a:	74 f6                	je     800d12 <strtol+0x12>
  800d1c:	3c 09                	cmp    $0x9,%al
  800d1e:	74 f2                	je     800d12 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d20:	3c 2b                	cmp    $0x2b,%al
  800d22:	74 2a                	je     800d4e <strtol+0x4e>
	int neg = 0;
  800d24:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d29:	3c 2d                	cmp    $0x2d,%al
  800d2b:	74 2b                	je     800d58 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d2d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d33:	75 0f                	jne    800d44 <strtol+0x44>
  800d35:	80 39 30             	cmpb   $0x30,(%ecx)
  800d38:	74 28                	je     800d62 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d3a:	85 db                	test   %ebx,%ebx
  800d3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d41:	0f 44 d8             	cmove  %eax,%ebx
  800d44:	b8 00 00 00 00       	mov    $0x0,%eax
  800d49:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d4c:	eb 46                	jmp    800d94 <strtol+0x94>
		s++;
  800d4e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d51:	bf 00 00 00 00       	mov    $0x0,%edi
  800d56:	eb d5                	jmp    800d2d <strtol+0x2d>
		s++, neg = 1;
  800d58:	83 c1 01             	add    $0x1,%ecx
  800d5b:	bf 01 00 00 00       	mov    $0x1,%edi
  800d60:	eb cb                	jmp    800d2d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d62:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d66:	74 0e                	je     800d76 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d68:	85 db                	test   %ebx,%ebx
  800d6a:	75 d8                	jne    800d44 <strtol+0x44>
		s++, base = 8;
  800d6c:	83 c1 01             	add    $0x1,%ecx
  800d6f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d74:	eb ce                	jmp    800d44 <strtol+0x44>
		s += 2, base = 16;
  800d76:	83 c1 02             	add    $0x2,%ecx
  800d79:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d7e:	eb c4                	jmp    800d44 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d80:	0f be d2             	movsbl %dl,%edx
  800d83:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d86:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d89:	7d 3a                	jge    800dc5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d8b:	83 c1 01             	add    $0x1,%ecx
  800d8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d92:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d94:	0f b6 11             	movzbl (%ecx),%edx
  800d97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d9a:	89 f3                	mov    %esi,%ebx
  800d9c:	80 fb 09             	cmp    $0x9,%bl
  800d9f:	76 df                	jbe    800d80 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800da1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800da4:	89 f3                	mov    %esi,%ebx
  800da6:	80 fb 19             	cmp    $0x19,%bl
  800da9:	77 08                	ja     800db3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dab:	0f be d2             	movsbl %dl,%edx
  800dae:	83 ea 57             	sub    $0x57,%edx
  800db1:	eb d3                	jmp    800d86 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800db3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800db6:	89 f3                	mov    %esi,%ebx
  800db8:	80 fb 19             	cmp    $0x19,%bl
  800dbb:	77 08                	ja     800dc5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dbd:	0f be d2             	movsbl %dl,%edx
  800dc0:	83 ea 37             	sub    $0x37,%edx
  800dc3:	eb c1                	jmp    800d86 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc9:	74 05                	je     800dd0 <strtol+0xd0>
		*endptr = (char *) s;
  800dcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dce:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dd0:	89 c2                	mov    %eax,%edx
  800dd2:	f7 da                	neg    %edx
  800dd4:	85 ff                	test   %edi,%edi
  800dd6:	0f 45 c2             	cmovne %edx,%eax
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    
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
