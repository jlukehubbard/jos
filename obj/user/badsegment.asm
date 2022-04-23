
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
	thisenv = 0;
  80004d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800054:	00 00 00 
    envid_t envid = sys_getenvid();
  800057:	e8 d6 00 00 00       	call   800132 <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 db                	test   %ebx,%ebx
  800070:	7e 07                	jle    800079 <libmain+0x3b>
		binaryname = argv[0];
  800072:	8b 06                	mov    (%esi),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	e8 b0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800083:	e8 0a 00 00 00       	call   800092 <exit>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    

00800092 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800092:	f3 0f 1e fb          	endbr32 
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80009c:	6a 00                	push   $0x0
  80009e:	e8 4a 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	f3 0f 1e fb          	endbr32 
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	f3 0f 1e fb          	endbr32 
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	f3 0f 1e fb          	endbr32 
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800102:	b8 03 00 00 00       	mov    $0x3,%eax
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7f 08                	jg     80011b <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	50                   	push   %eax
  80011f:	6a 03                	push   $0x3
  800121:	68 4a 10 80 00       	push   $0x80104a
  800126:	6a 23                	push   $0x23
  800128:	68 67 10 80 00       	push   $0x801067
  80012d:	e8 36 02 00 00       	call   800368 <_panic>

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	f3 0f 1e fb          	endbr32 
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 02 00 00 00       	mov    $0x2,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_yield>:

void
sys_yield(void)
{
  800155:	f3 0f 1e fb          	endbr32 
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 0b 00 00 00       	mov    $0xb,%eax
  800169:	89 d1                	mov    %edx,%ecx
  80016b:	89 d3                	mov    %edx,%ebx
  80016d:	89 d7                	mov    %edx,%edi
  80016f:	89 d6                	mov    %edx,%esi
  800171:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800173:	5b                   	pop    %ebx
  800174:	5e                   	pop    %esi
  800175:	5f                   	pop    %edi
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800185:	be 00 00 00 00       	mov    $0x0,%esi
  80018a:	8b 55 08             	mov    0x8(%ebp),%edx
  80018d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800190:	b8 04 00 00 00       	mov    $0x4,%eax
  800195:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800198:	89 f7                	mov    %esi,%edi
  80019a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80019c:	85 c0                	test   %eax,%eax
  80019e:	7f 08                	jg     8001a8 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a3:	5b                   	pop    %ebx
  8001a4:	5e                   	pop    %esi
  8001a5:	5f                   	pop    %edi
  8001a6:	5d                   	pop    %ebp
  8001a7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	50                   	push   %eax
  8001ac:	6a 04                	push   $0x4
  8001ae:	68 4a 10 80 00       	push   $0x80104a
  8001b3:	6a 23                	push   $0x23
  8001b5:	68 67 10 80 00       	push   $0x801067
  8001ba:	e8 a9 01 00 00       	call   800368 <_panic>

008001bf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bf:	f3 0f 1e fb          	endbr32 
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	57                   	push   %edi
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001dd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e2:	85 c0                	test   %eax,%eax
  8001e4:	7f 08                	jg     8001ee <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5f                   	pop    %edi
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	50                   	push   %eax
  8001f2:	6a 05                	push   $0x5
  8001f4:	68 4a 10 80 00       	push   $0x80104a
  8001f9:	6a 23                	push   $0x23
  8001fb:	68 67 10 80 00       	push   $0x801067
  800200:	e8 63 01 00 00       	call   800368 <_panic>

00800205 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800205:	f3 0f 1e fb          	endbr32 
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800212:	bb 00 00 00 00       	mov    $0x0,%ebx
  800217:	8b 55 08             	mov    0x8(%ebp),%edx
  80021a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021d:	b8 06 00 00 00       	mov    $0x6,%eax
  800222:	89 df                	mov    %ebx,%edi
  800224:	89 de                	mov    %ebx,%esi
  800226:	cd 30                	int    $0x30
	if(check && ret > 0)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7f 08                	jg     800234 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	50                   	push   %eax
  800238:	6a 06                	push   $0x6
  80023a:	68 4a 10 80 00       	push   $0x80104a
  80023f:	6a 23                	push   $0x23
  800241:	68 67 10 80 00       	push   $0x801067
  800246:	e8 1d 01 00 00       	call   800368 <_panic>

0080024b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024b:	f3 0f 1e fb          	endbr32 
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	57                   	push   %edi
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
  800255:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800258:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025d:	8b 55 08             	mov    0x8(%ebp),%edx
  800260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800263:	b8 08 00 00 00       	mov    $0x8,%eax
  800268:	89 df                	mov    %ebx,%edi
  80026a:	89 de                	mov    %ebx,%esi
  80026c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80026e:	85 c0                	test   %eax,%eax
  800270:	7f 08                	jg     80027a <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	50                   	push   %eax
  80027e:	6a 08                	push   $0x8
  800280:	68 4a 10 80 00       	push   $0x80104a
  800285:	6a 23                	push   $0x23
  800287:	68 67 10 80 00       	push   $0x801067
  80028c:	e8 d7 00 00 00       	call   800368 <_panic>

00800291 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800291:	f3 0f 1e fb          	endbr32 
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	57                   	push   %edi
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
  80029b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80029e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ae:	89 df                	mov    %ebx,%edi
  8002b0:	89 de                	mov    %ebx,%esi
  8002b2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002b4:	85 c0                	test   %eax,%eax
  8002b6:	7f 08                	jg     8002c0 <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c0:	83 ec 0c             	sub    $0xc,%esp
  8002c3:	50                   	push   %eax
  8002c4:	6a 09                	push   $0x9
  8002c6:	68 4a 10 80 00       	push   $0x80104a
  8002cb:	6a 23                	push   $0x23
  8002cd:	68 67 10 80 00       	push   $0x801067
  8002d2:	e8 91 00 00 00       	call   800368 <_panic>

008002d7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d7:	f3 0f 1e fb          	endbr32 
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	57                   	push   %edi
  8002df:	56                   	push   %esi
  8002e0:	53                   	push   %ebx
  8002e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002f4:	89 df                	mov    %ebx,%edi
  8002f6:	89 de                	mov    %ebx,%esi
  8002f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002fa:	85 c0                	test   %eax,%eax
  8002fc:	7f 08                	jg     800306 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800306:	83 ec 0c             	sub    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	6a 0a                	push   $0xa
  80030c:	68 4a 10 80 00       	push   $0x80104a
  800311:	6a 23                	push   $0x23
  800313:	68 67 10 80 00       	push   $0x801067
  800318:	e8 4b 00 00 00       	call   800368 <_panic>

0080031d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80031d:	f3 0f 1e fb          	endbr32 
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
	asm volatile("int %1\n"
  800327:	8b 55 08             	mov    0x8(%ebp),%edx
  80032a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800332:	be 00 00 00 00       	mov    $0x0,%esi
  800337:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80033d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    

00800344 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800344:	f3 0f 1e fb          	endbr32 
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80034e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800353:	8b 55 08             	mov    0x8(%ebp),%edx
  800356:	b8 0d 00 00 00       	mov    $0xd,%eax
  80035b:	89 cb                	mov    %ecx,%ebx
  80035d:	89 cf                	mov    %ecx,%edi
  80035f:	89 ce                	mov    %ecx,%esi
  800361:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 0, (uint32_t)dstva, 0, 0, 0, 0);
}
  800363:	5b                   	pop    %ebx
  800364:	5e                   	pop    %esi
  800365:	5f                   	pop    %edi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800368:	f3 0f 1e fb          	endbr32 
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800371:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800374:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80037a:	e8 b3 fd ff ff       	call   800132 <sys_getenvid>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	ff 75 0c             	pushl  0xc(%ebp)
  800385:	ff 75 08             	pushl  0x8(%ebp)
  800388:	56                   	push   %esi
  800389:	50                   	push   %eax
  80038a:	68 78 10 80 00       	push   $0x801078
  80038f:	e8 bb 00 00 00       	call   80044f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800394:	83 c4 18             	add    $0x18,%esp
  800397:	53                   	push   %ebx
  800398:	ff 75 10             	pushl  0x10(%ebp)
  80039b:	e8 5a 00 00 00       	call   8003fa <vcprintf>
	cprintf("\n");
  8003a0:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  8003a7:	e8 a3 00 00 00       	call   80044f <cprintf>
  8003ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003af:	cc                   	int3   
  8003b0:	eb fd                	jmp    8003af <_panic+0x47>

008003b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003b2:	f3 0f 1e fb          	endbr32 
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 04             	sub    $0x4,%esp
  8003bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003c0:	8b 13                	mov    (%ebx),%edx
  8003c2:	8d 42 01             	lea    0x1(%edx),%eax
  8003c5:	89 03                	mov    %eax,(%ebx)
  8003c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003d3:	74 09                	je     8003de <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003de:	83 ec 08             	sub    $0x8,%esp
  8003e1:	68 ff 00 00 00       	push   $0xff
  8003e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8003e9:	50                   	push   %eax
  8003ea:	e8 b9 fc ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  8003ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb db                	jmp    8003d5 <putch+0x23>

008003fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003fa:	f3 0f 1e fb          	endbr32 
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800407:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80040e:	00 00 00 
	b.cnt = 0;
  800411:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800418:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80041b:	ff 75 0c             	pushl  0xc(%ebp)
  80041e:	ff 75 08             	pushl  0x8(%ebp)
  800421:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800427:	50                   	push   %eax
  800428:	68 b2 03 80 00       	push   $0x8003b2
  80042d:	e8 20 01 00 00       	call   800552 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800432:	83 c4 08             	add    $0x8,%esp
  800435:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80043b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800441:	50                   	push   %eax
  800442:	e8 61 fc ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  800447:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80044f:	f3 0f 1e fb          	endbr32 
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800459:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80045c:	50                   	push   %eax
  80045d:	ff 75 08             	pushl  0x8(%ebp)
  800460:	e8 95 ff ff ff       	call   8003fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800465:	c9                   	leave  
  800466:	c3                   	ret    

00800467 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	57                   	push   %edi
  80046b:	56                   	push   %esi
  80046c:	53                   	push   %ebx
  80046d:	83 ec 1c             	sub    $0x1c,%esp
  800470:	89 c7                	mov    %eax,%edi
  800472:	89 d6                	mov    %edx,%esi
  800474:	8b 45 08             	mov    0x8(%ebp),%eax
  800477:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047a:	89 d1                	mov    %edx,%ecx
  80047c:	89 c2                	mov    %eax,%edx
  80047e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800481:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800484:	8b 45 10             	mov    0x10(%ebp),%eax
  800487:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800494:	39 c2                	cmp    %eax,%edx
  800496:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800499:	72 3e                	jb     8004d9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80049b:	83 ec 0c             	sub    $0xc,%esp
  80049e:	ff 75 18             	pushl  0x18(%ebp)
  8004a1:	83 eb 01             	sub    $0x1,%ebx
  8004a4:	53                   	push   %ebx
  8004a5:	50                   	push   %eax
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b5:	e8 16 09 00 00       	call   800dd0 <__udivdi3>
  8004ba:	83 c4 18             	add    $0x18,%esp
  8004bd:	52                   	push   %edx
  8004be:	50                   	push   %eax
  8004bf:	89 f2                	mov    %esi,%edx
  8004c1:	89 f8                	mov    %edi,%eax
  8004c3:	e8 9f ff ff ff       	call   800467 <printnum>
  8004c8:	83 c4 20             	add    $0x20,%esp
  8004cb:	eb 13                	jmp    8004e0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff 75 18             	pushl  0x18(%ebp)
  8004d4:	ff d7                	call   *%edi
  8004d6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004d9:	83 eb 01             	sub    $0x1,%ebx
  8004dc:	85 db                	test   %ebx,%ebx
  8004de:	7f ed                	jg     8004cd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	83 ec 04             	sub    $0x4,%esp
  8004e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8004f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004f3:	e8 e8 09 00 00       	call   800ee0 <__umoddi3>
  8004f8:	83 c4 14             	add    $0x14,%esp
  8004fb:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  800502:	50                   	push   %eax
  800503:	ff d7                	call   *%edi
}
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050b:	5b                   	pop    %ebx
  80050c:	5e                   	pop    %esi
  80050d:	5f                   	pop    %edi
  80050e:	5d                   	pop    %ebp
  80050f:	c3                   	ret    

00800510 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800510:	f3 0f 1e fb          	endbr32 
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80051a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051e:	8b 10                	mov    (%eax),%edx
  800520:	3b 50 04             	cmp    0x4(%eax),%edx
  800523:	73 0a                	jae    80052f <sprintputch+0x1f>
		*b->buf++ = ch;
  800525:	8d 4a 01             	lea    0x1(%edx),%ecx
  800528:	89 08                	mov    %ecx,(%eax)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	88 02                	mov    %al,(%edx)
}
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <printfmt>:
{
  800531:	f3 0f 1e fb          	endbr32 
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80053b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053e:	50                   	push   %eax
  80053f:	ff 75 10             	pushl  0x10(%ebp)
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	ff 75 08             	pushl  0x8(%ebp)
  800548:	e8 05 00 00 00       	call   800552 <vprintfmt>
}
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <vprintfmt>:
{
  800552:	f3 0f 1e fb          	endbr32 
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 3c             	sub    $0x3c,%esp
  80055f:	8b 75 08             	mov    0x8(%ebp),%esi
  800562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800565:	8b 7d 10             	mov    0x10(%ebp),%edi
  800568:	e9 4a 03 00 00       	jmp    8008b7 <vprintfmt+0x365>
		padc = ' ';
  80056d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800571:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800578:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80057f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800586:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8d 47 01             	lea    0x1(%edi),%eax
  80058e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800591:	0f b6 17             	movzbl (%edi),%edx
  800594:	8d 42 dd             	lea    -0x23(%edx),%eax
  800597:	3c 55                	cmp    $0x55,%al
  800599:	0f 87 de 03 00 00    	ja     80097d <vprintfmt+0x42b>
  80059f:	0f b6 c0             	movzbl %al,%eax
  8005a2:	3e ff 24 85 e0 11 80 	notrack jmp *0x8011e0(,%eax,4)
  8005a9:	00 
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005ad:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005b1:	eb d8                	jmp    80058b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005ba:	eb cf                	jmp    80058b <vprintfmt+0x39>
  8005bc:	0f b6 d2             	movzbl %dl,%edx
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005d1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005d4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005d7:	83 f9 09             	cmp    $0x9,%ecx
  8005da:	77 55                	ja     800631 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005df:	eb e9                	jmp    8005ca <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f9:	79 90                	jns    80058b <vprintfmt+0x39>
				width = precision, precision = -1;
  8005fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800601:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800608:	eb 81                	jmp    80058b <vprintfmt+0x39>
  80060a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060d:	85 c0                	test   %eax,%eax
  80060f:	ba 00 00 00 00       	mov    $0x0,%edx
  800614:	0f 49 d0             	cmovns %eax,%edx
  800617:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80061d:	e9 69 ff ff ff       	jmp    80058b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800625:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80062c:	e9 5a ff ff ff       	jmp    80058b <vprintfmt+0x39>
  800631:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800634:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800637:	eb bc                	jmp    8005f5 <vprintfmt+0xa3>
			lflag++;
  800639:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80063f:	e9 47 ff ff ff       	jmp    80058b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 78 04             	lea    0x4(%eax),%edi
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	ff 30                	pushl  (%eax)
  800650:	ff d6                	call   *%esi
			break;
  800652:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800655:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800658:	e9 57 02 00 00       	jmp    8008b4 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 78 04             	lea    0x4(%eax),%edi
  800663:	8b 00                	mov    (%eax),%eax
  800665:	99                   	cltd   
  800666:	31 d0                	xor    %edx,%eax
  800668:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066a:	83 f8 0f             	cmp    $0xf,%eax
  80066d:	7f 23                	jg     800692 <vprintfmt+0x140>
  80066f:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  800676:	85 d2                	test   %edx,%edx
  800678:	74 18                	je     800692 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80067a:	52                   	push   %edx
  80067b:	68 be 10 80 00       	push   $0x8010be
  800680:	53                   	push   %ebx
  800681:	56                   	push   %esi
  800682:	e8 aa fe ff ff       	call   800531 <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80068a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80068d:	e9 22 02 00 00       	jmp    8008b4 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  800692:	50                   	push   %eax
  800693:	68 b5 10 80 00       	push   $0x8010b5
  800698:	53                   	push   %ebx
  800699:	56                   	push   %esi
  80069a:	e8 92 fe ff ff       	call   800531 <printfmt>
  80069f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006a2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006a5:	e9 0a 02 00 00       	jmp    8008b4 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	83 c0 04             	add    $0x4,%eax
  8006b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  8006bf:	0f 45 c2             	cmovne %edx,%eax
  8006c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c9:	7e 06                	jle    8006d1 <vprintfmt+0x17f>
  8006cb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006cf:	75 0d                	jne    8006de <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006d4:	89 c7                	mov    %eax,%edi
  8006d6:	03 45 e0             	add    -0x20(%ebp),%eax
  8006d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006dc:	eb 55                	jmp    800733 <vprintfmt+0x1e1>
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e4:	ff 75 cc             	pushl  -0x34(%ebp)
  8006e7:	e8 45 03 00 00       	call   800a31 <strnlen>
  8006ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006ef:	29 c2                	sub    %eax,%edx
  8006f1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006f9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	85 ff                	test   %edi,%edi
  800702:	7e 11                	jle    800715 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	53                   	push   %ebx
  800708:	ff 75 e0             	pushl  -0x20(%ebp)
  80070b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80070d:	83 ef 01             	sub    $0x1,%edi
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb eb                	jmp    800700 <vprintfmt+0x1ae>
  800715:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800718:	85 d2                	test   %edx,%edx
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	0f 49 c2             	cmovns %edx,%eax
  800722:	29 c2                	sub    %eax,%edx
  800724:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800727:	eb a8                	jmp    8006d1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	53                   	push   %ebx
  80072d:	52                   	push   %edx
  80072e:	ff d6                	call   *%esi
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800736:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800738:	83 c7 01             	add    $0x1,%edi
  80073b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073f:	0f be d0             	movsbl %al,%edx
  800742:	85 d2                	test   %edx,%edx
  800744:	74 4b                	je     800791 <vprintfmt+0x23f>
  800746:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80074a:	78 06                	js     800752 <vprintfmt+0x200>
  80074c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800750:	78 1e                	js     800770 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800752:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800756:	74 d1                	je     800729 <vprintfmt+0x1d7>
  800758:	0f be c0             	movsbl %al,%eax
  80075b:	83 e8 20             	sub    $0x20,%eax
  80075e:	83 f8 5e             	cmp    $0x5e,%eax
  800761:	76 c6                	jbe    800729 <vprintfmt+0x1d7>
					putch('?', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 3f                	push   $0x3f
  800769:	ff d6                	call   *%esi
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	eb c3                	jmp    800733 <vprintfmt+0x1e1>
  800770:	89 cf                	mov    %ecx,%edi
  800772:	eb 0e                	jmp    800782 <vprintfmt+0x230>
				putch(' ', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	53                   	push   %ebx
  800778:	6a 20                	push   $0x20
  80077a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80077c:	83 ef 01             	sub    $0x1,%edi
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	85 ff                	test   %edi,%edi
  800784:	7f ee                	jg     800774 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800786:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800789:	89 45 14             	mov    %eax,0x14(%ebp)
  80078c:	e9 23 01 00 00       	jmp    8008b4 <vprintfmt+0x362>
  800791:	89 cf                	mov    %ecx,%edi
  800793:	eb ed                	jmp    800782 <vprintfmt+0x230>
	if (lflag >= 2)
  800795:	83 f9 01             	cmp    $0x1,%ecx
  800798:	7f 1b                	jg     8007b5 <vprintfmt+0x263>
	else if (lflag)
  80079a:	85 c9                	test   %ecx,%ecx
  80079c:	74 63                	je     800801 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a6:	99                   	cltd   
  8007a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b3:	eb 17                	jmp    8007cc <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8b 50 04             	mov    0x4(%eax),%edx
  8007bb:	8b 00                	mov    (%eax),%eax
  8007bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 40 08             	lea    0x8(%eax),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007d7:	85 c9                	test   %ecx,%ecx
  8007d9:	0f 89 bb 00 00 00    	jns    80089a <vprintfmt+0x348>
				putch('-', putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	6a 2d                	push   $0x2d
  8007e5:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ed:	f7 da                	neg    %edx
  8007ef:	83 d1 00             	adc    $0x0,%ecx
  8007f2:	f7 d9                	neg    %ecx
  8007f4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fc:	e9 99 00 00 00       	jmp    80089a <vprintfmt+0x348>
		return va_arg(*ap, int);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 00                	mov    (%eax),%eax
  800806:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800809:	99                   	cltd   
  80080a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80080d:	8b 45 14             	mov    0x14(%ebp),%eax
  800810:	8d 40 04             	lea    0x4(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
  800816:	eb b4                	jmp    8007cc <vprintfmt+0x27a>
	if (lflag >= 2)
  800818:	83 f9 01             	cmp    $0x1,%ecx
  80081b:	7f 1b                	jg     800838 <vprintfmt+0x2e6>
	else if (lflag)
  80081d:	85 c9                	test   %ecx,%ecx
  80081f:	74 2c                	je     80084d <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 10                	mov    (%eax),%edx
  800826:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082b:	8d 40 04             	lea    0x4(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800831:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800836:	eb 62                	jmp    80089a <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8b 10                	mov    (%eax),%edx
  80083d:	8b 48 04             	mov    0x4(%eax),%ecx
  800840:	8d 40 08             	lea    0x8(%eax),%eax
  800843:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800846:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80084b:	eb 4d                	jmp    80089a <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 10                	mov    (%eax),%edx
  800852:	b9 00 00 00 00       	mov    $0x0,%ecx
  800857:	8d 40 04             	lea    0x4(%eax),%eax
  80085a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80085d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800862:	eb 36                	jmp    80089a <vprintfmt+0x348>
	if (lflag >= 2)
  800864:	83 f9 01             	cmp    $0x1,%ecx
  800867:	7f 17                	jg     800880 <vprintfmt+0x32e>
	else if (lflag)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 6e                	je     8008db <vprintfmt+0x389>
		return va_arg(*ap, long);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8b 10                	mov    (%eax),%edx
  800872:	89 d0                	mov    %edx,%eax
  800874:	99                   	cltd   
  800875:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800878:	8d 49 04             	lea    0x4(%ecx),%ecx
  80087b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80087e:	eb 11                	jmp    800891 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8b 50 04             	mov    0x4(%eax),%edx
  800886:	8b 00                	mov    (%eax),%eax
  800888:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80088b:	8d 49 08             	lea    0x8(%ecx),%ecx
  80088e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800891:	89 d1                	mov    %edx,%ecx
  800893:	89 c2                	mov    %eax,%edx
            base = 8;
  800895:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80089a:	83 ec 0c             	sub    $0xc,%esp
  80089d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008a1:	57                   	push   %edi
  8008a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a5:	50                   	push   %eax
  8008a6:	51                   	push   %ecx
  8008a7:	52                   	push   %edx
  8008a8:	89 da                	mov    %ebx,%edx
  8008aa:	89 f0                	mov    %esi,%eax
  8008ac:	e8 b6 fb ff ff       	call   800467 <printnum>
			break;
  8008b1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b7:	83 c7 01             	add    $0x1,%edi
  8008ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008be:	83 f8 25             	cmp    $0x25,%eax
  8008c1:	0f 84 a6 fc ff ff    	je     80056d <vprintfmt+0x1b>
			if (ch == '\0')
  8008c7:	85 c0                	test   %eax,%eax
  8008c9:	0f 84 ce 00 00 00    	je     80099d <vprintfmt+0x44b>
			putch(ch, putdat);
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	53                   	push   %ebx
  8008d3:	50                   	push   %eax
  8008d4:	ff d6                	call   *%esi
  8008d6:	83 c4 10             	add    $0x10,%esp
  8008d9:	eb dc                	jmp    8008b7 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008db:	8b 45 14             	mov    0x14(%ebp),%eax
  8008de:	8b 10                	mov    (%eax),%edx
  8008e0:	89 d0                	mov    %edx,%eax
  8008e2:	99                   	cltd   
  8008e3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008e6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008ec:	eb a3                	jmp    800891 <vprintfmt+0x33f>
			putch('0', putdat);
  8008ee:	83 ec 08             	sub    $0x8,%esp
  8008f1:	53                   	push   %ebx
  8008f2:	6a 30                	push   $0x30
  8008f4:	ff d6                	call   *%esi
			putch('x', putdat);
  8008f6:	83 c4 08             	add    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	6a 78                	push   $0x78
  8008fc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	8b 10                	mov    (%eax),%edx
  800903:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800908:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80090b:	8d 40 04             	lea    0x4(%eax),%eax
  80090e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800911:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800916:	eb 82                	jmp    80089a <vprintfmt+0x348>
	if (lflag >= 2)
  800918:	83 f9 01             	cmp    $0x1,%ecx
  80091b:	7f 1e                	jg     80093b <vprintfmt+0x3e9>
	else if (lflag)
  80091d:	85 c9                	test   %ecx,%ecx
  80091f:	74 32                	je     800953 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800921:	8b 45 14             	mov    0x14(%ebp),%eax
  800924:	8b 10                	mov    (%eax),%edx
  800926:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092b:	8d 40 04             	lea    0x4(%eax),%eax
  80092e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800931:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800936:	e9 5f ff ff ff       	jmp    80089a <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80093b:	8b 45 14             	mov    0x14(%ebp),%eax
  80093e:	8b 10                	mov    (%eax),%edx
  800940:	8b 48 04             	mov    0x4(%eax),%ecx
  800943:	8d 40 08             	lea    0x8(%eax),%eax
  800946:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800949:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80094e:	e9 47 ff ff ff       	jmp    80089a <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800953:	8b 45 14             	mov    0x14(%ebp),%eax
  800956:	8b 10                	mov    (%eax),%edx
  800958:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095d:	8d 40 04             	lea    0x4(%eax),%eax
  800960:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800963:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800968:	e9 2d ff ff ff       	jmp    80089a <vprintfmt+0x348>
			putch(ch, putdat);
  80096d:	83 ec 08             	sub    $0x8,%esp
  800970:	53                   	push   %ebx
  800971:	6a 25                	push   $0x25
  800973:	ff d6                	call   *%esi
			break;
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	e9 37 ff ff ff       	jmp    8008b4 <vprintfmt+0x362>
			putch('%', putdat);
  80097d:	83 ec 08             	sub    $0x8,%esp
  800980:	53                   	push   %ebx
  800981:	6a 25                	push   $0x25
  800983:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800985:	83 c4 10             	add    $0x10,%esp
  800988:	89 f8                	mov    %edi,%eax
  80098a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80098e:	74 05                	je     800995 <vprintfmt+0x443>
  800990:	83 e8 01             	sub    $0x1,%eax
  800993:	eb f5                	jmp    80098a <vprintfmt+0x438>
  800995:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800998:	e9 17 ff ff ff       	jmp    8008b4 <vprintfmt+0x362>
}
  80099d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a5:	f3 0f 1e fb          	endbr32 
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 18             	sub    $0x18,%esp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009c6:	85 c0                	test   %eax,%eax
  8009c8:	74 26                	je     8009f0 <vsnprintf+0x4b>
  8009ca:	85 d2                	test   %edx,%edx
  8009cc:	7e 22                	jle    8009f0 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ce:	ff 75 14             	pushl  0x14(%ebp)
  8009d1:	ff 75 10             	pushl  0x10(%ebp)
  8009d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d7:	50                   	push   %eax
  8009d8:	68 10 05 80 00       	push   $0x800510
  8009dd:	e8 70 fb ff ff       	call   800552 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009eb:	83 c4 10             	add    $0x10,%esp
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    
		return -E_INVAL;
  8009f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f5:	eb f7                	jmp    8009ee <vsnprintf+0x49>

008009f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009f7:	f3 0f 1e fb          	endbr32 
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a04:	50                   	push   %eax
  800a05:	ff 75 10             	pushl  0x10(%ebp)
  800a08:	ff 75 0c             	pushl  0xc(%ebp)
  800a0b:	ff 75 08             	pushl  0x8(%ebp)
  800a0e:	e8 92 ff ff ff       	call   8009a5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a15:	f3 0f 1e fb          	endbr32 
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a28:	74 05                	je     800a2f <strlen+0x1a>
		n++;
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	eb f5                	jmp    800a24 <strlen+0xf>
	return n;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a31:	f3 0f 1e fb          	endbr32 
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	39 d0                	cmp    %edx,%eax
  800a45:	74 0d                	je     800a54 <strnlen+0x23>
  800a47:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a4b:	74 05                	je     800a52 <strnlen+0x21>
		n++;
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	eb f1                	jmp    800a43 <strnlen+0x12>
  800a52:	89 c2                	mov    %eax,%edx
	return n;
}
  800a54:	89 d0                	mov    %edx,%eax
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a58:	f3 0f 1e fb          	endbr32 
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a6f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	84 d2                	test   %dl,%dl
  800a77:	75 f2                	jne    800a6b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a79:	89 c8                	mov    %ecx,%eax
  800a7b:	5b                   	pop    %ebx
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7e:	f3 0f 1e fb          	endbr32 
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	83 ec 10             	sub    $0x10,%esp
  800a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8c:	53                   	push   %ebx
  800a8d:	e8 83 ff ff ff       	call   800a15 <strlen>
  800a92:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a95:	ff 75 0c             	pushl  0xc(%ebp)
  800a98:	01 d8                	add    %ebx,%eax
  800a9a:	50                   	push   %eax
  800a9b:	e8 b8 ff ff ff       	call   800a58 <strcpy>
	return dst;
}
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa7:	f3 0f 1e fb          	endbr32 
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab6:	89 f3                	mov    %esi,%ebx
  800ab8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800abb:	89 f0                	mov    %esi,%eax
  800abd:	39 d8                	cmp    %ebx,%eax
  800abf:	74 11                	je     800ad2 <strncpy+0x2b>
		*dst++ = *src;
  800ac1:	83 c0 01             	add    $0x1,%eax
  800ac4:	0f b6 0a             	movzbl (%edx),%ecx
  800ac7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aca:	80 f9 01             	cmp    $0x1,%cl
  800acd:	83 da ff             	sbb    $0xffffffff,%edx
  800ad0:	eb eb                	jmp    800abd <strncpy+0x16>
	}
	return ret;
}
  800ad2:	89 f0                	mov    %esi,%eax
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad8:	f3 0f 1e fb          	endbr32 
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae7:	8b 55 10             	mov    0x10(%ebp),%edx
  800aea:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aec:	85 d2                	test   %edx,%edx
  800aee:	74 21                	je     800b11 <strlcpy+0x39>
  800af0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800af4:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800af6:	39 c2                	cmp    %eax,%edx
  800af8:	74 14                	je     800b0e <strlcpy+0x36>
  800afa:	0f b6 19             	movzbl (%ecx),%ebx
  800afd:	84 db                	test   %bl,%bl
  800aff:	74 0b                	je     800b0c <strlcpy+0x34>
			*dst++ = *src++;
  800b01:	83 c1 01             	add    $0x1,%ecx
  800b04:	83 c2 01             	add    $0x1,%edx
  800b07:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b0a:	eb ea                	jmp    800af6 <strlcpy+0x1e>
  800b0c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b0e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b11:	29 f0                	sub    %esi,%eax
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b17:	f3 0f 1e fb          	endbr32 
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b24:	0f b6 01             	movzbl (%ecx),%eax
  800b27:	84 c0                	test   %al,%al
  800b29:	74 0c                	je     800b37 <strcmp+0x20>
  800b2b:	3a 02                	cmp    (%edx),%al
  800b2d:	75 08                	jne    800b37 <strcmp+0x20>
		p++, q++;
  800b2f:	83 c1 01             	add    $0x1,%ecx
  800b32:	83 c2 01             	add    $0x1,%edx
  800b35:	eb ed                	jmp    800b24 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b37:	0f b6 c0             	movzbl %al,%eax
  800b3a:	0f b6 12             	movzbl (%edx),%edx
  800b3d:	29 d0                	sub    %edx,%eax
}
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b41:	f3 0f 1e fb          	endbr32 
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	53                   	push   %ebx
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4f:	89 c3                	mov    %eax,%ebx
  800b51:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b54:	eb 06                	jmp    800b5c <strncmp+0x1b>
		n--, p++, q++;
  800b56:	83 c0 01             	add    $0x1,%eax
  800b59:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b5c:	39 d8                	cmp    %ebx,%eax
  800b5e:	74 16                	je     800b76 <strncmp+0x35>
  800b60:	0f b6 08             	movzbl (%eax),%ecx
  800b63:	84 c9                	test   %cl,%cl
  800b65:	74 04                	je     800b6b <strncmp+0x2a>
  800b67:	3a 0a                	cmp    (%edx),%cl
  800b69:	74 eb                	je     800b56 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6b:	0f b6 00             	movzbl (%eax),%eax
  800b6e:	0f b6 12             	movzbl (%edx),%edx
  800b71:	29 d0                	sub    %edx,%eax
}
  800b73:	5b                   	pop    %ebx
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
		return 0;
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7b:	eb f6                	jmp    800b73 <strncmp+0x32>

00800b7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7d:	f3 0f 1e fb          	endbr32 
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b8b:	0f b6 10             	movzbl (%eax),%edx
  800b8e:	84 d2                	test   %dl,%dl
  800b90:	74 09                	je     800b9b <strchr+0x1e>
		if (*s == c)
  800b92:	38 ca                	cmp    %cl,%dl
  800b94:	74 0a                	je     800ba0 <strchr+0x23>
	for (; *s; s++)
  800b96:	83 c0 01             	add    $0x1,%eax
  800b99:	eb f0                	jmp    800b8b <strchr+0xe>
			return (char *) s;
	return 0;
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bb3:	38 ca                	cmp    %cl,%dl
  800bb5:	74 09                	je     800bc0 <strfind+0x1e>
  800bb7:	84 d2                	test   %dl,%dl
  800bb9:	74 05                	je     800bc0 <strfind+0x1e>
	for (; *s; s++)
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	eb f0                	jmp    800bb0 <strfind+0xe>
			break;
	return (char *) s;
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc2:	f3 0f 1e fb          	endbr32 
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd2:	85 c9                	test   %ecx,%ecx
  800bd4:	74 31                	je     800c07 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd6:	89 f8                	mov    %edi,%eax
  800bd8:	09 c8                	or     %ecx,%eax
  800bda:	a8 03                	test   $0x3,%al
  800bdc:	75 23                	jne    800c01 <memset+0x3f>
		c &= 0xFF;
  800bde:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be2:	89 d3                	mov    %edx,%ebx
  800be4:	c1 e3 08             	shl    $0x8,%ebx
  800be7:	89 d0                	mov    %edx,%eax
  800be9:	c1 e0 18             	shl    $0x18,%eax
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	c1 e6 10             	shl    $0x10,%esi
  800bf1:	09 f0                	or     %esi,%eax
  800bf3:	09 c2                	or     %eax,%edx
  800bf5:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bfa:	89 d0                	mov    %edx,%eax
  800bfc:	fc                   	cld    
  800bfd:	f3 ab                	rep stos %eax,%es:(%edi)
  800bff:	eb 06                	jmp    800c07 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c04:	fc                   	cld    
  800c05:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c07:	89 f8                	mov    %edi,%eax
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0e:	f3 0f 1e fb          	endbr32 
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c20:	39 c6                	cmp    %eax,%esi
  800c22:	73 32                	jae    800c56 <memmove+0x48>
  800c24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c27:	39 c2                	cmp    %eax,%edx
  800c29:	76 2b                	jbe    800c56 <memmove+0x48>
		s += n;
		d += n;
  800c2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2e:	89 fe                	mov    %edi,%esi
  800c30:	09 ce                	or     %ecx,%esi
  800c32:	09 d6                	or     %edx,%esi
  800c34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c3a:	75 0e                	jne    800c4a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c3c:	83 ef 04             	sub    $0x4,%edi
  800c3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c42:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c45:	fd                   	std    
  800c46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c48:	eb 09                	jmp    800c53 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c4a:	83 ef 01             	sub    $0x1,%edi
  800c4d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c50:	fd                   	std    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c53:	fc                   	cld    
  800c54:	eb 1a                	jmp    800c70 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	09 ca                	or     %ecx,%edx
  800c5a:	09 f2                	or     %esi,%edx
  800c5c:	f6 c2 03             	test   $0x3,%dl
  800c5f:	75 0a                	jne    800c6b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c64:	89 c7                	mov    %eax,%edi
  800c66:	fc                   	cld    
  800c67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c69:	eb 05                	jmp    800c70 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c6b:	89 c7                	mov    %eax,%edi
  800c6d:	fc                   	cld    
  800c6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c74:	f3 0f 1e fb          	endbr32 
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7e:	ff 75 10             	pushl  0x10(%ebp)
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	ff 75 08             	pushl  0x8(%ebp)
  800c87:	e8 82 ff ff ff       	call   800c0e <memmove>
}
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8e:	f3 0f 1e fb          	endbr32 
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9d:	89 c6                	mov    %eax,%esi
  800c9f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca2:	39 f0                	cmp    %esi,%eax
  800ca4:	74 1c                	je     800cc2 <memcmp+0x34>
		if (*s1 != *s2)
  800ca6:	0f b6 08             	movzbl (%eax),%ecx
  800ca9:	0f b6 1a             	movzbl (%edx),%ebx
  800cac:	38 d9                	cmp    %bl,%cl
  800cae:	75 08                	jne    800cb8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cb0:	83 c0 01             	add    $0x1,%eax
  800cb3:	83 c2 01             	add    $0x1,%edx
  800cb6:	eb ea                	jmp    800ca2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cb8:	0f b6 c1             	movzbl %cl,%eax
  800cbb:	0f b6 db             	movzbl %bl,%ebx
  800cbe:	29 d8                	sub    %ebx,%eax
  800cc0:	eb 05                	jmp    800cc7 <memcmp+0x39>
	}

	return 0;
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ccb:	f3 0f 1e fb          	endbr32 
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cd8:	89 c2                	mov    %eax,%edx
  800cda:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cdd:	39 d0                	cmp    %edx,%eax
  800cdf:	73 09                	jae    800cea <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce1:	38 08                	cmp    %cl,(%eax)
  800ce3:	74 05                	je     800cea <memfind+0x1f>
	for (; s < ends; s++)
  800ce5:	83 c0 01             	add    $0x1,%eax
  800ce8:	eb f3                	jmp    800cdd <memfind+0x12>
			break;
	return (void *) s;
}
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cec:	f3 0f 1e fb          	endbr32 
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfc:	eb 03                	jmp    800d01 <strtol+0x15>
		s++;
  800cfe:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d01:	0f b6 01             	movzbl (%ecx),%eax
  800d04:	3c 20                	cmp    $0x20,%al
  800d06:	74 f6                	je     800cfe <strtol+0x12>
  800d08:	3c 09                	cmp    $0x9,%al
  800d0a:	74 f2                	je     800cfe <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d0c:	3c 2b                	cmp    $0x2b,%al
  800d0e:	74 2a                	je     800d3a <strtol+0x4e>
	int neg = 0;
  800d10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d15:	3c 2d                	cmp    $0x2d,%al
  800d17:	74 2b                	je     800d44 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d1f:	75 0f                	jne    800d30 <strtol+0x44>
  800d21:	80 39 30             	cmpb   $0x30,(%ecx)
  800d24:	74 28                	je     800d4e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d26:	85 db                	test   %ebx,%ebx
  800d28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2d:	0f 44 d8             	cmove  %eax,%ebx
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
  800d35:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d38:	eb 46                	jmp    800d80 <strtol+0x94>
		s++;
  800d3a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d42:	eb d5                	jmp    800d19 <strtol+0x2d>
		s++, neg = 1;
  800d44:	83 c1 01             	add    $0x1,%ecx
  800d47:	bf 01 00 00 00       	mov    $0x1,%edi
  800d4c:	eb cb                	jmp    800d19 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d52:	74 0e                	je     800d62 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d54:	85 db                	test   %ebx,%ebx
  800d56:	75 d8                	jne    800d30 <strtol+0x44>
		s++, base = 8;
  800d58:	83 c1 01             	add    $0x1,%ecx
  800d5b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d60:	eb ce                	jmp    800d30 <strtol+0x44>
		s += 2, base = 16;
  800d62:	83 c1 02             	add    $0x2,%ecx
  800d65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d6a:	eb c4                	jmp    800d30 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d6c:	0f be d2             	movsbl %dl,%edx
  800d6f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d75:	7d 3a                	jge    800db1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d77:	83 c1 01             	add    $0x1,%ecx
  800d7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d7e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d80:	0f b6 11             	movzbl (%ecx),%edx
  800d83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d86:	89 f3                	mov    %esi,%ebx
  800d88:	80 fb 09             	cmp    $0x9,%bl
  800d8b:	76 df                	jbe    800d6c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d90:	89 f3                	mov    %esi,%ebx
  800d92:	80 fb 19             	cmp    $0x19,%bl
  800d95:	77 08                	ja     800d9f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d97:	0f be d2             	movsbl %dl,%edx
  800d9a:	83 ea 57             	sub    $0x57,%edx
  800d9d:	eb d3                	jmp    800d72 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800da2:	89 f3                	mov    %esi,%ebx
  800da4:	80 fb 19             	cmp    $0x19,%bl
  800da7:	77 08                	ja     800db1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800da9:	0f be d2             	movsbl %dl,%edx
  800dac:	83 ea 37             	sub    $0x37,%edx
  800daf:	eb c1                	jmp    800d72 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800db1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db5:	74 05                	je     800dbc <strtol+0xd0>
		*endptr = (char *) s;
  800db7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dba:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dbc:	89 c2                	mov    %eax,%edx
  800dbe:	f7 da                	neg    %edx
  800dc0:	85 ff                	test   %edi,%edi
  800dc2:	0f 45 c2             	cmovne %edx,%eax
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <__udivdi3>:
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 1c             	sub    $0x1c,%esp
  800ddb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ddf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800de3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800de7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800deb:	85 d2                	test   %edx,%edx
  800ded:	75 19                	jne    800e08 <__udivdi3+0x38>
  800def:	39 f3                	cmp    %esi,%ebx
  800df1:	76 4d                	jbe    800e40 <__udivdi3+0x70>
  800df3:	31 ff                	xor    %edi,%edi
  800df5:	89 e8                	mov    %ebp,%eax
  800df7:	89 f2                	mov    %esi,%edx
  800df9:	f7 f3                	div    %ebx
  800dfb:	89 fa                	mov    %edi,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	76 14                	jbe    800e20 <__udivdi3+0x50>
  800e0c:	31 ff                	xor    %edi,%edi
  800e0e:	31 c0                	xor    %eax,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	83 c4 1c             	add    $0x1c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	0f bd fa             	bsr    %edx,%edi
  800e23:	83 f7 1f             	xor    $0x1f,%edi
  800e26:	75 48                	jne    800e70 <__udivdi3+0xa0>
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	72 06                	jb     800e32 <__udivdi3+0x62>
  800e2c:	31 c0                	xor    %eax,%eax
  800e2e:	39 eb                	cmp    %ebp,%ebx
  800e30:	77 de                	ja     800e10 <__udivdi3+0x40>
  800e32:	b8 01 00 00 00       	mov    $0x1,%eax
  800e37:	eb d7                	jmp    800e10 <__udivdi3+0x40>
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 d9                	mov    %ebx,%ecx
  800e42:	85 db                	test   %ebx,%ebx
  800e44:	75 0b                	jne    800e51 <__udivdi3+0x81>
  800e46:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f3                	div    %ebx
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	f7 f1                	div    %ecx
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	89 e8                	mov    %ebp,%eax
  800e5b:	89 f7                	mov    %esi,%edi
  800e5d:	f7 f1                	div    %ecx
  800e5f:	89 fa                	mov    %edi,%edx
  800e61:	83 c4 1c             	add    $0x1c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	b8 20 00 00 00       	mov    $0x20,%eax
  800e77:	29 f8                	sub    %edi,%eax
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 d1                	or     %edx,%ecx
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 c1                	mov    %eax,%ecx
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	89 eb                	mov    %ebp,%ebx
  800ea1:	d3 e6                	shl    %cl,%esi
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 de                	or     %ebx,%esi
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	f7 74 24 08          	divl   0x8(%esp)
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	f7 64 24 0c          	mull   0xc(%esp)
  800eb7:	39 d6                	cmp    %edx,%esi
  800eb9:	72 15                	jb     800ed0 <__udivdi3+0x100>
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	39 c5                	cmp    %eax,%ebp
  800ec1:	73 04                	jae    800ec7 <__udivdi3+0xf7>
  800ec3:	39 d6                	cmp    %edx,%esi
  800ec5:	74 09                	je     800ed0 <__udivdi3+0x100>
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	31 ff                	xor    %edi,%edi
  800ecb:	e9 40 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800ed0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ed3:	31 ff                	xor    %edi,%edi
  800ed5:	e9 36 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__umoddi3>:
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 1c             	sub    $0x1c,%esp
  800eeb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800eef:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ef3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ef7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 19                	jne    800f18 <__umoddi3+0x38>
  800eff:	39 df                	cmp    %ebx,%edi
  800f01:	76 5d                	jbe    800f60 <__umoddi3+0x80>
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	89 da                	mov    %ebx,%edx
  800f07:	f7 f7                	div    %edi
  800f09:	89 d0                	mov    %edx,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	83 c4 1c             	add    $0x1c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	89 f2                	mov    %esi,%edx
  800f1a:	39 d8                	cmp    %ebx,%eax
  800f1c:	76 12                	jbe    800f30 <__umoddi3+0x50>
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	89 da                	mov    %ebx,%edx
  800f22:	83 c4 1c             	add    $0x1c,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	0f bd e8             	bsr    %eax,%ebp
  800f33:	83 f5 1f             	xor    $0x1f,%ebp
  800f36:	75 50                	jne    800f88 <__umoddi3+0xa8>
  800f38:	39 d8                	cmp    %ebx,%eax
  800f3a:	0f 82 e0 00 00 00    	jb     801020 <__umoddi3+0x140>
  800f40:	89 d9                	mov    %ebx,%ecx
  800f42:	39 f7                	cmp    %esi,%edi
  800f44:	0f 86 d6 00 00 00    	jbe    801020 <__umoddi3+0x140>
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	89 ca                	mov    %ecx,%edx
  800f4e:	83 c4 1c             	add    $0x1c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
  800f56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	89 fd                	mov    %edi,%ebp
  800f62:	85 ff                	test   %edi,%edi
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x91>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f7                	div    %edi
  800f6f:	89 c5                	mov    %eax,%ebp
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f5                	div    %ebp
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	f7 f5                	div    %ebp
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	eb 8c                	jmp    800f0d <__umoddi3+0x2d>
  800f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f8f:	29 ea                	sub    %ebp,%edx
  800f91:	d3 e0                	shl    %cl,%eax
  800f93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f97:	89 d1                	mov    %edx,%ecx
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fa9:	09 c1                	or     %eax,%ecx
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fb1:	89 e9                	mov    %ebp,%ecx
  800fb3:	d3 e7                	shl    %cl,%edi
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fbf:	d3 e3                	shl    %cl,%ebx
  800fc1:	89 c7                	mov    %eax,%edi
  800fc3:	89 d1                	mov    %edx,%ecx
  800fc5:	89 f0                	mov    %esi,%eax
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	89 fa                	mov    %edi,%edx
  800fcd:	d3 e6                	shl    %cl,%esi
  800fcf:	09 d8                	or     %ebx,%eax
  800fd1:	f7 74 24 08          	divl   0x8(%esp)
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	89 f3                	mov    %esi,%ebx
  800fd9:	f7 64 24 0c          	mull   0xc(%esp)
  800fdd:	89 c6                	mov    %eax,%esi
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	39 d1                	cmp    %edx,%ecx
  800fe3:	72 06                	jb     800feb <__umoddi3+0x10b>
  800fe5:	75 10                	jne    800ff7 <__umoddi3+0x117>
  800fe7:	39 c3                	cmp    %eax,%ebx
  800fe9:	73 0c                	jae    800ff7 <__umoddi3+0x117>
  800feb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ff3:	89 d7                	mov    %edx,%edi
  800ff5:	89 c6                	mov    %eax,%esi
  800ff7:	89 ca                	mov    %ecx,%edx
  800ff9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffe:	29 f3                	sub    %esi,%ebx
  801000:	19 fa                	sbb    %edi,%edx
  801002:	89 d0                	mov    %edx,%eax
  801004:	d3 e0                	shl    %cl,%eax
  801006:	89 e9                	mov    %ebp,%ecx
  801008:	d3 eb                	shr    %cl,%ebx
  80100a:	d3 ea                	shr    %cl,%edx
  80100c:	09 d8                	or     %ebx,%eax
  80100e:	83 c4 1c             	add    $0x1c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	29 fe                	sub    %edi,%esi
  801022:	19 c3                	sbb    %eax,%ebx
  801024:	89 f2                	mov    %esi,%edx
  801026:	89 d9                	mov    %ebx,%ecx
  801028:	e9 1d ff ff ff       	jmp    800f4a <__umoddi3+0x6a>
