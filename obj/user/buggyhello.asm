
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1a 00 00 00       	call   80004b <libmain>
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
	sys_cputs((char*)1, 1);
  80003d:	6a 01                	push   $0x1
  80003f:	6a 01                	push   $0x1
  800041:	e8 6f 00 00 00       	call   8000b5 <sys_cputs>
}
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	c9                   	leave  
  80004a:	c3                   	ret    

0080004b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004b:	f3 0f 1e fb          	endbr32 
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800057:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800061:	00 00 00 
    envid_t envid = sys_getenvid();
  800064:	e8 d6 00 00 00       	call   80013f <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800069:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 db                	test   %ebx,%ebx
  80007d:	7e 07                	jle    800086 <libmain+0x3b>
		binaryname = argv[0];
  80007f:	8b 06                	mov    (%esi),%eax
  800081:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	56                   	push   %esi
  80008a:	53                   	push   %ebx
  80008b:	e8 a3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800090:	e8 0a 00 00 00       	call   80009f <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009f:	f3 0f 1e fb          	endbr32 
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000a9:	6a 00                	push   $0x0
  8000ab:	e8 4a 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b5:	f3 0f 1e fb          	endbr32 
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	89 c3                	mov    %eax,%ebx
  8000cc:	89 c7                	mov    %eax,%edi
  8000ce:	89 c6                	mov    %eax,%esi
  8000d0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d7:	f3 0f 1e fb          	endbr32 
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	f3 0f 1e fb          	endbr32 
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
  800104:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800107:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	89 cb                	mov    %ecx,%ebx
  800116:	89 cf                	mov    %ecx,%edi
  800118:	89 ce                	mov    %ecx,%esi
  80011a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011c:	85 c0                	test   %eax,%eax
  80011e:	7f 08                	jg     800128 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	50                   	push   %eax
  80012c:	6a 03                	push   $0x3
  80012e:	68 6a 10 80 00       	push   $0x80106a
  800133:	6a 23                	push   $0x23
  800135:	68 87 10 80 00       	push   $0x801087
  80013a:	e8 57 02 00 00       	call   800396 <_panic>

0080013f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013f:	f3 0f 1e fb          	endbr32 
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	f3 0f 1e fb          	endbr32 
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 0b 00 00 00       	mov    $0xb,%eax
  800176:	89 d1                	mov    %edx,%ecx
  800178:	89 d3                	mov    %edx,%ebx
  80017a:	89 d7                	mov    %edx,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800185:	f3 0f 1e fb          	endbr32 
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800192:	be 00 00 00 00       	mov    $0x0,%esi
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019d:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a5:	89 f7                	mov    %esi,%edi
  8001a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	7f 08                	jg     8001b5 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5e                   	pop    %esi
  8001b2:	5f                   	pop    %edi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	50                   	push   %eax
  8001b9:	6a 04                	push   $0x4
  8001bb:	68 6a 10 80 00       	push   $0x80106a
  8001c0:	6a 23                	push   $0x23
  8001c2:	68 87 10 80 00       	push   $0x801087
  8001c7:	e8 ca 01 00 00       	call   800396 <_panic>

008001cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cc:	f3 0f 1e fb          	endbr32 
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001df:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ea:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ed:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ef:	85 c0                	test   %eax,%eax
  8001f1:	7f 08                	jg     8001fb <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f6:	5b                   	pop    %ebx
  8001f7:	5e                   	pop    %esi
  8001f8:	5f                   	pop    %edi
  8001f9:	5d                   	pop    %ebp
  8001fa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fb:	83 ec 0c             	sub    $0xc,%esp
  8001fe:	50                   	push   %eax
  8001ff:	6a 05                	push   $0x5
  800201:	68 6a 10 80 00       	push   $0x80106a
  800206:	6a 23                	push   $0x23
  800208:	68 87 10 80 00       	push   $0x801087
  80020d:	e8 84 01 00 00       	call   800396 <_panic>

00800212 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800212:	f3 0f 1e fb          	endbr32 
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	57                   	push   %edi
  80021a:	56                   	push   %esi
  80021b:	53                   	push   %ebx
  80021c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	b8 06 00 00 00       	mov    $0x6,%eax
  80022f:	89 df                	mov    %ebx,%edi
  800231:	89 de                	mov    %ebx,%esi
  800233:	cd 30                	int    $0x30
	if(check && ret > 0)
  800235:	85 c0                	test   %eax,%eax
  800237:	7f 08                	jg     800241 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023c:	5b                   	pop    %ebx
  80023d:	5e                   	pop    %esi
  80023e:	5f                   	pop    %edi
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	50                   	push   %eax
  800245:	6a 06                	push   $0x6
  800247:	68 6a 10 80 00       	push   $0x80106a
  80024c:	6a 23                	push   $0x23
  80024e:	68 87 10 80 00       	push   $0x801087
  800253:	e8 3e 01 00 00       	call   800396 <_panic>

00800258 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800258:	f3 0f 1e fb          	endbr32 
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800270:	b8 08 00 00 00       	mov    $0x8,%eax
  800275:	89 df                	mov    %ebx,%edi
  800277:	89 de                	mov    %ebx,%esi
  800279:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7f 08                	jg     800287 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800282:	5b                   	pop    %ebx
  800283:	5e                   	pop    %esi
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 08                	push   $0x8
  80028d:	68 6a 10 80 00       	push   $0x80106a
  800292:	6a 23                	push   $0x23
  800294:	68 87 10 80 00       	push   $0x801087
  800299:	e8 f8 00 00 00       	call   800396 <_panic>

0080029e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80029e:	f3 0f 1e fb          	endbr32 
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	b8 09 00 00 00       	mov    $0x9,%eax
  8002bb:	89 df                	mov    %ebx,%edi
  8002bd:	89 de                	mov    %ebx,%esi
  8002bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c1:	85 c0                	test   %eax,%eax
  8002c3:	7f 08                	jg     8002cd <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	50                   	push   %eax
  8002d1:	6a 09                	push   $0x9
  8002d3:	68 6a 10 80 00       	push   $0x80106a
  8002d8:	6a 23                	push   $0x23
  8002da:	68 87 10 80 00       	push   $0x801087
  8002df:	e8 b2 00 00 00       	call   800396 <_panic>

008002e4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e4:	f3 0f 1e fb          	endbr32 
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800301:	89 df                	mov    %ebx,%edi
  800303:	89 de                	mov    %ebx,%esi
  800305:	cd 30                	int    $0x30
	if(check && ret > 0)
  800307:	85 c0                	test   %eax,%eax
  800309:	7f 08                	jg     800313 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800313:	83 ec 0c             	sub    $0xc,%esp
  800316:	50                   	push   %eax
  800317:	6a 0a                	push   $0xa
  800319:	68 6a 10 80 00       	push   $0x80106a
  80031e:	6a 23                	push   $0x23
  800320:	68 87 10 80 00       	push   $0x801087
  800325:	e8 6c 00 00 00       	call   800396 <_panic>

0080032a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80032a:	f3 0f 1e fb          	endbr32 
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
	asm volatile("int %1\n"
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80033f:	be 00 00 00 00       	mov    $0x0,%esi
  800344:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800347:	8b 7d 14             	mov    0x14(%ebp),%edi
  80034a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034c:	5b                   	pop    %ebx
  80034d:	5e                   	pop    %esi
  80034e:	5f                   	pop    %edi
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800351:	f3 0f 1e fb          	endbr32 
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
  80035b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80035e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800363:	8b 55 08             	mov    0x8(%ebp),%edx
  800366:	b8 0d 00 00 00       	mov    $0xd,%eax
  80036b:	89 cb                	mov    %ecx,%ebx
  80036d:	89 cf                	mov    %ecx,%edi
  80036f:	89 ce                	mov    %ecx,%esi
  800371:	cd 30                	int    $0x30
	if(check && ret > 0)
  800373:	85 c0                	test   %eax,%eax
  800375:	7f 08                	jg     80037f <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800377:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	50                   	push   %eax
  800383:	6a 0d                	push   $0xd
  800385:	68 6a 10 80 00       	push   $0x80106a
  80038a:	6a 23                	push   $0x23
  80038c:	68 87 10 80 00       	push   $0x801087
  800391:	e8 00 00 00 00       	call   800396 <_panic>

00800396 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800396:	f3 0f 1e fb          	endbr32 
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	56                   	push   %esi
  80039e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80039f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003a8:	e8 92 fd ff ff       	call   80013f <sys_getenvid>
  8003ad:	83 ec 0c             	sub    $0xc,%esp
  8003b0:	ff 75 0c             	pushl  0xc(%ebp)
  8003b3:	ff 75 08             	pushl  0x8(%ebp)
  8003b6:	56                   	push   %esi
  8003b7:	50                   	push   %eax
  8003b8:	68 98 10 80 00       	push   $0x801098
  8003bd:	e8 bb 00 00 00       	call   80047d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c2:	83 c4 18             	add    $0x18,%esp
  8003c5:	53                   	push   %ebx
  8003c6:	ff 75 10             	pushl  0x10(%ebp)
  8003c9:	e8 5a 00 00 00       	call   800428 <vcprintf>
	cprintf("\n");
  8003ce:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  8003d5:	e8 a3 00 00 00       	call   80047d <cprintf>
  8003da:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003dd:	cc                   	int3   
  8003de:	eb fd                	jmp    8003dd <_panic+0x47>

008003e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e0:	f3 0f 1e fb          	endbr32 
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 04             	sub    $0x4,%esp
  8003eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ee:	8b 13                	mov    (%ebx),%edx
  8003f0:	8d 42 01             	lea    0x1(%edx),%eax
  8003f3:	89 03                	mov    %eax,(%ebx)
  8003f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800401:	74 09                	je     80040c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800403:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800407:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80040c:	83 ec 08             	sub    $0x8,%esp
  80040f:	68 ff 00 00 00       	push   $0xff
  800414:	8d 43 08             	lea    0x8(%ebx),%eax
  800417:	50                   	push   %eax
  800418:	e8 98 fc ff ff       	call   8000b5 <sys_cputs>
		b->idx = 0;
  80041d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	eb db                	jmp    800403 <putch+0x23>

00800428 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800428:	f3 0f 1e fb          	endbr32 
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800435:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043c:	00 00 00 
	b.cnt = 0;
  80043f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800446:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800449:	ff 75 0c             	pushl  0xc(%ebp)
  80044c:	ff 75 08             	pushl  0x8(%ebp)
  80044f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800455:	50                   	push   %eax
  800456:	68 e0 03 80 00       	push   $0x8003e0
  80045b:	e8 20 01 00 00       	call   800580 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800460:	83 c4 08             	add    $0x8,%esp
  800463:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800469:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80046f:	50                   	push   %eax
  800470:	e8 40 fc ff ff       	call   8000b5 <sys_cputs>

	return b.cnt;
}
  800475:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80047b:	c9                   	leave  
  80047c:	c3                   	ret    

0080047d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80047d:	f3 0f 1e fb          	endbr32 
  800481:	55                   	push   %ebp
  800482:	89 e5                	mov    %esp,%ebp
  800484:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800487:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048a:	50                   	push   %eax
  80048b:	ff 75 08             	pushl  0x8(%ebp)
  80048e:	e8 95 ff ff ff       	call   800428 <vcprintf>
	va_end(ap);

	return cnt;
}
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	57                   	push   %edi
  800499:	56                   	push   %esi
  80049a:	53                   	push   %ebx
  80049b:	83 ec 1c             	sub    $0x1c,%esp
  80049e:	89 c7                	mov    %eax,%edi
  8004a0:	89 d6                	mov    %edx,%esi
  8004a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a8:	89 d1                	mov    %edx,%ecx
  8004aa:	89 c2                	mov    %eax,%edx
  8004ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004c2:	39 c2                	cmp    %eax,%edx
  8004c4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004c7:	72 3e                	jb     800507 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	ff 75 18             	pushl  0x18(%ebp)
  8004cf:	83 eb 01             	sub    $0x1,%ebx
  8004d2:	53                   	push   %ebx
  8004d3:	50                   	push   %eax
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004da:	ff 75 e0             	pushl  -0x20(%ebp)
  8004dd:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e3:	e8 18 09 00 00       	call   800e00 <__udivdi3>
  8004e8:	83 c4 18             	add    $0x18,%esp
  8004eb:	52                   	push   %edx
  8004ec:	50                   	push   %eax
  8004ed:	89 f2                	mov    %esi,%edx
  8004ef:	89 f8                	mov    %edi,%eax
  8004f1:	e8 9f ff ff ff       	call   800495 <printnum>
  8004f6:	83 c4 20             	add    $0x20,%esp
  8004f9:	eb 13                	jmp    80050e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	ff 75 18             	pushl  0x18(%ebp)
  800502:	ff d7                	call   *%edi
  800504:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800507:	83 eb 01             	sub    $0x1,%ebx
  80050a:	85 db                	test   %ebx,%ebx
  80050c:	7f ed                	jg     8004fb <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	83 ec 04             	sub    $0x4,%esp
  800515:	ff 75 e4             	pushl  -0x1c(%ebp)
  800518:	ff 75 e0             	pushl  -0x20(%ebp)
  80051b:	ff 75 dc             	pushl  -0x24(%ebp)
  80051e:	ff 75 d8             	pushl  -0x28(%ebp)
  800521:	e8 ea 09 00 00       	call   800f10 <__umoddi3>
  800526:	83 c4 14             	add    $0x14,%esp
  800529:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  800530:	50                   	push   %eax
  800531:	ff d7                	call   *%edi
}
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800539:	5b                   	pop    %ebx
  80053a:	5e                   	pop    %esi
  80053b:	5f                   	pop    %edi
  80053c:	5d                   	pop    %ebp
  80053d:	c3                   	ret    

0080053e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80053e:	f3 0f 1e fb          	endbr32 
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800548:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80054c:	8b 10                	mov    (%eax),%edx
  80054e:	3b 50 04             	cmp    0x4(%eax),%edx
  800551:	73 0a                	jae    80055d <sprintputch+0x1f>
		*b->buf++ = ch;
  800553:	8d 4a 01             	lea    0x1(%edx),%ecx
  800556:	89 08                	mov    %ecx,(%eax)
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	88 02                	mov    %al,(%edx)
}
  80055d:	5d                   	pop    %ebp
  80055e:	c3                   	ret    

0080055f <printfmt>:
{
  80055f:	f3 0f 1e fb          	endbr32 
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800569:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056c:	50                   	push   %eax
  80056d:	ff 75 10             	pushl  0x10(%ebp)
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	ff 75 08             	pushl  0x8(%ebp)
  800576:	e8 05 00 00 00       	call   800580 <vprintfmt>
}
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	c9                   	leave  
  80057f:	c3                   	ret    

00800580 <vprintfmt>:
{
  800580:	f3 0f 1e fb          	endbr32 
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	57                   	push   %edi
  800588:	56                   	push   %esi
  800589:	53                   	push   %ebx
  80058a:	83 ec 3c             	sub    $0x3c,%esp
  80058d:	8b 75 08             	mov    0x8(%ebp),%esi
  800590:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800593:	8b 7d 10             	mov    0x10(%ebp),%edi
  800596:	e9 4a 03 00 00       	jmp    8008e5 <vprintfmt+0x365>
		padc = ' ';
  80059b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80059f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005a6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005b4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8d 47 01             	lea    0x1(%edi),%eax
  8005bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005bf:	0f b6 17             	movzbl (%edi),%edx
  8005c2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005c5:	3c 55                	cmp    $0x55,%al
  8005c7:	0f 87 de 03 00 00    	ja     8009ab <vprintfmt+0x42b>
  8005cd:	0f b6 c0             	movzbl %al,%eax
  8005d0:	3e ff 24 85 00 12 80 	notrack jmp *0x801200(,%eax,4)
  8005d7:	00 
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005db:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005df:	eb d8                	jmp    8005b9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005e8:	eb cf                	jmp    8005b9 <vprintfmt+0x39>
  8005ea:	0f b6 d2             	movzbl %dl,%edx
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005fb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005ff:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800602:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800605:	83 f9 09             	cmp    $0x9,%ecx
  800608:	77 55                	ja     80065f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80060a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80060d:	eb e9                	jmp    8005f8 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 00                	mov    (%eax),%eax
  800614:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 40 04             	lea    0x4(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800623:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800627:	79 90                	jns    8005b9 <vprintfmt+0x39>
				width = precision, precision = -1;
  800629:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800636:	eb 81                	jmp    8005b9 <vprintfmt+0x39>
  800638:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063b:	85 c0                	test   %eax,%eax
  80063d:	ba 00 00 00 00       	mov    $0x0,%edx
  800642:	0f 49 d0             	cmovns %eax,%edx
  800645:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80064b:	e9 69 ff ff ff       	jmp    8005b9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800653:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80065a:	e9 5a ff ff ff       	jmp    8005b9 <vprintfmt+0x39>
  80065f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	eb bc                	jmp    800623 <vprintfmt+0xa3>
			lflag++;
  800667:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80066d:	e9 47 ff ff ff       	jmp    8005b9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 78 04             	lea    0x4(%eax),%edi
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	ff 30                	pushl  (%eax)
  80067e:	ff d6                	call   *%esi
			break;
  800680:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800683:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800686:	e9 57 02 00 00       	jmp    8008e2 <vprintfmt+0x362>
			err = va_arg(ap, int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 78 04             	lea    0x4(%eax),%edi
  800691:	8b 00                	mov    (%eax),%eax
  800693:	99                   	cltd   
  800694:	31 d0                	xor    %edx,%eax
  800696:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800698:	83 f8 0f             	cmp    $0xf,%eax
  80069b:	7f 23                	jg     8006c0 <vprintfmt+0x140>
  80069d:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  8006a4:	85 d2                	test   %edx,%edx
  8006a6:	74 18                	je     8006c0 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8006a8:	52                   	push   %edx
  8006a9:	68 de 10 80 00       	push   $0x8010de
  8006ae:	53                   	push   %ebx
  8006af:	56                   	push   %esi
  8006b0:	e8 aa fe ff ff       	call   80055f <printfmt>
  8006b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006b8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8006bb:	e9 22 02 00 00       	jmp    8008e2 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8006c0:	50                   	push   %eax
  8006c1:	68 d5 10 80 00       	push   $0x8010d5
  8006c6:	53                   	push   %ebx
  8006c7:	56                   	push   %esi
  8006c8:	e8 92 fe ff ff       	call   80055f <printfmt>
  8006cd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006d0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006d3:	e9 0a 02 00 00       	jmp    8008e2 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	83 c0 04             	add    $0x4,%eax
  8006de:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  8006ed:	0f 45 c2             	cmovne %edx,%eax
  8006f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f7:	7e 06                	jle    8006ff <vprintfmt+0x17f>
  8006f9:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006fd:	75 0d                	jne    80070c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800702:	89 c7                	mov    %eax,%edi
  800704:	03 45 e0             	add    -0x20(%ebp),%eax
  800707:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070a:	eb 55                	jmp    800761 <vprintfmt+0x1e1>
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	ff 75 d8             	pushl  -0x28(%ebp)
  800712:	ff 75 cc             	pushl  -0x34(%ebp)
  800715:	e8 45 03 00 00       	call   800a5f <strnlen>
  80071a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80071d:	29 c2                	sub    %eax,%edx
  80071f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800727:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80072b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80072e:	85 ff                	test   %edi,%edi
  800730:	7e 11                	jle    800743 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	ff 75 e0             	pushl  -0x20(%ebp)
  800739:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb eb                	jmp    80072e <vprintfmt+0x1ae>
  800743:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800746:	85 d2                	test   %edx,%edx
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	0f 49 c2             	cmovns %edx,%eax
  800750:	29 c2                	sub    %eax,%edx
  800752:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800755:	eb a8                	jmp    8006ff <vprintfmt+0x17f>
					putch(ch, putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	53                   	push   %ebx
  80075b:	52                   	push   %edx
  80075c:	ff d6                	call   *%esi
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800764:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800766:	83 c7 01             	add    $0x1,%edi
  800769:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076d:	0f be d0             	movsbl %al,%edx
  800770:	85 d2                	test   %edx,%edx
  800772:	74 4b                	je     8007bf <vprintfmt+0x23f>
  800774:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800778:	78 06                	js     800780 <vprintfmt+0x200>
  80077a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80077e:	78 1e                	js     80079e <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800780:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800784:	74 d1                	je     800757 <vprintfmt+0x1d7>
  800786:	0f be c0             	movsbl %al,%eax
  800789:	83 e8 20             	sub    $0x20,%eax
  80078c:	83 f8 5e             	cmp    $0x5e,%eax
  80078f:	76 c6                	jbe    800757 <vprintfmt+0x1d7>
					putch('?', putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 3f                	push   $0x3f
  800797:	ff d6                	call   *%esi
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	eb c3                	jmp    800761 <vprintfmt+0x1e1>
  80079e:	89 cf                	mov    %ecx,%edi
  8007a0:	eb 0e                	jmp    8007b0 <vprintfmt+0x230>
				putch(' ', putdat);
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	6a 20                	push   $0x20
  8007a8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8007aa:	83 ef 01             	sub    $0x1,%edi
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	85 ff                	test   %edi,%edi
  8007b2:	7f ee                	jg     8007a2 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8007b4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ba:	e9 23 01 00 00       	jmp    8008e2 <vprintfmt+0x362>
  8007bf:	89 cf                	mov    %ecx,%edi
  8007c1:	eb ed                	jmp    8007b0 <vprintfmt+0x230>
	if (lflag >= 2)
  8007c3:	83 f9 01             	cmp    $0x1,%ecx
  8007c6:	7f 1b                	jg     8007e3 <vprintfmt+0x263>
	else if (lflag)
  8007c8:	85 c9                	test   %ecx,%ecx
  8007ca:	74 63                	je     80082f <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d4:	99                   	cltd   
  8007d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8d 40 04             	lea    0x4(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e1:	eb 17                	jmp    8007fa <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8b 50 04             	mov    0x4(%eax),%edx
  8007e9:	8b 00                	mov    (%eax),%eax
  8007eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 40 08             	lea    0x8(%eax),%eax
  8007f7:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800800:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800805:	85 c9                	test   %ecx,%ecx
  800807:	0f 89 bb 00 00 00    	jns    8008c8 <vprintfmt+0x348>
				putch('-', putdat);
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	53                   	push   %ebx
  800811:	6a 2d                	push   $0x2d
  800813:	ff d6                	call   *%esi
				num = -(long long) num;
  800815:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800818:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80081b:	f7 da                	neg    %edx
  80081d:	83 d1 00             	adc    $0x0,%ecx
  800820:	f7 d9                	neg    %ecx
  800822:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800825:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082a:	e9 99 00 00 00       	jmp    8008c8 <vprintfmt+0x348>
		return va_arg(*ap, int);
  80082f:	8b 45 14             	mov    0x14(%ebp),%eax
  800832:	8b 00                	mov    (%eax),%eax
  800834:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800837:	99                   	cltd   
  800838:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8d 40 04             	lea    0x4(%eax),%eax
  800841:	89 45 14             	mov    %eax,0x14(%ebp)
  800844:	eb b4                	jmp    8007fa <vprintfmt+0x27a>
	if (lflag >= 2)
  800846:	83 f9 01             	cmp    $0x1,%ecx
  800849:	7f 1b                	jg     800866 <vprintfmt+0x2e6>
	else if (lflag)
  80084b:	85 c9                	test   %ecx,%ecx
  80084d:	74 2c                	je     80087b <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8b 10                	mov    (%eax),%edx
  800854:	b9 00 00 00 00       	mov    $0x0,%ecx
  800859:	8d 40 04             	lea    0x4(%eax),%eax
  80085c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80085f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800864:	eb 62                	jmp    8008c8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8b 10                	mov    (%eax),%edx
  80086b:	8b 48 04             	mov    0x4(%eax),%ecx
  80086e:	8d 40 08             	lea    0x8(%eax),%eax
  800871:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800874:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800879:	eb 4d                	jmp    8008c8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  80087b:	8b 45 14             	mov    0x14(%ebp),%eax
  80087e:	8b 10                	mov    (%eax),%edx
  800880:	b9 00 00 00 00       	mov    $0x0,%ecx
  800885:	8d 40 04             	lea    0x4(%eax),%eax
  800888:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80088b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800890:	eb 36                	jmp    8008c8 <vprintfmt+0x348>
	if (lflag >= 2)
  800892:	83 f9 01             	cmp    $0x1,%ecx
  800895:	7f 17                	jg     8008ae <vprintfmt+0x32e>
	else if (lflag)
  800897:	85 c9                	test   %ecx,%ecx
  800899:	74 6e                	je     800909 <vprintfmt+0x389>
		return va_arg(*ap, long);
  80089b:	8b 45 14             	mov    0x14(%ebp),%eax
  80089e:	8b 10                	mov    (%eax),%edx
  8008a0:	89 d0                	mov    %edx,%eax
  8008a2:	99                   	cltd   
  8008a3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008a6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8008a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008ac:	eb 11                	jmp    8008bf <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8b 50 04             	mov    0x4(%eax),%edx
  8008b4:	8b 00                	mov    (%eax),%eax
  8008b6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8008b9:	8d 49 08             	lea    0x8(%ecx),%ecx
  8008bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8008bf:	89 d1                	mov    %edx,%ecx
  8008c1:	89 c2                	mov    %eax,%edx
            base = 8;
  8008c3:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008c8:	83 ec 0c             	sub    $0xc,%esp
  8008cb:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008cf:	57                   	push   %edi
  8008d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d3:	50                   	push   %eax
  8008d4:	51                   	push   %ecx
  8008d5:	52                   	push   %edx
  8008d6:	89 da                	mov    %ebx,%edx
  8008d8:	89 f0                	mov    %esi,%eax
  8008da:	e8 b6 fb ff ff       	call   800495 <printnum>
			break;
  8008df:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e5:	83 c7 01             	add    $0x1,%edi
  8008e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ec:	83 f8 25             	cmp    $0x25,%eax
  8008ef:	0f 84 a6 fc ff ff    	je     80059b <vprintfmt+0x1b>
			if (ch == '\0')
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	0f 84 ce 00 00 00    	je     8009cb <vprintfmt+0x44b>
			putch(ch, putdat);
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	53                   	push   %ebx
  800901:	50                   	push   %eax
  800902:	ff d6                	call   *%esi
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb dc                	jmp    8008e5 <vprintfmt+0x365>
		return va_arg(*ap, int);
  800909:	8b 45 14             	mov    0x14(%ebp),%eax
  80090c:	8b 10                	mov    (%eax),%edx
  80090e:	89 d0                	mov    %edx,%eax
  800910:	99                   	cltd   
  800911:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800914:	8d 49 04             	lea    0x4(%ecx),%ecx
  800917:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80091a:	eb a3                	jmp    8008bf <vprintfmt+0x33f>
			putch('0', putdat);
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	53                   	push   %ebx
  800920:	6a 30                	push   $0x30
  800922:	ff d6                	call   *%esi
			putch('x', putdat);
  800924:	83 c4 08             	add    $0x8,%esp
  800927:	53                   	push   %ebx
  800928:	6a 78                	push   $0x78
  80092a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8b 10                	mov    (%eax),%edx
  800931:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800936:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800939:	8d 40 04             	lea    0x4(%eax),%eax
  80093c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80093f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800944:	eb 82                	jmp    8008c8 <vprintfmt+0x348>
	if (lflag >= 2)
  800946:	83 f9 01             	cmp    $0x1,%ecx
  800949:	7f 1e                	jg     800969 <vprintfmt+0x3e9>
	else if (lflag)
  80094b:	85 c9                	test   %ecx,%ecx
  80094d:	74 32                	je     800981 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8b 10                	mov    (%eax),%edx
  800954:	b9 00 00 00 00       	mov    $0x0,%ecx
  800959:	8d 40 04             	lea    0x4(%eax),%eax
  80095c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800964:	e9 5f ff ff ff       	jmp    8008c8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  800969:	8b 45 14             	mov    0x14(%ebp),%eax
  80096c:	8b 10                	mov    (%eax),%edx
  80096e:	8b 48 04             	mov    0x4(%eax),%ecx
  800971:	8d 40 08             	lea    0x8(%eax),%eax
  800974:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800977:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80097c:	e9 47 ff ff ff       	jmp    8008c8 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  800981:	8b 45 14             	mov    0x14(%ebp),%eax
  800984:	8b 10                	mov    (%eax),%edx
  800986:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098b:	8d 40 04             	lea    0x4(%eax),%eax
  80098e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800991:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800996:	e9 2d ff ff ff       	jmp    8008c8 <vprintfmt+0x348>
			putch(ch, putdat);
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	53                   	push   %ebx
  80099f:	6a 25                	push   $0x25
  8009a1:	ff d6                	call   *%esi
			break;
  8009a3:	83 c4 10             	add    $0x10,%esp
  8009a6:	e9 37 ff ff ff       	jmp    8008e2 <vprintfmt+0x362>
			putch('%', putdat);
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	53                   	push   %ebx
  8009af:	6a 25                	push   $0x25
  8009b1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009b3:	83 c4 10             	add    $0x10,%esp
  8009b6:	89 f8                	mov    %edi,%eax
  8009b8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009bc:	74 05                	je     8009c3 <vprintfmt+0x443>
  8009be:	83 e8 01             	sub    $0x1,%eax
  8009c1:	eb f5                	jmp    8009b8 <vprintfmt+0x438>
  8009c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009c6:	e9 17 ff ff ff       	jmp    8008e2 <vprintfmt+0x362>
}
  8009cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5f                   	pop    %edi
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d3:	f3 0f 1e fb          	endbr32 
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	83 ec 18             	sub    $0x18,%esp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	74 26                	je     800a1e <vsnprintf+0x4b>
  8009f8:	85 d2                	test   %edx,%edx
  8009fa:	7e 22                	jle    800a1e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009fc:	ff 75 14             	pushl  0x14(%ebp)
  8009ff:	ff 75 10             	pushl  0x10(%ebp)
  800a02:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a05:	50                   	push   %eax
  800a06:	68 3e 05 80 00       	push   $0x80053e
  800a0b:	e8 70 fb ff ff       	call   800580 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a13:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a19:	83 c4 10             	add    $0x10,%esp
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    
		return -E_INVAL;
  800a1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a23:	eb f7                	jmp    800a1c <vsnprintf+0x49>

00800a25 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a25:	f3 0f 1e fb          	endbr32 
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a2f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a32:	50                   	push   %eax
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 92 ff ff ff       	call   8009d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a43:	f3 0f 1e fb          	endbr32 
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a56:	74 05                	je     800a5d <strlen+0x1a>
		n++;
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	eb f5                	jmp    800a52 <strlen+0xf>
	return n;
}
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a5f:	f3 0f 1e fb          	endbr32 
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	39 d0                	cmp    %edx,%eax
  800a73:	74 0d                	je     800a82 <strnlen+0x23>
  800a75:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a79:	74 05                	je     800a80 <strnlen+0x21>
		n++;
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	eb f1                	jmp    800a71 <strnlen+0x12>
  800a80:	89 c2                	mov    %eax,%edx
	return n;
}
  800a82:	89 d0                	mov    %edx,%eax
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a86:	f3 0f 1e fb          	endbr32 
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	53                   	push   %ebx
  800a8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
  800a99:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a9d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800aa0:	83 c0 01             	add    $0x1,%eax
  800aa3:	84 d2                	test   %dl,%dl
  800aa5:	75 f2                	jne    800a99 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800aa7:	89 c8                	mov    %ecx,%eax
  800aa9:	5b                   	pop    %ebx
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aac:	f3 0f 1e fb          	endbr32 
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 10             	sub    $0x10,%esp
  800ab7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aba:	53                   	push   %ebx
  800abb:	e8 83 ff ff ff       	call   800a43 <strlen>
  800ac0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ac3:	ff 75 0c             	pushl  0xc(%ebp)
  800ac6:	01 d8                	add    %ebx,%eax
  800ac8:	50                   	push   %eax
  800ac9:	e8 b8 ff ff ff       	call   800a86 <strcpy>
	return dst;
}
  800ace:	89 d8                	mov    %ebx,%eax
  800ad0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad3:	c9                   	leave  
  800ad4:	c3                   	ret    

00800ad5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ad5:	f3 0f 1e fb          	endbr32 
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae4:	89 f3                	mov    %esi,%ebx
  800ae6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae9:	89 f0                	mov    %esi,%eax
  800aeb:	39 d8                	cmp    %ebx,%eax
  800aed:	74 11                	je     800b00 <strncpy+0x2b>
		*dst++ = *src;
  800aef:	83 c0 01             	add    $0x1,%eax
  800af2:	0f b6 0a             	movzbl (%edx),%ecx
  800af5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af8:	80 f9 01             	cmp    $0x1,%cl
  800afb:	83 da ff             	sbb    $0xffffffff,%edx
  800afe:	eb eb                	jmp    800aeb <strncpy+0x16>
	}
	return ret;
}
  800b00:	89 f0                	mov    %esi,%eax
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b06:	f3 0f 1e fb          	endbr32 
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	8b 75 08             	mov    0x8(%ebp),%esi
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 55 10             	mov    0x10(%ebp),%edx
  800b18:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b1a:	85 d2                	test   %edx,%edx
  800b1c:	74 21                	je     800b3f <strlcpy+0x39>
  800b1e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b22:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b24:	39 c2                	cmp    %eax,%edx
  800b26:	74 14                	je     800b3c <strlcpy+0x36>
  800b28:	0f b6 19             	movzbl (%ecx),%ebx
  800b2b:	84 db                	test   %bl,%bl
  800b2d:	74 0b                	je     800b3a <strlcpy+0x34>
			*dst++ = *src++;
  800b2f:	83 c1 01             	add    $0x1,%ecx
  800b32:	83 c2 01             	add    $0x1,%edx
  800b35:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b38:	eb ea                	jmp    800b24 <strlcpy+0x1e>
  800b3a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b3c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b3f:	29 f0                	sub    %esi,%eax
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b45:	f3 0f 1e fb          	endbr32 
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b52:	0f b6 01             	movzbl (%ecx),%eax
  800b55:	84 c0                	test   %al,%al
  800b57:	74 0c                	je     800b65 <strcmp+0x20>
  800b59:	3a 02                	cmp    (%edx),%al
  800b5b:	75 08                	jne    800b65 <strcmp+0x20>
		p++, q++;
  800b5d:	83 c1 01             	add    $0x1,%ecx
  800b60:	83 c2 01             	add    $0x1,%edx
  800b63:	eb ed                	jmp    800b52 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b65:	0f b6 c0             	movzbl %al,%eax
  800b68:	0f b6 12             	movzbl (%edx),%edx
  800b6b:	29 d0                	sub    %edx,%eax
}
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b6f:	f3 0f 1e fb          	endbr32 
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	53                   	push   %ebx
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7d:	89 c3                	mov    %eax,%ebx
  800b7f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b82:	eb 06                	jmp    800b8a <strncmp+0x1b>
		n--, p++, q++;
  800b84:	83 c0 01             	add    $0x1,%eax
  800b87:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b8a:	39 d8                	cmp    %ebx,%eax
  800b8c:	74 16                	je     800ba4 <strncmp+0x35>
  800b8e:	0f b6 08             	movzbl (%eax),%ecx
  800b91:	84 c9                	test   %cl,%cl
  800b93:	74 04                	je     800b99 <strncmp+0x2a>
  800b95:	3a 0a                	cmp    (%edx),%cl
  800b97:	74 eb                	je     800b84 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b99:	0f b6 00             	movzbl (%eax),%eax
  800b9c:	0f b6 12             	movzbl (%edx),%edx
  800b9f:	29 d0                	sub    %edx,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    
		return 0;
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	eb f6                	jmp    800ba1 <strncmp+0x32>

00800bab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb9:	0f b6 10             	movzbl (%eax),%edx
  800bbc:	84 d2                	test   %dl,%dl
  800bbe:	74 09                	je     800bc9 <strchr+0x1e>
		if (*s == c)
  800bc0:	38 ca                	cmp    %cl,%dl
  800bc2:	74 0a                	je     800bce <strchr+0x23>
	for (; *s; s++)
  800bc4:	83 c0 01             	add    $0x1,%eax
  800bc7:	eb f0                	jmp    800bb9 <strchr+0xe>
			return (char *) s;
	return 0;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bde:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be1:	38 ca                	cmp    %cl,%dl
  800be3:	74 09                	je     800bee <strfind+0x1e>
  800be5:	84 d2                	test   %dl,%dl
  800be7:	74 05                	je     800bee <strfind+0x1e>
	for (; *s; s++)
  800be9:	83 c0 01             	add    $0x1,%eax
  800bec:	eb f0                	jmp    800bde <strfind+0xe>
			break;
	return (char *) s;
}
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c00:	85 c9                	test   %ecx,%ecx
  800c02:	74 31                	je     800c35 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c04:	89 f8                	mov    %edi,%eax
  800c06:	09 c8                	or     %ecx,%eax
  800c08:	a8 03                	test   $0x3,%al
  800c0a:	75 23                	jne    800c2f <memset+0x3f>
		c &= 0xFF;
  800c0c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	c1 e3 08             	shl    $0x8,%ebx
  800c15:	89 d0                	mov    %edx,%eax
  800c17:	c1 e0 18             	shl    $0x18,%eax
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	c1 e6 10             	shl    $0x10,%esi
  800c1f:	09 f0                	or     %esi,%eax
  800c21:	09 c2                	or     %eax,%edx
  800c23:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c25:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c28:	89 d0                	mov    %edx,%eax
  800c2a:	fc                   	cld    
  800c2b:	f3 ab                	rep stos %eax,%es:(%edi)
  800c2d:	eb 06                	jmp    800c35 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	fc                   	cld    
  800c33:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c35:	89 f8                	mov    %edi,%eax
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c3c:	f3 0f 1e fb          	endbr32 
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c4e:	39 c6                	cmp    %eax,%esi
  800c50:	73 32                	jae    800c84 <memmove+0x48>
  800c52:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c55:	39 c2                	cmp    %eax,%edx
  800c57:	76 2b                	jbe    800c84 <memmove+0x48>
		s += n;
		d += n;
  800c59:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5c:	89 fe                	mov    %edi,%esi
  800c5e:	09 ce                	or     %ecx,%esi
  800c60:	09 d6                	or     %edx,%esi
  800c62:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c68:	75 0e                	jne    800c78 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c6a:	83 ef 04             	sub    $0x4,%edi
  800c6d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c70:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c73:	fd                   	std    
  800c74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c76:	eb 09                	jmp    800c81 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c78:	83 ef 01             	sub    $0x1,%edi
  800c7b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c7e:	fd                   	std    
  800c7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c81:	fc                   	cld    
  800c82:	eb 1a                	jmp    800c9e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c84:	89 c2                	mov    %eax,%edx
  800c86:	09 ca                	or     %ecx,%edx
  800c88:	09 f2                	or     %esi,%edx
  800c8a:	f6 c2 03             	test   $0x3,%dl
  800c8d:	75 0a                	jne    800c99 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c8f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c92:	89 c7                	mov    %eax,%edi
  800c94:	fc                   	cld    
  800c95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c97:	eb 05                	jmp    800c9e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c99:	89 c7                	mov    %eax,%edi
  800c9b:	fc                   	cld    
  800c9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cac:	ff 75 10             	pushl  0x10(%ebp)
  800caf:	ff 75 0c             	pushl  0xc(%ebp)
  800cb2:	ff 75 08             	pushl  0x8(%ebp)
  800cb5:	e8 82 ff ff ff       	call   800c3c <memmove>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccb:	89 c6                	mov    %eax,%esi
  800ccd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd0:	39 f0                	cmp    %esi,%eax
  800cd2:	74 1c                	je     800cf0 <memcmp+0x34>
		if (*s1 != *s2)
  800cd4:	0f b6 08             	movzbl (%eax),%ecx
  800cd7:	0f b6 1a             	movzbl (%edx),%ebx
  800cda:	38 d9                	cmp    %bl,%cl
  800cdc:	75 08                	jne    800ce6 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cde:	83 c0 01             	add    $0x1,%eax
  800ce1:	83 c2 01             	add    $0x1,%edx
  800ce4:	eb ea                	jmp    800cd0 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ce6:	0f b6 c1             	movzbl %cl,%eax
  800ce9:	0f b6 db             	movzbl %bl,%ebx
  800cec:	29 d8                	sub    %ebx,%eax
  800cee:	eb 05                	jmp    800cf5 <memcmp+0x39>
	}

	return 0;
  800cf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf9:	f3 0f 1e fb          	endbr32 
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d06:	89 c2                	mov    %eax,%edx
  800d08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d0b:	39 d0                	cmp    %edx,%eax
  800d0d:	73 09                	jae    800d18 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d0f:	38 08                	cmp    %cl,(%eax)
  800d11:	74 05                	je     800d18 <memfind+0x1f>
	for (; s < ends; s++)
  800d13:	83 c0 01             	add    $0x1,%eax
  800d16:	eb f3                	jmp    800d0b <memfind+0x12>
			break;
	return (void *) s;
}
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d1a:	f3 0f 1e fb          	endbr32 
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2a:	eb 03                	jmp    800d2f <strtol+0x15>
		s++;
  800d2c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d2f:	0f b6 01             	movzbl (%ecx),%eax
  800d32:	3c 20                	cmp    $0x20,%al
  800d34:	74 f6                	je     800d2c <strtol+0x12>
  800d36:	3c 09                	cmp    $0x9,%al
  800d38:	74 f2                	je     800d2c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d3a:	3c 2b                	cmp    $0x2b,%al
  800d3c:	74 2a                	je     800d68 <strtol+0x4e>
	int neg = 0;
  800d3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d43:	3c 2d                	cmp    $0x2d,%al
  800d45:	74 2b                	je     800d72 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d47:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d4d:	75 0f                	jne    800d5e <strtol+0x44>
  800d4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800d52:	74 28                	je     800d7c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d54:	85 db                	test   %ebx,%ebx
  800d56:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5b:	0f 44 d8             	cmove  %eax,%ebx
  800d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d63:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d66:	eb 46                	jmp    800dae <strtol+0x94>
		s++;
  800d68:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d70:	eb d5                	jmp    800d47 <strtol+0x2d>
		s++, neg = 1;
  800d72:	83 c1 01             	add    $0x1,%ecx
  800d75:	bf 01 00 00 00       	mov    $0x1,%edi
  800d7a:	eb cb                	jmp    800d47 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d7c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d80:	74 0e                	je     800d90 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d82:	85 db                	test   %ebx,%ebx
  800d84:	75 d8                	jne    800d5e <strtol+0x44>
		s++, base = 8;
  800d86:	83 c1 01             	add    $0x1,%ecx
  800d89:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d8e:	eb ce                	jmp    800d5e <strtol+0x44>
		s += 2, base = 16;
  800d90:	83 c1 02             	add    $0x2,%ecx
  800d93:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d98:	eb c4                	jmp    800d5e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d9a:	0f be d2             	movsbl %dl,%edx
  800d9d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800da0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800da3:	7d 3a                	jge    800ddf <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800da5:	83 c1 01             	add    $0x1,%ecx
  800da8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dac:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800dae:	0f b6 11             	movzbl (%ecx),%edx
  800db1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db4:	89 f3                	mov    %esi,%ebx
  800db6:	80 fb 09             	cmp    $0x9,%bl
  800db9:	76 df                	jbe    800d9a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800dbb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dbe:	89 f3                	mov    %esi,%ebx
  800dc0:	80 fb 19             	cmp    $0x19,%bl
  800dc3:	77 08                	ja     800dcd <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dc5:	0f be d2             	movsbl %dl,%edx
  800dc8:	83 ea 57             	sub    $0x57,%edx
  800dcb:	eb d3                	jmp    800da0 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dcd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dd0:	89 f3                	mov    %esi,%ebx
  800dd2:	80 fb 19             	cmp    $0x19,%bl
  800dd5:	77 08                	ja     800ddf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dd7:	0f be d2             	movsbl %dl,%edx
  800dda:	83 ea 37             	sub    $0x37,%edx
  800ddd:	eb c1                	jmp    800da0 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ddf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de3:	74 05                	je     800dea <strtol+0xd0>
		*endptr = (char *) s;
  800de5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	f7 da                	neg    %edx
  800dee:	85 ff                	test   %edi,%edi
  800df0:	0f 45 c2             	cmovne %edx,%eax
}
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	66 90                	xchg   %ax,%ax
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	66 90                	xchg   %ax,%ax
  800dfe:	66 90                	xchg   %ax,%ax

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
