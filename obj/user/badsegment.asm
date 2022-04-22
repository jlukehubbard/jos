
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
  800121:	68 6a 10 80 00       	push   $0x80106a
  800126:	6a 23                	push   $0x23
  800128:	68 87 10 80 00       	push   $0x801087
  80012d:	e8 57 02 00 00       	call   800389 <_panic>

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
  8001ae:	68 6a 10 80 00       	push   $0x80106a
  8001b3:	6a 23                	push   $0x23
  8001b5:	68 87 10 80 00       	push   $0x801087
  8001ba:	e8 ca 01 00 00       	call   800389 <_panic>

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
  8001f4:	68 6a 10 80 00       	push   $0x80106a
  8001f9:	6a 23                	push   $0x23
  8001fb:	68 87 10 80 00       	push   $0x801087
  800200:	e8 84 01 00 00       	call   800389 <_panic>

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
  80023a:	68 6a 10 80 00       	push   $0x80106a
  80023f:	6a 23                	push   $0x23
  800241:	68 87 10 80 00       	push   $0x801087
  800246:	e8 3e 01 00 00       	call   800389 <_panic>

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
  800280:	68 6a 10 80 00       	push   $0x80106a
  800285:	6a 23                	push   $0x23
  800287:	68 87 10 80 00       	push   $0x801087
  80028c:	e8 f8 00 00 00       	call   800389 <_panic>

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
  8002c6:	68 6a 10 80 00       	push   $0x80106a
  8002cb:	6a 23                	push   $0x23
  8002cd:	68 87 10 80 00       	push   $0x801087
  8002d2:	e8 b2 00 00 00       	call   800389 <_panic>

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
  80030c:	68 6a 10 80 00       	push   $0x80106a
  800311:	6a 23                	push   $0x23
  800313:	68 87 10 80 00       	push   $0x801087
  800318:	e8 6c 00 00 00       	call   800389 <_panic>

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
  80034e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800351:	b9 00 00 00 00       	mov    $0x0,%ecx
  800356:	8b 55 08             	mov    0x8(%ebp),%edx
  800359:	b8 0d 00 00 00       	mov    $0xd,%eax
  80035e:	89 cb                	mov    %ecx,%ebx
  800360:	89 cf                	mov    %ecx,%edi
  800362:	89 ce                	mov    %ecx,%esi
  800364:	cd 30                	int    $0x30
	if(check && ret > 0)
  800366:	85 c0                	test   %eax,%eax
  800368:	7f 08                	jg     800372 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800372:	83 ec 0c             	sub    $0xc,%esp
  800375:	50                   	push   %eax
  800376:	6a 0d                	push   $0xd
  800378:	68 6a 10 80 00       	push   $0x80106a
  80037d:	6a 23                	push   $0x23
  80037f:	68 87 10 80 00       	push   $0x801087
  800384:	e8 00 00 00 00       	call   800389 <_panic>

00800389 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800389:	f3 0f 1e fb          	endbr32 
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800392:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800395:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80039b:	e8 92 fd ff ff       	call   800132 <sys_getenvid>
  8003a0:	83 ec 0c             	sub    $0xc,%esp
  8003a3:	ff 75 0c             	pushl  0xc(%ebp)
  8003a6:	ff 75 08             	pushl  0x8(%ebp)
  8003a9:	56                   	push   %esi
  8003aa:	50                   	push   %eax
  8003ab:	68 98 10 80 00       	push   $0x801098
  8003b0:	e8 bb 00 00 00       	call   800470 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b5:	83 c4 18             	add    $0x18,%esp
  8003b8:	53                   	push   %ebx
  8003b9:	ff 75 10             	pushl  0x10(%ebp)
  8003bc:	e8 5a 00 00 00       	call   80041b <vcprintf>
	cprintf("\n");
  8003c1:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  8003c8:	e8 a3 00 00 00       	call   800470 <cprintf>
  8003cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003d0:	cc                   	int3   
  8003d1:	eb fd                	jmp    8003d0 <_panic+0x47>

008003d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003d3:	f3 0f 1e fb          	endbr32 
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	53                   	push   %ebx
  8003db:	83 ec 04             	sub    $0x4,%esp
  8003de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e1:	8b 13                	mov    (%ebx),%edx
  8003e3:	8d 42 01             	lea    0x1(%edx),%eax
  8003e6:	89 03                	mov    %eax,(%ebx)
  8003e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003eb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f4:	74 09                	je     8003ff <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003f6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	68 ff 00 00 00       	push   $0xff
  800407:	8d 43 08             	lea    0x8(%ebx),%eax
  80040a:	50                   	push   %eax
  80040b:	e8 98 fc ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800410:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	eb db                	jmp    8003f6 <putch+0x23>

0080041b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80041b:	f3 0f 1e fb          	endbr32 
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800428:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80042f:	00 00 00 
	b.cnt = 0;
  800432:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800439:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80043c:	ff 75 0c             	pushl  0xc(%ebp)
  80043f:	ff 75 08             	pushl  0x8(%ebp)
  800442:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800448:	50                   	push   %eax
  800449:	68 d3 03 80 00       	push   $0x8003d3
  80044e:	e8 20 01 00 00       	call   800573 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800453:	83 c4 08             	add    $0x8,%esp
  800456:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80045c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800462:	50                   	push   %eax
  800463:	e8 40 fc ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  800468:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80046e:	c9                   	leave  
  80046f:	c3                   	ret    

00800470 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800470:	f3 0f 1e fb          	endbr32 
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80047a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80047d:	50                   	push   %eax
  80047e:	ff 75 08             	pushl  0x8(%ebp)
  800481:	e8 95 ff ff ff       	call   80041b <vcprintf>
	va_end(ap);

	return cnt;
}
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	57                   	push   %edi
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 1c             	sub    $0x1c,%esp
  800491:	89 c7                	mov    %eax,%edi
  800493:	89 d6                	mov    %edx,%esi
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049b:	89 d1                	mov    %edx,%ecx
  80049d:	89 c2                	mov    %eax,%edx
  80049f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b5:	39 c2                	cmp    %eax,%edx
  8004b7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004ba:	72 3e                	jb     8004fa <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004bc:	83 ec 0c             	sub    $0xc,%esp
  8004bf:	ff 75 18             	pushl  0x18(%ebp)
  8004c2:	83 eb 01             	sub    $0x1,%ebx
  8004c5:	53                   	push   %ebx
  8004c6:	50                   	push   %eax
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d6:	e8 15 09 00 00       	call   800df0 <__udivdi3>
  8004db:	83 c4 18             	add    $0x18,%esp
  8004de:	52                   	push   %edx
  8004df:	50                   	push   %eax
  8004e0:	89 f2                	mov    %esi,%edx
  8004e2:	89 f8                	mov    %edi,%eax
  8004e4:	e8 9f ff ff ff       	call   800488 <printnum>
  8004e9:	83 c4 20             	add    $0x20,%esp
  8004ec:	eb 13                	jmp    800501 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	56                   	push   %esi
  8004f2:	ff 75 18             	pushl  0x18(%ebp)
  8004f5:	ff d7                	call   *%edi
  8004f7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004fa:	83 eb 01             	sub    $0x1,%ebx
  8004fd:	85 db                	test   %ebx,%ebx
  8004ff:	7f ed                	jg     8004ee <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	56                   	push   %esi
  800505:	83 ec 04             	sub    $0x4,%esp
  800508:	ff 75 e4             	pushl  -0x1c(%ebp)
  80050b:	ff 75 e0             	pushl  -0x20(%ebp)
  80050e:	ff 75 dc             	pushl  -0x24(%ebp)
  800511:	ff 75 d8             	pushl  -0x28(%ebp)
  800514:	e8 e7 09 00 00       	call   800f00 <__umoddi3>
  800519:	83 c4 14             	add    $0x14,%esp
  80051c:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  800523:	50                   	push   %eax
  800524:	ff d7                	call   *%edi
}
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80052c:	5b                   	pop    %ebx
  80052d:	5e                   	pop    %esi
  80052e:	5f                   	pop    %edi
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800531:	f3 0f 1e fb          	endbr32 
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80053b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80053f:	8b 10                	mov    (%eax),%edx
  800541:	3b 50 04             	cmp    0x4(%eax),%edx
  800544:	73 0a                	jae    800550 <sprintputch+0x1f>
		*b->buf++ = ch;
  800546:	8d 4a 01             	lea    0x1(%edx),%ecx
  800549:	89 08                	mov    %ecx,(%eax)
  80054b:	8b 45 08             	mov    0x8(%ebp),%eax
  80054e:	88 02                	mov    %al,(%edx)
}
  800550:	5d                   	pop    %ebp
  800551:	c3                   	ret    

00800552 <printfmt>:
{
  800552:	f3 0f 1e fb          	endbr32 
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80055c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80055f:	50                   	push   %eax
  800560:	ff 75 10             	pushl  0x10(%ebp)
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	ff 75 08             	pushl  0x8(%ebp)
  800569:	e8 05 00 00 00       	call   800573 <vprintfmt>
}
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	c9                   	leave  
  800572:	c3                   	ret    

00800573 <vprintfmt>:
{
  800573:	f3 0f 1e fb          	endbr32 
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	57                   	push   %edi
  80057b:	56                   	push   %esi
  80057c:	53                   	push   %ebx
  80057d:	83 ec 3c             	sub    $0x3c,%esp
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	8b 7d 10             	mov    0x10(%ebp),%edi
  800589:	e9 4a 03 00 00       	jmp    8008d8 <vprintfmt+0x365>
		padc = ' ';
  80058e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800592:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800599:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005a0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8d 47 01             	lea    0x1(%edi),%eax
  8005af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b2:	0f b6 17             	movzbl (%edi),%edx
  8005b5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005b8:	3c 55                	cmp    $0x55,%al
  8005ba:	0f 87 de 03 00 00    	ja     80099e <vprintfmt+0x42b>
  8005c0:	0f b6 c0             	movzbl %al,%eax
  8005c3:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005ca:	00 
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005ce:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005d2:	eb d8                	jmp    8005ac <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005db:	eb cf                	jmp    8005ac <vprintfmt+0x39>
  8005dd:	0f b6 d2             	movzbl %dl,%edx
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ee:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005f2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005f5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005f8:	83 f9 09             	cmp    $0x9,%ecx
  8005fb:	77 55                	ja     800652 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800600:	eb e9                	jmp    8005eb <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800616:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061a:	79 90                	jns    8005ac <vprintfmt+0x39>
				width = precision, precision = -1;
  80061c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800622:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800629:	eb 81                	jmp    8005ac <vprintfmt+0x39>
  80062b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80062e:	85 c0                	test   %eax,%eax
  800630:	ba 00 00 00 00       	mov    $0x0,%edx
  800635:	0f 49 d0             	cmovns %eax,%edx
  800638:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80063e:	e9 69 ff ff ff       	jmp    8005ac <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800646:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80064d:	e9 5a ff ff ff       	jmp    8005ac <vprintfmt+0x39>
  800652:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800655:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800658:	eb bc                	jmp    800616 <vprintfmt+0xa3>
			lflag++;
  80065a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80065d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800660:	e9 47 ff ff ff       	jmp    8005ac <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 78 04             	lea    0x4(%eax),%edi
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	ff 30                	pushl  (%eax)
  800671:	ff d6                	call   *%esi
			break;
  800673:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800676:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800679:	e9 57 02 00 00       	jmp    8008d5 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 78 04             	lea    0x4(%eax),%edi
  800684:	8b 00                	mov    (%eax),%eax
  800686:	99                   	cltd   
  800687:	31 d0                	xor    %edx,%eax
  800689:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068b:	83 f8 0f             	cmp    $0xf,%eax
  80068e:	7f 23                	jg     8006b3 <vprintfmt+0x140>
  800690:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800697:	85 d2                	test   %edx,%edx
  800699:	74 18                	je     8006b3 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80069b:	52                   	push   %edx
  80069c:	68 de 10 80 00       	push   $0x8010de
  8006a1:	53                   	push   %ebx
  8006a2:	56                   	push   %esi
  8006a3:	e8 aa fe ff ff       	call   800552 <printfmt>
  8006a8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006ab:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006ae:	e9 22 02 00 00       	jmp    8008d5 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006b3:	50                   	push   %eax
  8006b4:	68 d5 10 80 00       	push   $0x8010d5
  8006b9:	53                   	push   %ebx
  8006ba:	56                   	push   %esi
  8006bb:	e8 92 fe ff ff       	call   800552 <printfmt>
  8006c0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006c3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006c6:	e9 0a 02 00 00       	jmp    8008d5 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	83 c0 04             	add    $0x4,%eax
  8006d1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006e0:	0f 45 c2             	cmovne %edx,%eax
  8006e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ea:	7e 06                	jle    8006f2 <vprintfmt+0x17f>
  8006ec:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006f0:	75 0d                	jne    8006ff <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f5:	89 c7                	mov    %eax,%edi
  8006f7:	03 45 e0             	add    -0x20(%ebp),%eax
  8006fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fd:	eb 55                	jmp    800754 <vprintfmt+0x1e1>
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	ff 75 d8             	pushl  -0x28(%ebp)
  800705:	ff 75 cc             	pushl  -0x34(%ebp)
  800708:	e8 45 03 00 00       	call   800a52 <strnlen>
  80070d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800710:	29 c2                	sub    %eax,%edx
  800712:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80071a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80071e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800721:	85 ff                	test   %edi,%edi
  800723:	7e 11                	jle    800736 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	ff 75 e0             	pushl  -0x20(%ebp)
  80072c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80072e:	83 ef 01             	sub    $0x1,%edi
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	eb eb                	jmp    800721 <vprintfmt+0x1ae>
  800736:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800739:	85 d2                	test   %edx,%edx
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	0f 49 c2             	cmovns %edx,%eax
  800743:	29 c2                	sub    %eax,%edx
  800745:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800748:	eb a8                	jmp    8006f2 <vprintfmt+0x17f>
					putch(ch, putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	52                   	push   %edx
  80074f:	ff d6                	call   *%esi
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800757:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800759:	83 c7 01             	add    $0x1,%edi
  80075c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800760:	0f be d0             	movsbl %al,%edx
  800763:	85 d2                	test   %edx,%edx
  800765:	74 4b                	je     8007b2 <vprintfmt+0x23f>
  800767:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80076b:	78 06                	js     800773 <vprintfmt+0x200>
  80076d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800771:	78 1e                	js     800791 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800773:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800777:	74 d1                	je     80074a <vprintfmt+0x1d7>
  800779:	0f be c0             	movsbl %al,%eax
  80077c:	83 e8 20             	sub    $0x20,%eax
  80077f:	83 f8 5e             	cmp    $0x5e,%eax
  800782:	76 c6                	jbe    80074a <vprintfmt+0x1d7>
					putch('?', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 3f                	push   $0x3f
  80078a:	ff d6                	call   *%esi
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	eb c3                	jmp    800754 <vprintfmt+0x1e1>
  800791:	89 cf                	mov    %ecx,%edi
  800793:	eb 0e                	jmp    8007a3 <vprintfmt+0x230>
				putch(' ', putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	53                   	push   %ebx
  800799:	6a 20                	push   $0x20
  80079b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80079d:	83 ef 01             	sub    $0x1,%edi
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	85 ff                	test   %edi,%edi
  8007a5:	7f ee                	jg     800795 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007a7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ad:	e9 23 01 00 00       	jmp    8008d5 <vprintfmt+0x362>
  8007b2:	89 cf                	mov    %ecx,%edi
  8007b4:	eb ed                	jmp    8007a3 <vprintfmt+0x230>
	if (lflag >= 2)
  8007b6:	83 f9 01             	cmp    $0x1,%ecx
  8007b9:	7f 1b                	jg     8007d6 <vprintfmt+0x263>
	else if (lflag)
  8007bb:	85 c9                	test   %ecx,%ecx
  8007bd:	74 63                	je     800822 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8b 00                	mov    (%eax),%eax
  8007c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c7:	99                   	cltd   
  8007c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d4:	eb 17                	jmp    8007ed <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8b 50 04             	mov    0x4(%eax),%edx
  8007dc:	8b 00                	mov    (%eax),%eax
  8007de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 40 08             	lea    0x8(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007ed:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007f3:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007f8:	85 c9                	test   %ecx,%ecx
  8007fa:	0f 89 bb 00 00 00    	jns    8008bb <vprintfmt+0x348>
				putch('-', putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	53                   	push   %ebx
  800804:	6a 2d                	push   $0x2d
  800806:	ff d6                	call   *%esi
				num = -(long long) num;
  800808:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80080b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80080e:	f7 da                	neg    %edx
  800810:	83 d1 00             	adc    $0x0,%ecx
  800813:	f7 d9                	neg    %ecx
  800815:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800818:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081d:	e9 99 00 00 00       	jmp    8008bb <vprintfmt+0x348>
		return va_arg(*ap, int);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 00                	mov    (%eax),%eax
  800827:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082a:	99                   	cltd   
  80082b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80082e:	8b 45 14             	mov    0x14(%ebp),%eax
  800831:	8d 40 04             	lea    0x4(%eax),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)
  800837:	eb b4                	jmp    8007ed <vprintfmt+0x27a>
	if (lflag >= 2)
  800839:	83 f9 01             	cmp    $0x1,%ecx
  80083c:	7f 1b                	jg     800859 <vprintfmt+0x2e6>
	else if (lflag)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	74 2c                	je     80086e <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8b 10                	mov    (%eax),%edx
  800847:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084c:	8d 40 04             	lea    0x4(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800852:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800857:	eb 62                	jmp    8008bb <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	8b 48 04             	mov    0x4(%eax),%ecx
  800861:	8d 40 08             	lea    0x8(%eax),%eax
  800864:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800867:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80086c:	eb 4d                	jmp    8008bb <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 10                	mov    (%eax),%edx
  800873:	b9 00 00 00 00       	mov    $0x0,%ecx
  800878:	8d 40 04             	lea    0x4(%eax),%eax
  80087b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80087e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800883:	eb 36                	jmp    8008bb <vprintfmt+0x348>
	if (lflag >= 2)
  800885:	83 f9 01             	cmp    $0x1,%ecx
  800888:	7f 17                	jg     8008a1 <vprintfmt+0x32e>
	else if (lflag)
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 6e                	je     8008fc <vprintfmt+0x389>
		return va_arg(*ap, long);
  80088e:	8b 45 14             	mov    0x14(%ebp),%eax
  800891:	8b 10                	mov    (%eax),%edx
  800893:	89 d0                	mov    %edx,%eax
  800895:	99                   	cltd   
  800896:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800899:	8d 49 04             	lea    0x4(%ecx),%ecx
  80089c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80089f:	eb 11                	jmp    8008b2 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8b 50 04             	mov    0x4(%eax),%edx
  8008a7:	8b 00                	mov    (%eax),%eax
  8008a9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008ac:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008af:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008b2:	89 d1                	mov    %edx,%ecx
  8008b4:	89 c2                	mov    %eax,%edx
            base = 8;
  8008b6:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008bb:	83 ec 0c             	sub    $0xc,%esp
  8008be:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008c2:	57                   	push   %edi
  8008c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c6:	50                   	push   %eax
  8008c7:	51                   	push   %ecx
  8008c8:	52                   	push   %edx
  8008c9:	89 da                	mov    %ebx,%edx
  8008cb:	89 f0                	mov    %esi,%eax
  8008cd:	e8 b6 fb ff ff       	call   800488 <printnum>
			break;
  8008d2:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d8:	83 c7 01             	add    $0x1,%edi
  8008db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008df:	83 f8 25             	cmp    $0x25,%eax
  8008e2:	0f 84 a6 fc ff ff    	je     80058e <vprintfmt+0x1b>
			if (ch == '\0')
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	0f 84 ce 00 00 00    	je     8009be <vprintfmt+0x44b>
			putch(ch, putdat);
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	53                   	push   %ebx
  8008f4:	50                   	push   %eax
  8008f5:	ff d6                	call   *%esi
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	eb dc                	jmp    8008d8 <vprintfmt+0x365>
		return va_arg(*ap, int);
  8008fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ff:	8b 10                	mov    (%eax),%edx
  800901:	89 d0                	mov    %edx,%eax
  800903:	99                   	cltd   
  800904:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800907:	8d 49 04             	lea    0x4(%ecx),%ecx
  80090a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80090d:	eb a3                	jmp    8008b2 <vprintfmt+0x33f>
			putch('0', putdat);
  80090f:	83 ec 08             	sub    $0x8,%esp
  800912:	53                   	push   %ebx
  800913:	6a 30                	push   $0x30
  800915:	ff d6                	call   *%esi
			putch('x', putdat);
  800917:	83 c4 08             	add    $0x8,%esp
  80091a:	53                   	push   %ebx
  80091b:	6a 78                	push   $0x78
  80091d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8b 10                	mov    (%eax),%edx
  800924:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800929:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80092c:	8d 40 04             	lea    0x4(%eax),%eax
  80092f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800932:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800937:	eb 82                	jmp    8008bb <vprintfmt+0x348>
	if (lflag >= 2)
  800939:	83 f9 01             	cmp    $0x1,%ecx
  80093c:	7f 1e                	jg     80095c <vprintfmt+0x3e9>
	else if (lflag)
  80093e:	85 c9                	test   %ecx,%ecx
  800940:	74 32                	je     800974 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8b 10                	mov    (%eax),%edx
  800947:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094c:	8d 40 04             	lea    0x4(%eax),%eax
  80094f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800952:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800957:	e9 5f ff ff ff       	jmp    8008bb <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80095c:	8b 45 14             	mov    0x14(%ebp),%eax
  80095f:	8b 10                	mov    (%eax),%edx
  800961:	8b 48 04             	mov    0x4(%eax),%ecx
  800964:	8d 40 08             	lea    0x8(%eax),%eax
  800967:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80096a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80096f:	e9 47 ff ff ff       	jmp    8008bb <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800974:	8b 45 14             	mov    0x14(%ebp),%eax
  800977:	8b 10                	mov    (%eax),%edx
  800979:	b9 00 00 00 00       	mov    $0x0,%ecx
  80097e:	8d 40 04             	lea    0x4(%eax),%eax
  800981:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800984:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800989:	e9 2d ff ff ff       	jmp    8008bb <vprintfmt+0x348>
			putch(ch, putdat);
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	53                   	push   %ebx
  800992:	6a 25                	push   $0x25
  800994:	ff d6                	call   *%esi
			break;
  800996:	83 c4 10             	add    $0x10,%esp
  800999:	e9 37 ff ff ff       	jmp    8008d5 <vprintfmt+0x362>
			putch('%', putdat);
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	53                   	push   %ebx
  8009a2:	6a 25                	push   $0x25
  8009a4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a6:	83 c4 10             	add    $0x10,%esp
  8009a9:	89 f8                	mov    %edi,%eax
  8009ab:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009af:	74 05                	je     8009b6 <vprintfmt+0x443>
  8009b1:	83 e8 01             	sub    $0x1,%eax
  8009b4:	eb f5                	jmp    8009ab <vprintfmt+0x438>
  8009b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009b9:	e9 17 ff ff ff       	jmp    8008d5 <vprintfmt+0x362>
}
  8009be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009c6:	f3 0f 1e fb          	endbr32 
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 18             	sub    $0x18,%esp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009d9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009dd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	74 26                	je     800a11 <vsnprintf+0x4b>
  8009eb:	85 d2                	test   %edx,%edx
  8009ed:	7e 22                	jle    800a11 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ef:	ff 75 14             	pushl  0x14(%ebp)
  8009f2:	ff 75 10             	pushl  0x10(%ebp)
  8009f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009f8:	50                   	push   %eax
  8009f9:	68 31 05 80 00       	push   $0x800531
  8009fe:	e8 70 fb ff ff       	call   800573 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a06:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a0c:	83 c4 10             	add    $0x10,%esp
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    
		return -E_INVAL;
  800a11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a16:	eb f7                	jmp    800a0f <vsnprintf+0x49>

00800a18 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a18:	f3 0f 1e fb          	endbr32 
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a22:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a25:	50                   	push   %eax
  800a26:	ff 75 10             	pushl  0x10(%ebp)
  800a29:	ff 75 0c             	pushl  0xc(%ebp)
  800a2c:	ff 75 08             	pushl  0x8(%ebp)
  800a2f:	e8 92 ff ff ff       	call   8009c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a36:	f3 0f 1e fb          	endbr32 
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a49:	74 05                	je     800a50 <strlen+0x1a>
		n++;
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	eb f5                	jmp    800a45 <strlen+0xf>
	return n;
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a52:	f3 0f 1e fb          	endbr32 
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	39 d0                	cmp    %edx,%eax
  800a66:	74 0d                	je     800a75 <strnlen+0x23>
  800a68:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a6c:	74 05                	je     800a73 <strnlen+0x21>
		n++;
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	eb f1                	jmp    800a64 <strnlen+0x12>
  800a73:	89 c2                	mov    %eax,%edx
	return n;
}
  800a75:	89 d0                	mov    %edx,%eax
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a79:	f3 0f 1e fb          	endbr32 
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a90:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	84 d2                	test   %dl,%dl
  800a98:	75 f2                	jne    800a8c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a9a:	89 c8                	mov    %ecx,%eax
  800a9c:	5b                   	pop    %ebx
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a9f:	f3 0f 1e fb          	endbr32 
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 10             	sub    $0x10,%esp
  800aaa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aad:	53                   	push   %ebx
  800aae:	e8 83 ff ff ff       	call   800a36 <strlen>
  800ab3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ab6:	ff 75 0c             	pushl  0xc(%ebp)
  800ab9:	01 d8                	add    %ebx,%eax
  800abb:	50                   	push   %eax
  800abc:	e8 b8 ff ff ff       	call   800a79 <strcpy>
	return dst;
}
  800ac1:	89 d8                	mov    %ebx,%eax
  800ac3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac8:	f3 0f 1e fb          	endbr32 
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800adc:	89 f0                	mov    %esi,%eax
  800ade:	39 d8                	cmp    %ebx,%eax
  800ae0:	74 11                	je     800af3 <strncpy+0x2b>
		*dst++ = *src;
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	0f b6 0a             	movzbl (%edx),%ecx
  800ae8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aeb:	80 f9 01             	cmp    $0x1,%cl
  800aee:	83 da ff             	sbb    $0xffffffff,%edx
  800af1:	eb eb                	jmp    800ade <strncpy+0x16>
	}
	return ret;
}
  800af3:	89 f0                	mov    %esi,%eax
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af9:	f3 0f 1e fb          	endbr32 
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	8b 75 08             	mov    0x8(%ebp),%esi
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b08:	8b 55 10             	mov    0x10(%ebp),%edx
  800b0b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b0d:	85 d2                	test   %edx,%edx
  800b0f:	74 21                	je     800b32 <strlcpy+0x39>
  800b11:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b15:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b17:	39 c2                	cmp    %eax,%edx
  800b19:	74 14                	je     800b2f <strlcpy+0x36>
  800b1b:	0f b6 19             	movzbl (%ecx),%ebx
  800b1e:	84 db                	test   %bl,%bl
  800b20:	74 0b                	je     800b2d <strlcpy+0x34>
			*dst++ = *src++;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	83 c2 01             	add    $0x1,%edx
  800b28:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b2b:	eb ea                	jmp    800b17 <strlcpy+0x1e>
  800b2d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b2f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b32:	29 f0                	sub    %esi,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b38:	f3 0f 1e fb          	endbr32 
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b42:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b45:	0f b6 01             	movzbl (%ecx),%eax
  800b48:	84 c0                	test   %al,%al
  800b4a:	74 0c                	je     800b58 <strcmp+0x20>
  800b4c:	3a 02                	cmp    (%edx),%al
  800b4e:	75 08                	jne    800b58 <strcmp+0x20>
		p++, q++;
  800b50:	83 c1 01             	add    $0x1,%ecx
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	eb ed                	jmp    800b45 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b58:	0f b6 c0             	movzbl %al,%eax
  800b5b:	0f b6 12             	movzbl (%edx),%edx
  800b5e:	29 d0                	sub    %edx,%eax
}
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b62:	f3 0f 1e fb          	endbr32 
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	53                   	push   %ebx
  800b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b70:	89 c3                	mov    %eax,%ebx
  800b72:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b75:	eb 06                	jmp    800b7d <strncmp+0x1b>
		n--, p++, q++;
  800b77:	83 c0 01             	add    $0x1,%eax
  800b7a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b7d:	39 d8                	cmp    %ebx,%eax
  800b7f:	74 16                	je     800b97 <strncmp+0x35>
  800b81:	0f b6 08             	movzbl (%eax),%ecx
  800b84:	84 c9                	test   %cl,%cl
  800b86:	74 04                	je     800b8c <strncmp+0x2a>
  800b88:	3a 0a                	cmp    (%edx),%cl
  800b8a:	74 eb                	je     800b77 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b8c:	0f b6 00             	movzbl (%eax),%eax
  800b8f:	0f b6 12             	movzbl (%edx),%edx
  800b92:	29 d0                	sub    %edx,%eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    
		return 0;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	eb f6                	jmp    800b94 <strncmp+0x32>

00800b9e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b9e:	f3 0f 1e fb          	endbr32 
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bac:	0f b6 10             	movzbl (%eax),%edx
  800baf:	84 d2                	test   %dl,%dl
  800bb1:	74 09                	je     800bbc <strchr+0x1e>
		if (*s == c)
  800bb3:	38 ca                	cmp    %cl,%dl
  800bb5:	74 0a                	je     800bc1 <strchr+0x23>
	for (; *s; s++)
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	eb f0                	jmp    800bac <strchr+0xe>
			return (char *) s;
	return 0;
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc3:	f3 0f 1e fb          	endbr32 
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd4:	38 ca                	cmp    %cl,%dl
  800bd6:	74 09                	je     800be1 <strfind+0x1e>
  800bd8:	84 d2                	test   %dl,%dl
  800bda:	74 05                	je     800be1 <strfind+0x1e>
	for (; *s; s++)
  800bdc:	83 c0 01             	add    $0x1,%eax
  800bdf:	eb f0                	jmp    800bd1 <strfind+0xe>
			break;
	return (char *) s;
}
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be3:	f3 0f 1e fb          	endbr32 
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bf3:	85 c9                	test   %ecx,%ecx
  800bf5:	74 31                	je     800c28 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf7:	89 f8                	mov    %edi,%eax
  800bf9:	09 c8                	or     %ecx,%eax
  800bfb:	a8 03                	test   $0x3,%al
  800bfd:	75 23                	jne    800c22 <memset+0x3f>
		c &= 0xFF;
  800bff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	c1 e3 08             	shl    $0x8,%ebx
  800c08:	89 d0                	mov    %edx,%eax
  800c0a:	c1 e0 18             	shl    $0x18,%eax
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	c1 e6 10             	shl    $0x10,%esi
  800c12:	09 f0                	or     %esi,%eax
  800c14:	09 c2                	or     %eax,%edx
  800c16:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c18:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c1b:	89 d0                	mov    %edx,%eax
  800c1d:	fc                   	cld    
  800c1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c20:	eb 06                	jmp    800c28 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c25:	fc                   	cld    
  800c26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c28:	89 f8                	mov    %edi,%eax
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2f:	f3 0f 1e fb          	endbr32 
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c41:	39 c6                	cmp    %eax,%esi
  800c43:	73 32                	jae    800c77 <memmove+0x48>
  800c45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c48:	39 c2                	cmp    %eax,%edx
  800c4a:	76 2b                	jbe    800c77 <memmove+0x48>
		s += n;
		d += n;
  800c4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4f:	89 fe                	mov    %edi,%esi
  800c51:	09 ce                	or     %ecx,%esi
  800c53:	09 d6                	or     %edx,%esi
  800c55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5b:	75 0e                	jne    800c6b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c5d:	83 ef 04             	sub    $0x4,%edi
  800c60:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c66:	fd                   	std    
  800c67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c69:	eb 09                	jmp    800c74 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c6b:	83 ef 01             	sub    $0x1,%edi
  800c6e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c71:	fd                   	std    
  800c72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c74:	fc                   	cld    
  800c75:	eb 1a                	jmp    800c91 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c77:	89 c2                	mov    %eax,%edx
  800c79:	09 ca                	or     %ecx,%edx
  800c7b:	09 f2                	or     %esi,%edx
  800c7d:	f6 c2 03             	test   $0x3,%dl
  800c80:	75 0a                	jne    800c8c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c82:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c85:	89 c7                	mov    %eax,%edi
  800c87:	fc                   	cld    
  800c88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8a:	eb 05                	jmp    800c91 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	fc                   	cld    
  800c8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c95:	f3 0f 1e fb          	endbr32 
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c9f:	ff 75 10             	pushl  0x10(%ebp)
  800ca2:	ff 75 0c             	pushl  0xc(%ebp)
  800ca5:	ff 75 08             	pushl  0x8(%ebp)
  800ca8:	e8 82 ff ff ff       	call   800c2f <memmove>
}
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800caf:	f3 0f 1e fb          	endbr32 
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbe:	89 c6                	mov    %eax,%esi
  800cc0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc3:	39 f0                	cmp    %esi,%eax
  800cc5:	74 1c                	je     800ce3 <memcmp+0x34>
		if (*s1 != *s2)
  800cc7:	0f b6 08             	movzbl (%eax),%ecx
  800cca:	0f b6 1a             	movzbl (%edx),%ebx
  800ccd:	38 d9                	cmp    %bl,%cl
  800ccf:	75 08                	jne    800cd9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cd1:	83 c0 01             	add    $0x1,%eax
  800cd4:	83 c2 01             	add    $0x1,%edx
  800cd7:	eb ea                	jmp    800cc3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cd9:	0f b6 c1             	movzbl %cl,%eax
  800cdc:	0f b6 db             	movzbl %bl,%ebx
  800cdf:	29 d8                	sub    %ebx,%eax
  800ce1:	eb 05                	jmp    800ce8 <memcmp+0x39>
	}

	return 0;
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cec:	f3 0f 1e fb          	endbr32 
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf9:	89 c2                	mov    %eax,%edx
  800cfb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfe:	39 d0                	cmp    %edx,%eax
  800d00:	73 09                	jae    800d0b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d02:	38 08                	cmp    %cl,(%eax)
  800d04:	74 05                	je     800d0b <memfind+0x1f>
	for (; s < ends; s++)
  800d06:	83 c0 01             	add    $0x1,%eax
  800d09:	eb f3                	jmp    800cfe <memfind+0x12>
			break;
	return (void *) s;
}
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0d:	f3 0f 1e fb          	endbr32 
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1d:	eb 03                	jmp    800d22 <strtol+0x15>
		s++;
  800d1f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d22:	0f b6 01             	movzbl (%ecx),%eax
  800d25:	3c 20                	cmp    $0x20,%al
  800d27:	74 f6                	je     800d1f <strtol+0x12>
  800d29:	3c 09                	cmp    $0x9,%al
  800d2b:	74 f2                	je     800d1f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d2d:	3c 2b                	cmp    $0x2b,%al
  800d2f:	74 2a                	je     800d5b <strtol+0x4e>
	int neg = 0;
  800d31:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d36:	3c 2d                	cmp    $0x2d,%al
  800d38:	74 2b                	je     800d65 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d40:	75 0f                	jne    800d51 <strtol+0x44>
  800d42:	80 39 30             	cmpb   $0x30,(%ecx)
  800d45:	74 28                	je     800d6f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d47:	85 db                	test   %ebx,%ebx
  800d49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4e:	0f 44 d8             	cmove  %eax,%ebx
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d59:	eb 46                	jmp    800da1 <strtol+0x94>
		s++;
  800d5b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d63:	eb d5                	jmp    800d3a <strtol+0x2d>
		s++, neg = 1;
  800d65:	83 c1 01             	add    $0x1,%ecx
  800d68:	bf 01 00 00 00       	mov    $0x1,%edi
  800d6d:	eb cb                	jmp    800d3a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d73:	74 0e                	je     800d83 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d75:	85 db                	test   %ebx,%ebx
  800d77:	75 d8                	jne    800d51 <strtol+0x44>
		s++, base = 8;
  800d79:	83 c1 01             	add    $0x1,%ecx
  800d7c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d81:	eb ce                	jmp    800d51 <strtol+0x44>
		s += 2, base = 16;
  800d83:	83 c1 02             	add    $0x2,%ecx
  800d86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8b:	eb c4                	jmp    800d51 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d8d:	0f be d2             	movsbl %dl,%edx
  800d90:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d96:	7d 3a                	jge    800dd2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d98:	83 c1 01             	add    $0x1,%ecx
  800d9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800da1:	0f b6 11             	movzbl (%ecx),%edx
  800da4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da7:	89 f3                	mov    %esi,%ebx
  800da9:	80 fb 09             	cmp    $0x9,%bl
  800dac:	76 df                	jbe    800d8d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db1:	89 f3                	mov    %esi,%ebx
  800db3:	80 fb 19             	cmp    $0x19,%bl
  800db6:	77 08                	ja     800dc0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800db8:	0f be d2             	movsbl %dl,%edx
  800dbb:	83 ea 57             	sub    $0x57,%edx
  800dbe:	eb d3                	jmp    800d93 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dc0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc3:	89 f3                	mov    %esi,%ebx
  800dc5:	80 fb 19             	cmp    $0x19,%bl
  800dc8:	77 08                	ja     800dd2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dca:	0f be d2             	movsbl %dl,%edx
  800dcd:	83 ea 37             	sub    $0x37,%edx
  800dd0:	eb c1                	jmp    800d93 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd6:	74 05                	je     800ddd <strtol+0xd0>
		*endptr = (char *) s;
  800dd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ddb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ddd:	89 c2                	mov    %eax,%edx
  800ddf:	f7 da                	neg    %edx
  800de1:	85 ff                	test   %edi,%edi
  800de3:	0f 45 c2             	cmovne %edx,%eax
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    
  800deb:	66 90                	xchg   %ax,%ax
  800ded:	66 90                	xchg   %ax,%ax
  800def:	90                   	nop

00800df0 <__udivdi3>:
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 1c             	sub    $0x1c,%esp
  800dfb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e0b:	85 d2                	test   %edx,%edx
  800e0d:	75 19                	jne    800e28 <__udivdi3+0x38>
  800e0f:	39 f3                	cmp    %esi,%ebx
  800e11:	76 4d                	jbe    800e60 <__udivdi3+0x70>
  800e13:	31 ff                	xor    %edi,%edi
  800e15:	89 e8                	mov    %ebp,%eax
  800e17:	89 f2                	mov    %esi,%edx
  800e19:	f7 f3                	div    %ebx
  800e1b:	89 fa                	mov    %edi,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	76 14                	jbe    800e40 <__udivdi3+0x50>
  800e2c:	31 ff                	xor    %edi,%edi
  800e2e:	31 c0                	xor    %eax,%eax
  800e30:	89 fa                	mov    %edi,%edx
  800e32:	83 c4 1c             	add    $0x1c,%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
  800e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e40:	0f bd fa             	bsr    %edx,%edi
  800e43:	83 f7 1f             	xor    $0x1f,%edi
  800e46:	75 48                	jne    800e90 <__udivdi3+0xa0>
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x62>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 de                	ja     800e30 <__udivdi3+0x40>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb d7                	jmp    800e30 <__udivdi3+0x40>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d9                	mov    %ebx,%ecx
  800e62:	85 db                	test   %ebx,%ebx
  800e64:	75 0b                	jne    800e71 <__udivdi3+0x81>
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f3                	div    %ebx
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	31 d2                	xor    %edx,%edx
  800e73:	89 f0                	mov    %esi,%eax
  800e75:	f7 f1                	div    %ecx
  800e77:	89 c6                	mov    %eax,%esi
  800e79:	89 e8                	mov    %ebp,%eax
  800e7b:	89 f7                	mov    %esi,%edi
  800e7d:	f7 f1                	div    %ecx
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	83 c4 1c             	add    $0x1c,%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 f9                	mov    %edi,%ecx
  800e92:	b8 20 00 00 00       	mov    $0x20,%eax
  800e97:	29 f8                	sub    %edi,%eax
  800e99:	d3 e2                	shl    %cl,%edx
  800e9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 da                	mov    %ebx,%edx
  800ea3:	d3 ea                	shr    %cl,%edx
  800ea5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ea9:	09 d1                	or     %edx,%ecx
  800eab:	89 f2                	mov    %esi,%edx
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e3                	shl    %cl,%ebx
  800eb5:	89 c1                	mov    %eax,%ecx
  800eb7:	d3 ea                	shr    %cl,%edx
  800eb9:	89 f9                	mov    %edi,%ecx
  800ebb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ebf:	89 eb                	mov    %ebp,%ebx
  800ec1:	d3 e6                	shl    %cl,%esi
  800ec3:	89 c1                	mov    %eax,%ecx
  800ec5:	d3 eb                	shr    %cl,%ebx
  800ec7:	09 de                	or     %ebx,%esi
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	f7 74 24 08          	divl   0x8(%esp)
  800ecf:	89 d6                	mov    %edx,%esi
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	f7 64 24 0c          	mull   0xc(%esp)
  800ed7:	39 d6                	cmp    %edx,%esi
  800ed9:	72 15                	jb     800ef0 <__udivdi3+0x100>
  800edb:	89 f9                	mov    %edi,%ecx
  800edd:	d3 e5                	shl    %cl,%ebp
  800edf:	39 c5                	cmp    %eax,%ebp
  800ee1:	73 04                	jae    800ee7 <__udivdi3+0xf7>
  800ee3:	39 d6                	cmp    %edx,%esi
  800ee5:	74 09                	je     800ef0 <__udivdi3+0x100>
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	31 ff                	xor    %edi,%edi
  800eeb:	e9 40 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800ef0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ef3:	31 ff                	xor    %edi,%edi
  800ef5:	e9 36 ff ff ff       	jmp    800e30 <__udivdi3+0x40>
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	83 ec 1c             	sub    $0x1c,%esp
  800f0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 19                	jne    800f38 <__umoddi3+0x38>
  800f1f:	39 df                	cmp    %ebx,%edi
  800f21:	76 5d                	jbe    800f80 <__umoddi3+0x80>
  800f23:	89 f0                	mov    %esi,%eax
  800f25:	89 da                	mov    %ebx,%edx
  800f27:	f7 f7                	div    %edi
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	89 f2                	mov    %esi,%edx
  800f3a:	39 d8                	cmp    %ebx,%eax
  800f3c:	76 12                	jbe    800f50 <__umoddi3+0x50>
  800f3e:	89 f0                	mov    %esi,%eax
  800f40:	89 da                	mov    %ebx,%edx
  800f42:	83 c4 1c             	add    $0x1c,%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	0f bd e8             	bsr    %eax,%ebp
  800f53:	83 f5 1f             	xor    $0x1f,%ebp
  800f56:	75 50                	jne    800fa8 <__umoddi3+0xa8>
  800f58:	39 d8                	cmp    %ebx,%eax
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	89 d9                	mov    %ebx,%ecx
  800f62:	39 f7                	cmp    %esi,%edi
  800f64:	0f 86 d6 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f6a:	89 d0                	mov    %edx,%eax
  800f6c:	89 ca                	mov    %ecx,%edx
  800f6e:	83 c4 1c             	add    $0x1c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    
  800f76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	89 fd                	mov    %edi,%ebp
  800f82:	85 ff                	test   %edi,%edi
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 d8                	mov    %ebx,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 f0                	mov    %esi,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	eb 8c                	jmp    800f2d <__umoddi3+0x2d>
  800fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	ba 20 00 00 00       	mov    $0x20,%edx
  800faf:	29 ea                	sub    %ebp,%edx
  800fb1:	d3 e0                	shl    %cl,%eax
  800fb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb7:	89 d1                	mov    %edx,%ecx
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fc9:	09 c1                	or     %eax,%ecx
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 e9                	mov    %ebp,%ecx
  800fd3:	d3 e7                	shl    %cl,%edi
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fdf:	d3 e3                	shl    %cl,%ebx
  800fe1:	89 c7                	mov    %eax,%edi
  800fe3:	89 d1                	mov    %edx,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 fa                	mov    %edi,%edx
  800fed:	d3 e6                	shl    %cl,%esi
  800fef:	09 d8                	or     %ebx,%eax
  800ff1:	f7 74 24 08          	divl   0x8(%esp)
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	89 f3                	mov    %esi,%ebx
  800ff9:	f7 64 24 0c          	mull   0xc(%esp)
  800ffd:	89 c6                	mov    %eax,%esi
  800fff:	89 d7                	mov    %edx,%edi
  801001:	39 d1                	cmp    %edx,%ecx
  801003:	72 06                	jb     80100b <__umoddi3+0x10b>
  801005:	75 10                	jne    801017 <__umoddi3+0x117>
  801007:	39 c3                	cmp    %eax,%ebx
  801009:	73 0c                	jae    801017 <__umoddi3+0x117>
  80100b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80100f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801013:	89 d7                	mov    %edx,%edi
  801015:	89 c6                	mov    %eax,%esi
  801017:	89 ca                	mov    %ecx,%edx
  801019:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101e:	29 f3                	sub    %esi,%ebx
  801020:	19 fa                	sbb    %edi,%edx
  801022:	89 d0                	mov    %edx,%eax
  801024:	d3 e0                	shl    %cl,%eax
  801026:	89 e9                	mov    %ebp,%ecx
  801028:	d3 eb                	shr    %cl,%ebx
  80102a:	d3 ea                	shr    %cl,%edx
  80102c:	09 d8                	or     %ebx,%eax
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 fe                	sub    %edi,%esi
  801042:	19 c3                	sbb    %eax,%ebx
  801044:	89 f2                	mov    %esi,%edx
  801046:	89 d9                	mov    %ebx,%ecx
  801048:	e9 1d ff ff ff       	jmp    800f6a <__umoddi3+0x6a>
