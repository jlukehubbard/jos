
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	f3 0f 1e fb          	endbr32 
  800046:	55                   	push   %ebp
  800047:	89 e5                	mov    %esp,%ebp
  800049:	56                   	push   %esi
  80004a:	53                   	push   %ebx
  80004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800051:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800058:	00 00 00 
    envid_t envid = sys_getenvid();
  80005b:	e8 de 00 00 00       	call   80013e <sys_getenvid>
    thisenv = &envs[ENVX(envid)];
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 db                	test   %ebx,%ebx
  800074:	7e 07                	jle    80007d <libmain+0x3b>
		binaryname = argv[0];
  800076:	8b 06                	mov    (%esi),%eax
  800078:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	56                   	push   %esi
  800081:	53                   	push   %ebx
  800082:	e8 ac ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800087:	e8 0a 00 00 00       	call   800096 <exit>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5d                   	pop    %ebp
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	f3 0f 1e fb          	endbr32 
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 df 04 00 00       	call   800584 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 4a 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	f3 0f 1e fb          	endbr32 
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c9:	89 c3                	mov    %eax,%ebx
  8000cb:	89 c7                	mov    %eax,%edi
  8000cd:	89 c6                	mov    %eax,%esi
  8000cf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	f3 0f 1e fb          	endbr32 
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800106:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010b:	8b 55 08             	mov    0x8(%ebp),%edx
  80010e:	b8 03 00 00 00       	mov    $0x3,%eax
  800113:	89 cb                	mov    %ecx,%ebx
  800115:	89 cf                	mov    %ecx,%edi
  800117:	89 ce                	mov    %ecx,%esi
  800119:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011b:	85 c0                	test   %eax,%eax
  80011d:	7f 08                	jg     800127 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800127:	83 ec 0c             	sub    $0xc,%esp
  80012a:	50                   	push   %eax
  80012b:	6a 03                	push   $0x3
  80012d:	68 ca 1e 80 00       	push   $0x801eca
  800132:	6a 23                	push   $0x23
  800134:	68 e7 1e 80 00       	push   $0x801ee7
  800139:	e8 70 0f 00 00       	call   8010ae <_panic>

0080013e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013e:	f3 0f 1e fb          	endbr32 
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	57                   	push   %edi
  800146:	56                   	push   %esi
  800147:	53                   	push   %ebx
	asm volatile("int %1\n"
  800148:	ba 00 00 00 00       	mov    $0x0,%edx
  80014d:	b8 02 00 00 00       	mov    $0x2,%eax
  800152:	89 d1                	mov    %edx,%ecx
  800154:	89 d3                	mov    %edx,%ebx
  800156:	89 d7                	mov    %edx,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015c:	5b                   	pop    %ebx
  80015d:	5e                   	pop    %esi
  80015e:	5f                   	pop    %edi
  80015f:	5d                   	pop    %ebp
  800160:	c3                   	ret    

00800161 <sys_yield>:

void
sys_yield(void)
{
  800161:	f3 0f 1e fb          	endbr32 
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 0b 00 00 00       	mov    $0xb,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800184:	f3 0f 1e fb          	endbr32 
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800191:	be 00 00 00 00       	mov    $0x0,%esi
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019c:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a4:	89 f7                	mov    %esi,%edi
  8001a6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	7f 08                	jg     8001b4 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5f                   	pop    %edi
  8001b2:	5d                   	pop    %ebp
  8001b3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	6a 04                	push   $0x4
  8001ba:	68 ca 1e 80 00       	push   $0x801eca
  8001bf:	6a 23                	push   $0x23
  8001c1:	68 e7 1e 80 00       	push   $0x801ee7
  8001c6:	e8 e3 0e 00 00       	call   8010ae <_panic>

008001cb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cb:	f3 0f 1e fb          	endbr32 
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	57                   	push   %edi
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001de:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ec:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f 08                	jg     8001fa <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f5:	5b                   	pop    %ebx
  8001f6:	5e                   	pop    %esi
  8001f7:	5f                   	pop    %edi
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 05                	push   $0x5
  800200:	68 ca 1e 80 00       	push   $0x801eca
  800205:	6a 23                	push   $0x23
  800207:	68 e7 1e 80 00       	push   $0x801ee7
  80020c:	e8 9d 0e 00 00       	call   8010ae <_panic>

00800211 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800211:	f3 0f 1e fb          	endbr32 
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800229:	b8 06 00 00 00       	mov    $0x6,%eax
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7f 08                	jg     800240 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 06                	push   $0x6
  800246:	68 ca 1e 80 00       	push   $0x801eca
  80024b:	6a 23                	push   $0x23
  80024d:	68 e7 1e 80 00       	push   $0x801ee7
  800252:	e8 57 0e 00 00       	call   8010ae <_panic>

00800257 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800257:	f3 0f 1e fb          	endbr32 
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026f:	b8 08 00 00 00       	mov    $0x8,%eax
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7f 08                	jg     800286 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 08                	push   $0x8
  80028c:	68 ca 1e 80 00       	push   $0x801eca
  800291:	6a 23                	push   $0x23
  800293:	68 e7 1e 80 00       	push   $0x801ee7
  800298:	e8 11 0e 00 00       	call   8010ae <_panic>

0080029d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80029d:	f3 0f 1e fb          	endbr32 
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7f 08                	jg     8002cc <sys_env_set_trapframe+0x2f>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 09                	push   $0x9
  8002d2:	68 ca 1e 80 00       	push   $0x801eca
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 e7 1e 80 00       	push   $0x801ee7
  8002de:	e8 cb 0d 00 00       	call   8010ae <_panic>

008002e3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e3:	f3 0f 1e fb          	endbr32 
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800300:	89 df                	mov    %ebx,%edi
  800302:	89 de                	mov    %ebx,%esi
  800304:	cd 30                	int    $0x30
	if(check && ret > 0)
  800306:	85 c0                	test   %eax,%eax
  800308:	7f 08                	jg     800312 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030d:	5b                   	pop    %ebx
  80030e:	5e                   	pop    %esi
  80030f:	5f                   	pop    %edi
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	50                   	push   %eax
  800316:	6a 0a                	push   $0xa
  800318:	68 ca 1e 80 00       	push   $0x801eca
  80031d:	6a 23                	push   $0x23
  80031f:	68 e7 1e 80 00       	push   $0x801ee7
  800324:	e8 85 0d 00 00       	call   8010ae <_panic>

00800329 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800329:	f3 0f 1e fb          	endbr32 
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
	asm volatile("int %1\n"
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800339:	b8 0c 00 00 00       	mov    $0xc,%eax
  80033e:	be 00 00 00 00       	mov    $0x0,%esi
  800343:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800346:	8b 7d 14             	mov    0x14(%ebp),%edi
  800349:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034b:	5b                   	pop    %ebx
  80034c:	5e                   	pop    %esi
  80034d:	5f                   	pop    %edi
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800350:	f3 0f 1e fb          	endbr32 
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	8b 55 08             	mov    0x8(%ebp),%edx
  800365:	b8 0d 00 00 00       	mov    $0xd,%eax
  80036a:	89 cb                	mov    %ecx,%ebx
  80036c:	89 cf                	mov    %ecx,%edi
  80036e:	89 ce                	mov    %ecx,%esi
  800370:	cd 30                	int    $0x30
	if(check && ret > 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	7f 08                	jg     80037e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800376:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800379:	5b                   	pop    %ebx
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80037e:	83 ec 0c             	sub    $0xc,%esp
  800381:	50                   	push   %eax
  800382:	6a 0d                	push   $0xd
  800384:	68 ca 1e 80 00       	push   $0x801eca
  800389:	6a 23                	push   $0x23
  80038b:	68 e7 1e 80 00       	push   $0x801ee7
  800390:	e8 19 0d 00 00       	call   8010ae <_panic>

00800395 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800395:	f3 0f 1e fb          	endbr32 
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80039c:	8b 45 08             	mov    0x8(%ebp),%eax
  80039f:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a4:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a9:	f3 0f 1e fb          	endbr32 
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003bd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c2:	5d                   	pop    %ebp
  8003c3:	c3                   	ret    

008003c4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c4:	f3 0f 1e fb          	endbr32 
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 2d                	je     80040e <fd_alloc+0x4a>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1c                	je     80040e <fd_alloc+0x4a>
  8003f2:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003f7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003fc:	75 d2                	jne    8003d0 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800407:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80040c:	eb 0a                	jmp    800418 <fd_alloc+0x54>
			*fd_store = fd;
  80040e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800411:	89 01                	mov    %eax,(%ecx)
			return 0;
  800413:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041a:	f3 0f 1e fb          	endbr32 
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800424:	83 f8 1f             	cmp    $0x1f,%eax
  800427:	77 30                	ja     800459 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800429:	c1 e0 0c             	shl    $0xc,%eax
  80042c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800431:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	74 24                	je     800460 <fd_lookup+0x46>
  80043c:	89 c2                	mov    %eax,%edx
  80043e:	c1 ea 0c             	shr    $0xc,%edx
  800441:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800448:	f6 c2 01             	test   $0x1,%dl
  80044b:	74 1a                	je     800467 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800450:	89 02                	mov    %eax,(%edx)
	return 0;
  800452:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800457:	5d                   	pop    %ebp
  800458:	c3                   	ret    
		return -E_INVAL;
  800459:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045e:	eb f7                	jmp    800457 <fd_lookup+0x3d>
		return -E_INVAL;
  800460:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800465:	eb f0                	jmp    800457 <fd_lookup+0x3d>
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046c:	eb e9                	jmp    800457 <fd_lookup+0x3d>

0080046e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046e:	f3 0f 1e fb          	endbr32 
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047b:	ba 74 1f 80 00       	mov    $0x801f74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800480:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800485:	39 08                	cmp    %ecx,(%eax)
  800487:	74 33                	je     8004bc <dev_lookup+0x4e>
  800489:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80048c:	8b 02                	mov    (%edx),%eax
  80048e:	85 c0                	test   %eax,%eax
  800490:	75 f3                	jne    800485 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800492:	a1 04 40 80 00       	mov    0x804004,%eax
  800497:	8b 40 48             	mov    0x48(%eax),%eax
  80049a:	83 ec 04             	sub    $0x4,%esp
  80049d:	51                   	push   %ecx
  80049e:	50                   	push   %eax
  80049f:	68 f8 1e 80 00       	push   $0x801ef8
  8004a4:	e8 ec 0c 00 00       	call   801195 <cprintf>
	*dev = 0;
  8004a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    
			*dev = devtab[i];
  8004bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c6:	eb f2                	jmp    8004ba <dev_lookup+0x4c>

008004c8 <fd_close>:
{
  8004c8:	f3 0f 1e fb          	endbr32 
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	57                   	push   %edi
  8004d0:	56                   	push   %esi
  8004d1:	53                   	push   %ebx
  8004d2:	83 ec 24             	sub    $0x24,%esp
  8004d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004de:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004df:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004e5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e8:	50                   	push   %eax
  8004e9:	e8 2c ff ff ff       	call   80041a <fd_lookup>
  8004ee:	89 c3                	mov    %eax,%ebx
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	78 05                	js     8004fc <fd_close+0x34>
	    || fd != fd2)
  8004f7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004fa:	74 16                	je     800512 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8004fc:	89 f8                	mov    %edi,%eax
  8004fe:	84 c0                	test   %al,%al
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 44 d8             	cmove  %eax,%ebx
}
  800508:	89 d8                	mov    %ebx,%eax
  80050a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050d:	5b                   	pop    %ebx
  80050e:	5e                   	pop    %esi
  80050f:	5f                   	pop    %edi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800518:	50                   	push   %eax
  800519:	ff 36                	pushl  (%esi)
  80051b:	e8 4e ff ff ff       	call   80046e <dev_lookup>
  800520:	89 c3                	mov    %eax,%ebx
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	85 c0                	test   %eax,%eax
  800527:	78 1a                	js     800543 <fd_close+0x7b>
		if (dev->dev_close)
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80052f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800534:	85 c0                	test   %eax,%eax
  800536:	74 0b                	je     800543 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800538:	83 ec 0c             	sub    $0xc,%esp
  80053b:	56                   	push   %esi
  80053c:	ff d0                	call   *%eax
  80053e:	89 c3                	mov    %eax,%ebx
  800540:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	6a 00                	push   $0x0
  800549:	e8 c3 fc ff ff       	call   800211 <sys_page_unmap>
	return r;
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	eb b5                	jmp    800508 <fd_close+0x40>

00800553 <close>:

int
close(int fdnum)
{
  800553:	f3 0f 1e fb          	endbr32 
  800557:	55                   	push   %ebp
  800558:	89 e5                	mov    %esp,%ebp
  80055a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80055d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800560:	50                   	push   %eax
  800561:	ff 75 08             	pushl  0x8(%ebp)
  800564:	e8 b1 fe ff ff       	call   80041a <fd_lookup>
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	85 c0                	test   %eax,%eax
  80056e:	79 02                	jns    800572 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800570:	c9                   	leave  
  800571:	c3                   	ret    
		return fd_close(fd, 1);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	6a 01                	push   $0x1
  800577:	ff 75 f4             	pushl  -0xc(%ebp)
  80057a:	e8 49 ff ff ff       	call   8004c8 <fd_close>
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	eb ec                	jmp    800570 <close+0x1d>

00800584 <close_all>:

void
close_all(void)
{
  800584:	f3 0f 1e fb          	endbr32 
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	53                   	push   %ebx
  80058c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80058f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800594:	83 ec 0c             	sub    $0xc,%esp
  800597:	53                   	push   %ebx
  800598:	e8 b6 ff ff ff       	call   800553 <close>
	for (i = 0; i < MAXFD; i++)
  80059d:	83 c3 01             	add    $0x1,%ebx
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	83 fb 20             	cmp    $0x20,%ebx
  8005a6:	75 ec                	jne    800594 <close_all+0x10>
}
  8005a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005ab:	c9                   	leave  
  8005ac:	c3                   	ret    

008005ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ad:	f3 0f 1e fb          	endbr32 
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	57                   	push   %edi
  8005b5:	56                   	push   %esi
  8005b6:	53                   	push   %ebx
  8005b7:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 08             	pushl  0x8(%ebp)
  8005c1:	e8 54 fe ff ff       	call   80041a <fd_lookup>
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	0f 88 81 00 00 00    	js     800654 <dup+0xa7>
		return r;
	close(newfdnum);
  8005d3:	83 ec 0c             	sub    $0xc,%esp
  8005d6:	ff 75 0c             	pushl  0xc(%ebp)
  8005d9:	e8 75 ff ff ff       	call   800553 <close>

	newfd = INDEX2FD(newfdnum);
  8005de:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005e1:	c1 e6 0c             	shl    $0xc,%esi
  8005e4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005ea:	83 c4 04             	add    $0x4,%esp
  8005ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f0:	e8 b4 fd ff ff       	call   8003a9 <fd2data>
  8005f5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005f7:	89 34 24             	mov    %esi,(%esp)
  8005fa:	e8 aa fd ff ff       	call   8003a9 <fd2data>
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800604:	89 d8                	mov    %ebx,%eax
  800606:	c1 e8 16             	shr    $0x16,%eax
  800609:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800610:	a8 01                	test   $0x1,%al
  800612:	74 11                	je     800625 <dup+0x78>
  800614:	89 d8                	mov    %ebx,%eax
  800616:	c1 e8 0c             	shr    $0xc,%eax
  800619:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800620:	f6 c2 01             	test   $0x1,%dl
  800623:	75 39                	jne    80065e <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800628:	89 d0                	mov    %edx,%eax
  80062a:	c1 e8 0c             	shr    $0xc,%eax
  80062d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	25 07 0e 00 00       	and    $0xe07,%eax
  80063c:	50                   	push   %eax
  80063d:	56                   	push   %esi
  80063e:	6a 00                	push   $0x0
  800640:	52                   	push   %edx
  800641:	6a 00                	push   $0x0
  800643:	e8 83 fb ff ff       	call   8001cb <sys_page_map>
  800648:	89 c3                	mov    %eax,%ebx
  80064a:	83 c4 20             	add    $0x20,%esp
  80064d:	85 c0                	test   %eax,%eax
  80064f:	78 31                	js     800682 <dup+0xd5>
		goto err;

	return newfdnum;
  800651:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800654:	89 d8                	mov    %ebx,%eax
  800656:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800659:	5b                   	pop    %ebx
  80065a:	5e                   	pop    %esi
  80065b:	5f                   	pop    %edi
  80065c:	5d                   	pop    %ebp
  80065d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80065e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800665:	83 ec 0c             	sub    $0xc,%esp
  800668:	25 07 0e 00 00       	and    $0xe07,%eax
  80066d:	50                   	push   %eax
  80066e:	57                   	push   %edi
  80066f:	6a 00                	push   $0x0
  800671:	53                   	push   %ebx
  800672:	6a 00                	push   $0x0
  800674:	e8 52 fb ff ff       	call   8001cb <sys_page_map>
  800679:	89 c3                	mov    %eax,%ebx
  80067b:	83 c4 20             	add    $0x20,%esp
  80067e:	85 c0                	test   %eax,%eax
  800680:	79 a3                	jns    800625 <dup+0x78>
	sys_page_unmap(0, newfd);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	56                   	push   %esi
  800686:	6a 00                	push   $0x0
  800688:	e8 84 fb ff ff       	call   800211 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80068d:	83 c4 08             	add    $0x8,%esp
  800690:	57                   	push   %edi
  800691:	6a 00                	push   $0x0
  800693:	e8 79 fb ff ff       	call   800211 <sys_page_unmap>
	return r;
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	eb b7                	jmp    800654 <dup+0xa7>

0080069d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80069d:	f3 0f 1e fb          	endbr32 
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	53                   	push   %ebx
  8006a5:	83 ec 1c             	sub    $0x1c,%esp
  8006a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ae:	50                   	push   %eax
  8006af:	53                   	push   %ebx
  8006b0:	e8 65 fd ff ff       	call   80041a <fd_lookup>
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	78 3f                	js     8006fb <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c6:	ff 30                	pushl  (%eax)
  8006c8:	e8 a1 fd ff ff       	call   80046e <dev_lookup>
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	78 27                	js     8006fb <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006d7:	8b 42 08             	mov    0x8(%edx),%eax
  8006da:	83 e0 03             	and    $0x3,%eax
  8006dd:	83 f8 01             	cmp    $0x1,%eax
  8006e0:	74 1e                	je     800700 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e5:	8b 40 08             	mov    0x8(%eax),%eax
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 35                	je     800721 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ec:	83 ec 04             	sub    $0x4,%esp
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff d0                	call   *%eax
  8006f8:	83 c4 10             	add    $0x10,%esp
}
  8006fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800700:	a1 04 40 80 00       	mov    0x804004,%eax
  800705:	8b 40 48             	mov    0x48(%eax),%eax
  800708:	83 ec 04             	sub    $0x4,%esp
  80070b:	53                   	push   %ebx
  80070c:	50                   	push   %eax
  80070d:	68 39 1f 80 00       	push   $0x801f39
  800712:	e8 7e 0a 00 00       	call   801195 <cprintf>
		return -E_INVAL;
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071f:	eb da                	jmp    8006fb <read+0x5e>
		return -E_NOT_SUPP;
  800721:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800726:	eb d3                	jmp    8006fb <read+0x5e>

00800728 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800728:	f3 0f 1e fb          	endbr32 
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	57                   	push   %edi
  800730:	56                   	push   %esi
  800731:	53                   	push   %ebx
  800732:	83 ec 0c             	sub    $0xc,%esp
  800735:	8b 7d 08             	mov    0x8(%ebp),%edi
  800738:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80073b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800740:	eb 02                	jmp    800744 <readn+0x1c>
  800742:	01 c3                	add    %eax,%ebx
  800744:	39 f3                	cmp    %esi,%ebx
  800746:	73 21                	jae    800769 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800748:	83 ec 04             	sub    $0x4,%esp
  80074b:	89 f0                	mov    %esi,%eax
  80074d:	29 d8                	sub    %ebx,%eax
  80074f:	50                   	push   %eax
  800750:	89 d8                	mov    %ebx,%eax
  800752:	03 45 0c             	add    0xc(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	57                   	push   %edi
  800757:	e8 41 ff ff ff       	call   80069d <read>
		if (m < 0)
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	85 c0                	test   %eax,%eax
  800761:	78 04                	js     800767 <readn+0x3f>
			return m;
		if (m == 0)
  800763:	75 dd                	jne    800742 <readn+0x1a>
  800765:	eb 02                	jmp    800769 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800767:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800769:	89 d8                	mov    %ebx,%eax
  80076b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5f                   	pop    %edi
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800773:	f3 0f 1e fb          	endbr32 
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800781:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800784:	50                   	push   %eax
  800785:	53                   	push   %ebx
  800786:	e8 8f fc ff ff       	call   80041a <fd_lookup>
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	85 c0                	test   %eax,%eax
  800790:	78 3a                	js     8007cc <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800798:	50                   	push   %eax
  800799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079c:	ff 30                	pushl  (%eax)
  80079e:	e8 cb fc ff ff       	call   80046e <dev_lookup>
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 22                	js     8007cc <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007b1:	74 1e                	je     8007d1 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b6:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	74 35                	je     8007f2 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007bd:	83 ec 04             	sub    $0x4,%esp
  8007c0:	ff 75 10             	pushl  0x10(%ebp)
  8007c3:	ff 75 0c             	pushl  0xc(%ebp)
  8007c6:	50                   	push   %eax
  8007c7:	ff d2                	call   *%edx
  8007c9:	83 c4 10             	add    $0x10,%esp
}
  8007cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8007d6:	8b 40 48             	mov    0x48(%eax),%eax
  8007d9:	83 ec 04             	sub    $0x4,%esp
  8007dc:	53                   	push   %ebx
  8007dd:	50                   	push   %eax
  8007de:	68 55 1f 80 00       	push   $0x801f55
  8007e3:	e8 ad 09 00 00       	call   801195 <cprintf>
		return -E_INVAL;
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f0:	eb da                	jmp    8007cc <write+0x59>
		return -E_NOT_SUPP;
  8007f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007f7:	eb d3                	jmp    8007cc <write+0x59>

008007f9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f9:	f3 0f 1e fb          	endbr32 
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800803:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800806:	50                   	push   %eax
  800807:	ff 75 08             	pushl  0x8(%ebp)
  80080a:	e8 0b fc ff ff       	call   80041a <fd_lookup>
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	85 c0                	test   %eax,%eax
  800814:	78 0e                	js     800824 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800824:	c9                   	leave  
  800825:	c3                   	ret    

00800826 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800826:	f3 0f 1e fb          	endbr32 
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	83 ec 1c             	sub    $0x1c,%esp
  800831:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800834:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800837:	50                   	push   %eax
  800838:	53                   	push   %ebx
  800839:	e8 dc fb ff ff       	call   80041a <fd_lookup>
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	85 c0                	test   %eax,%eax
  800843:	78 37                	js     80087c <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084b:	50                   	push   %eax
  80084c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084f:	ff 30                	pushl  (%eax)
  800851:	e8 18 fc ff ff       	call   80046e <dev_lookup>
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	85 c0                	test   %eax,%eax
  80085b:	78 1f                	js     80087c <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80085d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800860:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800864:	74 1b                	je     800881 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800866:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800869:	8b 52 18             	mov    0x18(%edx),%edx
  80086c:	85 d2                	test   %edx,%edx
  80086e:	74 32                	je     8008a2 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	ff 75 0c             	pushl  0xc(%ebp)
  800876:	50                   	push   %eax
  800877:	ff d2                	call   *%edx
  800879:	83 c4 10             	add    $0x10,%esp
}
  80087c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087f:	c9                   	leave  
  800880:	c3                   	ret    
			thisenv->env_id, fdnum);
  800881:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800886:	8b 40 48             	mov    0x48(%eax),%eax
  800889:	83 ec 04             	sub    $0x4,%esp
  80088c:	53                   	push   %ebx
  80088d:	50                   	push   %eax
  80088e:	68 18 1f 80 00       	push   $0x801f18
  800893:	e8 fd 08 00 00       	call   801195 <cprintf>
		return -E_INVAL;
  800898:	83 c4 10             	add    $0x10,%esp
  80089b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a0:	eb da                	jmp    80087c <ftruncate+0x56>
		return -E_NOT_SUPP;
  8008a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a7:	eb d3                	jmp    80087c <ftruncate+0x56>

008008a9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a9:	f3 0f 1e fb          	endbr32 
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	53                   	push   %ebx
  8008b1:	83 ec 1c             	sub    $0x1c,%esp
  8008b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ba:	50                   	push   %eax
  8008bb:	ff 75 08             	pushl  0x8(%ebp)
  8008be:	e8 57 fb ff ff       	call   80041a <fd_lookup>
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	85 c0                	test   %eax,%eax
  8008c8:	78 4b                	js     800915 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d0:	50                   	push   %eax
  8008d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d4:	ff 30                	pushl  (%eax)
  8008d6:	e8 93 fb ff ff       	call   80046e <dev_lookup>
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	85 c0                	test   %eax,%eax
  8008e0:	78 33                	js     800915 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8008e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e9:	74 2f                	je     80091a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008eb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ee:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008f5:	00 00 00 
	stat->st_isdir = 0;
  8008f8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ff:	00 00 00 
	stat->st_dev = dev;
  800902:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	53                   	push   %ebx
  80090c:	ff 75 f0             	pushl  -0x10(%ebp)
  80090f:	ff 50 14             	call   *0x14(%eax)
  800912:	83 c4 10             	add    $0x10,%esp
}
  800915:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800918:	c9                   	leave  
  800919:	c3                   	ret    
		return -E_NOT_SUPP;
  80091a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80091f:	eb f4                	jmp    800915 <fstat+0x6c>

00800921 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800921:	f3 0f 1e fb          	endbr32 
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80092a:	83 ec 08             	sub    $0x8,%esp
  80092d:	6a 00                	push   $0x0
  80092f:	ff 75 08             	pushl  0x8(%ebp)
  800932:	e8 cf 01 00 00       	call   800b06 <open>
  800937:	89 c3                	mov    %eax,%ebx
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	85 c0                	test   %eax,%eax
  80093e:	78 1b                	js     80095b <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800940:	83 ec 08             	sub    $0x8,%esp
  800943:	ff 75 0c             	pushl  0xc(%ebp)
  800946:	50                   	push   %eax
  800947:	e8 5d ff ff ff       	call   8008a9 <fstat>
  80094c:	89 c6                	mov    %eax,%esi
	close(fd);
  80094e:	89 1c 24             	mov    %ebx,(%esp)
  800951:	e8 fd fb ff ff       	call   800553 <close>
	return r;
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	89 f3                	mov    %esi,%ebx
}
  80095b:	89 d8                	mov    %ebx,%eax
  80095d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	89 c6                	mov    %eax,%esi
  80096b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80096d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800974:	74 27                	je     80099d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800976:	6a 07                	push   $0x7
  800978:	68 00 50 80 00       	push   $0x805000
  80097d:	56                   	push   %esi
  80097e:	ff 35 00 40 80 00    	pushl  0x804000
  800984:	e8 de 11 00 00       	call   801b67 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800989:	83 c4 0c             	add    $0xc,%esp
  80098c:	6a 00                	push   $0x0
  80098e:	53                   	push   %ebx
  80098f:	6a 00                	push   $0x0
  800991:	e8 7a 11 00 00       	call   801b10 <ipc_recv>
}
  800996:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80099d:	83 ec 0c             	sub    $0xc,%esp
  8009a0:	6a 01                	push   $0x1
  8009a2:	e8 26 12 00 00       	call   801bcd <ipc_find_env>
  8009a7:	a3 00 40 80 00       	mov    %eax,0x804000
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	eb c5                	jmp    800976 <fsipc+0x12>

008009b1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009b1:	f3 0f 1e fb          	endbr32 
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d8:	e8 87 ff ff ff       	call   800964 <fsipc>
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <devfile_flush>:
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ef:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8009fe:	e8 61 ff ff ff       	call   800964 <fsipc>
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <devfile_stat>:
{
  800a05:	f3 0f 1e fb          	endbr32 
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	53                   	push   %ebx
  800a0d:	83 ec 04             	sub    $0x4,%esp
  800a10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 40 0c             	mov    0xc(%eax),%eax
  800a19:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	b8 05 00 00 00       	mov    $0x5,%eax
  800a28:	e8 37 ff ff ff       	call   800964 <fsipc>
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	78 2c                	js     800a5d <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	68 00 50 80 00       	push   $0x805000
  800a39:	53                   	push   %ebx
  800a3a:	e8 5f 0d 00 00       	call   80179e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a3f:	a1 80 50 80 00       	mov    0x805080,%eax
  800a44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a4a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a4f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a55:	83 c4 10             	add    $0x10,%esp
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <devfile_write>:
{
  800a62:	f3 0f 1e fb          	endbr32 
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	83 ec 0c             	sub    $0xc,%esp
	panic("devfile_write not implemented");
  800a6c:	68 84 1f 80 00       	push   $0x801f84
  800a71:	68 90 00 00 00       	push   $0x90
  800a76:	68 a2 1f 80 00       	push   $0x801fa2
  800a7b:	e8 2e 06 00 00       	call   8010ae <_panic>

00800a80 <devfile_read>:
{
  800a80:	f3 0f 1e fb          	endbr32 
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a92:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a97:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa2:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa7:	e8 b8 fe ff ff       	call   800964 <fsipc>
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	85 c0                	test   %eax,%eax
  800ab0:	78 1f                	js     800ad1 <devfile_read+0x51>
	assert(r <= n);
  800ab2:	39 f0                	cmp    %esi,%eax
  800ab4:	77 24                	ja     800ada <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ab6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800abb:	7f 33                	jg     800af0 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800abd:	83 ec 04             	sub    $0x4,%esp
  800ac0:	50                   	push   %eax
  800ac1:	68 00 50 80 00       	push   $0x805000
  800ac6:	ff 75 0c             	pushl  0xc(%ebp)
  800ac9:	e8 86 0e 00 00       	call   801954 <memmove>
	return r;
  800ace:	83 c4 10             	add    $0x10,%esp
}
  800ad1:	89 d8                	mov    %ebx,%eax
  800ad3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    
	assert(r <= n);
  800ada:	68 ad 1f 80 00       	push   $0x801fad
  800adf:	68 b4 1f 80 00       	push   $0x801fb4
  800ae4:	6a 7c                	push   $0x7c
  800ae6:	68 a2 1f 80 00       	push   $0x801fa2
  800aeb:	e8 be 05 00 00       	call   8010ae <_panic>
	assert(r <= PGSIZE);
  800af0:	68 c9 1f 80 00       	push   $0x801fc9
  800af5:	68 b4 1f 80 00       	push   $0x801fb4
  800afa:	6a 7d                	push   $0x7d
  800afc:	68 a2 1f 80 00       	push   $0x801fa2
  800b01:	e8 a8 05 00 00       	call   8010ae <_panic>

00800b06 <open>:
{
  800b06:	f3 0f 1e fb          	endbr32 
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	83 ec 1c             	sub    $0x1c,%esp
  800b12:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b15:	56                   	push   %esi
  800b16:	e8 40 0c 00 00       	call   80175b <strlen>
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b23:	7f 6c                	jg     800b91 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b25:	83 ec 0c             	sub    $0xc,%esp
  800b28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2b:	50                   	push   %eax
  800b2c:	e8 93 f8 ff ff       	call   8003c4 <fd_alloc>
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	83 c4 10             	add    $0x10,%esp
  800b36:	85 c0                	test   %eax,%eax
  800b38:	78 3c                	js     800b76 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b3a:	83 ec 08             	sub    $0x8,%esp
  800b3d:	56                   	push   %esi
  800b3e:	68 00 50 80 00       	push   $0x805000
  800b43:	e8 56 0c 00 00       	call   80179e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b53:	b8 01 00 00 00       	mov    $0x1,%eax
  800b58:	e8 07 fe ff ff       	call   800964 <fsipc>
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	83 c4 10             	add    $0x10,%esp
  800b62:	85 c0                	test   %eax,%eax
  800b64:	78 19                	js     800b7f <open+0x79>
	return fd2num(fd);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6c:	e8 24 f8 ff ff       	call   800395 <fd2num>
  800b71:	89 c3                	mov    %eax,%ebx
  800b73:	83 c4 10             	add    $0x10,%esp
}
  800b76:	89 d8                	mov    %ebx,%eax
  800b78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    
		fd_close(fd, 0);
  800b7f:	83 ec 08             	sub    $0x8,%esp
  800b82:	6a 00                	push   $0x0
  800b84:	ff 75 f4             	pushl  -0xc(%ebp)
  800b87:	e8 3c f9 ff ff       	call   8004c8 <fd_close>
		return r;
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	eb e5                	jmp    800b76 <open+0x70>
		return -E_BAD_PATH;
  800b91:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b96:	eb de                	jmp    800b76 <open+0x70>

00800b98 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b98:	f3 0f 1e fb          	endbr32 
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bac:	e8 b3 fd ff ff       	call   800964 <fsipc>
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	ff 75 08             	pushl  0x8(%ebp)
  800bc5:	e8 df f7 ff ff       	call   8003a9 <fd2data>
  800bca:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bcc:	83 c4 08             	add    $0x8,%esp
  800bcf:	68 d5 1f 80 00       	push   $0x801fd5
  800bd4:	53                   	push   %ebx
  800bd5:	e8 c4 0b 00 00       	call   80179e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bda:	8b 46 04             	mov    0x4(%esi),%eax
  800bdd:	2b 06                	sub    (%esi),%eax
  800bdf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800be5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bec:	00 00 00 
	stat->st_dev = &devpipe;
  800bef:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bf6:	30 80 00 
	return 0;
}
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c05:	f3 0f 1e fb          	endbr32 
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c13:	53                   	push   %ebx
  800c14:	6a 00                	push   $0x0
  800c16:	e8 f6 f5 ff ff       	call   800211 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c1b:	89 1c 24             	mov    %ebx,(%esp)
  800c1e:	e8 86 f7 ff ff       	call   8003a9 <fd2data>
  800c23:	83 c4 08             	add    $0x8,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 00                	push   $0x0
  800c29:	e8 e3 f5 ff ff       	call   800211 <sys_page_unmap>
}
  800c2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <_pipeisclosed>:
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 1c             	sub    $0x1c,%esp
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c40:	a1 04 40 80 00       	mov    0x804004,%eax
  800c45:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	57                   	push   %edi
  800c4c:	e8 b9 0f 00 00       	call   801c0a <pageref>
  800c51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c54:	89 34 24             	mov    %esi,(%esp)
  800c57:	e8 ae 0f 00 00       	call   801c0a <pageref>
		nn = thisenv->env_runs;
  800c5c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c62:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c65:	83 c4 10             	add    $0x10,%esp
  800c68:	39 cb                	cmp    %ecx,%ebx
  800c6a:	74 1b                	je     800c87 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c6c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c6f:	75 cf                	jne    800c40 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c71:	8b 42 58             	mov    0x58(%edx),%eax
  800c74:	6a 01                	push   $0x1
  800c76:	50                   	push   %eax
  800c77:	53                   	push   %ebx
  800c78:	68 dc 1f 80 00       	push   $0x801fdc
  800c7d:	e8 13 05 00 00       	call   801195 <cprintf>
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	eb b9                	jmp    800c40 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c87:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c8a:	0f 94 c0             	sete   %al
  800c8d:	0f b6 c0             	movzbl %al,%eax
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <devpipe_write>:
{
  800c98:	f3 0f 1e fb          	endbr32 
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 28             	sub    $0x28,%esp
  800ca5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ca8:	56                   	push   %esi
  800ca9:	e8 fb f6 ff ff       	call   8003a9 <fd2data>
  800cae:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cbb:	74 4f                	je     800d0c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbd:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc0:	8b 0b                	mov    (%ebx),%ecx
  800cc2:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc5:	39 d0                	cmp    %edx,%eax
  800cc7:	72 14                	jb     800cdd <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cc9:	89 da                	mov    %ebx,%edx
  800ccb:	89 f0                	mov    %esi,%eax
  800ccd:	e8 61 ff ff ff       	call   800c33 <_pipeisclosed>
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	75 3b                	jne    800d11 <devpipe_write+0x79>
			sys_yield();
  800cd6:	e8 86 f4 ff ff       	call   800161 <sys_yield>
  800cdb:	eb e0                	jmp    800cbd <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ce4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ce7:	89 c2                	mov    %eax,%edx
  800ce9:	c1 fa 1f             	sar    $0x1f,%edx
  800cec:	89 d1                	mov    %edx,%ecx
  800cee:	c1 e9 1b             	shr    $0x1b,%ecx
  800cf1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cf4:	83 e2 1f             	and    $0x1f,%edx
  800cf7:	29 ca                	sub    %ecx,%edx
  800cf9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cfd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d01:	83 c0 01             	add    $0x1,%eax
  800d04:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d07:	83 c7 01             	add    $0x1,%edi
  800d0a:	eb ac                	jmp    800cb8 <devpipe_write+0x20>
	return i;
  800d0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0f:	eb 05                	jmp    800d16 <devpipe_write+0x7e>
				return 0;
  800d11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <devpipe_read>:
{
  800d1e:	f3 0f 1e fb          	endbr32 
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 18             	sub    $0x18,%esp
  800d2b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d2e:	57                   	push   %edi
  800d2f:	e8 75 f6 ff ff       	call   8003a9 <fd2data>
  800d34:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	be 00 00 00 00       	mov    $0x0,%esi
  800d3e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d41:	75 14                	jne    800d57 <devpipe_read+0x39>
	return i;
  800d43:	8b 45 10             	mov    0x10(%ebp),%eax
  800d46:	eb 02                	jmp    800d4a <devpipe_read+0x2c>
				return i;
  800d48:	89 f0                	mov    %esi,%eax
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
			sys_yield();
  800d52:	e8 0a f4 ff ff       	call   800161 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d57:	8b 03                	mov    (%ebx),%eax
  800d59:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d5c:	75 18                	jne    800d76 <devpipe_read+0x58>
			if (i > 0)
  800d5e:	85 f6                	test   %esi,%esi
  800d60:	75 e6                	jne    800d48 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d62:	89 da                	mov    %ebx,%edx
  800d64:	89 f8                	mov    %edi,%eax
  800d66:	e8 c8 fe ff ff       	call   800c33 <_pipeisclosed>
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	74 e3                	je     800d52 <devpipe_read+0x34>
				return 0;
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d74:	eb d4                	jmp    800d4a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d76:	99                   	cltd   
  800d77:	c1 ea 1b             	shr    $0x1b,%edx
  800d7a:	01 d0                	add    %edx,%eax
  800d7c:	83 e0 1f             	and    $0x1f,%eax
  800d7f:	29 d0                	sub    %edx,%eax
  800d81:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d8c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d8f:	83 c6 01             	add    $0x1,%esi
  800d92:	eb aa                	jmp    800d3e <devpipe_read+0x20>

00800d94 <pipe>:
{
  800d94:	f3 0f 1e fb          	endbr32 
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800da0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800da3:	50                   	push   %eax
  800da4:	e8 1b f6 ff ff       	call   8003c4 <fd_alloc>
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	85 c0                	test   %eax,%eax
  800db0:	0f 88 23 01 00 00    	js     800ed9 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	68 07 04 00 00       	push   $0x407
  800dbe:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc1:	6a 00                	push   $0x0
  800dc3:	e8 bc f3 ff ff       	call   800184 <sys_page_alloc>
  800dc8:	89 c3                	mov    %eax,%ebx
  800dca:	83 c4 10             	add    $0x10,%esp
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	0f 88 04 01 00 00    	js     800ed9 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ddb:	50                   	push   %eax
  800ddc:	e8 e3 f5 ff ff       	call   8003c4 <fd_alloc>
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	0f 88 db 00 00 00    	js     800ec9 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	68 07 04 00 00       	push   $0x407
  800df6:	ff 75 f0             	pushl  -0x10(%ebp)
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 84 f3 ff ff       	call   800184 <sys_page_alloc>
  800e00:	89 c3                	mov    %eax,%ebx
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	0f 88 bc 00 00 00    	js     800ec9 <pipe+0x135>
	va = fd2data(fd0);
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	ff 75 f4             	pushl  -0xc(%ebp)
  800e13:	e8 91 f5 ff ff       	call   8003a9 <fd2data>
  800e18:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1a:	83 c4 0c             	add    $0xc,%esp
  800e1d:	68 07 04 00 00       	push   $0x407
  800e22:	50                   	push   %eax
  800e23:	6a 00                	push   $0x0
  800e25:	e8 5a f3 ff ff       	call   800184 <sys_page_alloc>
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	0f 88 82 00 00 00    	js     800eb9 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3d:	e8 67 f5 ff ff       	call   8003a9 <fd2data>
  800e42:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e49:	50                   	push   %eax
  800e4a:	6a 00                	push   $0x0
  800e4c:	56                   	push   %esi
  800e4d:	6a 00                	push   $0x0
  800e4f:	e8 77 f3 ff ff       	call   8001cb <sys_page_map>
  800e54:	89 c3                	mov    %eax,%ebx
  800e56:	83 c4 20             	add    $0x20,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 4e                	js     800eab <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e5d:	a1 20 30 80 00       	mov    0x803020,%eax
  800e62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e65:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e6a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e71:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e74:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e79:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	ff 75 f4             	pushl  -0xc(%ebp)
  800e86:	e8 0a f5 ff ff       	call   800395 <fd2num>
  800e8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e90:	83 c4 04             	add    $0x4,%esp
  800e93:	ff 75 f0             	pushl  -0x10(%ebp)
  800e96:	e8 fa f4 ff ff       	call   800395 <fd2num>
  800e9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea9:	eb 2e                	jmp    800ed9 <pipe+0x145>
	sys_page_unmap(0, va);
  800eab:	83 ec 08             	sub    $0x8,%esp
  800eae:	56                   	push   %esi
  800eaf:	6a 00                	push   $0x0
  800eb1:	e8 5b f3 ff ff       	call   800211 <sys_page_unmap>
  800eb6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	ff 75 f0             	pushl  -0x10(%ebp)
  800ebf:	6a 00                	push   $0x0
  800ec1:	e8 4b f3 ff ff       	call   800211 <sys_page_unmap>
  800ec6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ec9:	83 ec 08             	sub    $0x8,%esp
  800ecc:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 3b f3 ff ff       	call   800211 <sys_page_unmap>
  800ed6:	83 c4 10             	add    $0x10,%esp
}
  800ed9:	89 d8                	mov    %ebx,%eax
  800edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <pipeisclosed>:
{
  800ee2:	f3 0f 1e fb          	endbr32 
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eef:	50                   	push   %eax
  800ef0:	ff 75 08             	pushl  0x8(%ebp)
  800ef3:	e8 22 f5 ff ff       	call   80041a <fd_lookup>
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	78 18                	js     800f17 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	ff 75 f4             	pushl  -0xc(%ebp)
  800f05:	e8 9f f4 ff ff       	call   8003a9 <fd2data>
  800f0a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f0f:	e8 1f fd ff ff       	call   800c33 <_pipeisclosed>
  800f14:	83 c4 10             	add    $0x10,%esp
}
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f19:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	c3                   	ret    

00800f23 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f23:	f3 0f 1e fb          	endbr32 
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f2d:	68 f4 1f 80 00       	push   $0x801ff4
  800f32:	ff 75 0c             	pushl  0xc(%ebp)
  800f35:	e8 64 08 00 00       	call   80179e <strcpy>
	return 0;
}
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <devcons_write>:
{
  800f41:	f3 0f 1e fb          	endbr32 
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f51:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f56:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f5c:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f5f:	73 31                	jae    800f92 <devcons_write+0x51>
		m = n - tot;
  800f61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f64:	29 f3                	sub    %esi,%ebx
  800f66:	83 fb 7f             	cmp    $0x7f,%ebx
  800f69:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f6e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f71:	83 ec 04             	sub    $0x4,%esp
  800f74:	53                   	push   %ebx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	03 45 0c             	add    0xc(%ebp),%eax
  800f7a:	50                   	push   %eax
  800f7b:	57                   	push   %edi
  800f7c:	e8 d3 09 00 00       	call   801954 <memmove>
		sys_cputs(buf, m);
  800f81:	83 c4 08             	add    $0x8,%esp
  800f84:	53                   	push   %ebx
  800f85:	57                   	push   %edi
  800f86:	e8 29 f1 ff ff       	call   8000b4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f8b:	01 de                	add    %ebx,%esi
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	eb ca                	jmp    800f5c <devcons_write+0x1b>
}
  800f92:	89 f0                	mov    %esi,%eax
  800f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <devcons_read>:
{
  800f9c:	f3 0f 1e fb          	endbr32 
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	83 ec 08             	sub    $0x8,%esp
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800faf:	74 21                	je     800fd2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fb1:	e8 20 f1 ff ff       	call   8000d6 <sys_cgetc>
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	75 07                	jne    800fc1 <devcons_read+0x25>
		sys_yield();
  800fba:	e8 a2 f1 ff ff       	call   800161 <sys_yield>
  800fbf:	eb f0                	jmp    800fb1 <devcons_read+0x15>
	if (c < 0)
  800fc1:	78 0f                	js     800fd2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fc3:	83 f8 04             	cmp    $0x4,%eax
  800fc6:	74 0c                	je     800fd4 <devcons_read+0x38>
	*(char*)vbuf = c;
  800fc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fcb:	88 02                	mov    %al,(%edx)
	return 1;
  800fcd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    
		return 0;
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	eb f7                	jmp    800fd2 <devcons_read+0x36>

00800fdb <cputchar>:
{
  800fdb:	f3 0f 1e fb          	endbr32 
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800feb:	6a 01                	push   $0x1
  800fed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	e8 be f0 ff ff       	call   8000b4 <sys_cputs>
}
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <getchar>:
{
  800ffb:	f3 0f 1e fb          	endbr32 
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801005:	6a 01                	push   $0x1
  801007:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	6a 00                	push   $0x0
  80100d:	e8 8b f6 ff ff       	call   80069d <read>
	if (r < 0)
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	78 06                	js     80101f <getchar+0x24>
	if (r < 1)
  801019:	74 06                	je     801021 <getchar+0x26>
	return c;
  80101b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    
		return -E_EOF;
  801021:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801026:	eb f7                	jmp    80101f <getchar+0x24>

00801028 <iscons>:
{
  801028:	f3 0f 1e fb          	endbr32 
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801032:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	ff 75 08             	pushl  0x8(%ebp)
  801039:	e8 dc f3 ff ff       	call   80041a <fd_lookup>
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	78 11                	js     801056 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801048:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80104e:	39 10                	cmp    %edx,(%eax)
  801050:	0f 94 c0             	sete   %al
  801053:	0f b6 c0             	movzbl %al,%eax
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <opencons>:
{
  801058:	f3 0f 1e fb          	endbr32 
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801062:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801065:	50                   	push   %eax
  801066:	e8 59 f3 ff ff       	call   8003c4 <fd_alloc>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 3a                	js     8010ac <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	68 07 04 00 00       	push   $0x407
  80107a:	ff 75 f4             	pushl  -0xc(%ebp)
  80107d:	6a 00                	push   $0x0
  80107f:	e8 00 f1 ff ff       	call   800184 <sys_page_alloc>
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 21                	js     8010ac <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80108b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801094:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801099:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	50                   	push   %eax
  8010a4:	e8 ec f2 ff ff       	call   800395 <fd2num>
  8010a9:	83 c4 10             	add    $0x10,%esp
}
  8010ac:	c9                   	leave  
  8010ad:	c3                   	ret    

008010ae <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010ae:	f3 0f 1e fb          	endbr32 
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010b7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ba:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010c0:	e8 79 f0 ff ff       	call   80013e <sys_getenvid>
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	ff 75 0c             	pushl  0xc(%ebp)
  8010cb:	ff 75 08             	pushl  0x8(%ebp)
  8010ce:	56                   	push   %esi
  8010cf:	50                   	push   %eax
  8010d0:	68 00 20 80 00       	push   $0x802000
  8010d5:	e8 bb 00 00 00       	call   801195 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010da:	83 c4 18             	add    $0x18,%esp
  8010dd:	53                   	push   %ebx
  8010de:	ff 75 10             	pushl  0x10(%ebp)
  8010e1:	e8 5a 00 00 00       	call   801140 <vcprintf>
	cprintf("\n");
  8010e6:	c7 04 24 ed 1f 80 00 	movl   $0x801fed,(%esp)
  8010ed:	e8 a3 00 00 00       	call   801195 <cprintf>
  8010f2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010f5:	cc                   	int3   
  8010f6:	eb fd                	jmp    8010f5 <_panic+0x47>

008010f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010f8:	f3 0f 1e fb          	endbr32 
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	53                   	push   %ebx
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801106:	8b 13                	mov    (%ebx),%edx
  801108:	8d 42 01             	lea    0x1(%edx),%eax
  80110b:	89 03                	mov    %eax,(%ebx)
  80110d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801110:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801114:	3d ff 00 00 00       	cmp    $0xff,%eax
  801119:	74 09                	je     801124 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80111b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80111f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801122:	c9                   	leave  
  801123:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801124:	83 ec 08             	sub    $0x8,%esp
  801127:	68 ff 00 00 00       	push   $0xff
  80112c:	8d 43 08             	lea    0x8(%ebx),%eax
  80112f:	50                   	push   %eax
  801130:	e8 7f ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  801135:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	eb db                	jmp    80111b <putch+0x23>

00801140 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801140:	f3 0f 1e fb          	endbr32 
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80114d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801154:	00 00 00 
	b.cnt = 0;
  801157:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80115e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801161:	ff 75 0c             	pushl  0xc(%ebp)
  801164:	ff 75 08             	pushl  0x8(%ebp)
  801167:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80116d:	50                   	push   %eax
  80116e:	68 f8 10 80 00       	push   $0x8010f8
  801173:	e8 20 01 00 00       	call   801298 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801181:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801187:	50                   	push   %eax
  801188:	e8 27 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80118d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801195:	f3 0f 1e fb          	endbr32 
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80119f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011a2:	50                   	push   %eax
  8011a3:	ff 75 08             	pushl  0x8(%ebp)
  8011a6:	e8 95 ff ff ff       	call   801140 <vcprintf>
	va_end(ap);

	return cnt;
}
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    

008011ad <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	57                   	push   %edi
  8011b1:	56                   	push   %esi
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 1c             	sub    $0x1c,%esp
  8011b6:	89 c7                	mov    %eax,%edi
  8011b8:	89 d6                	mov    %edx,%esi
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c0:	89 d1                	mov    %edx,%ecx
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8011cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011da:	39 c2                	cmp    %eax,%edx
  8011dc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011df:	72 3e                	jb     80121f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011e1:	83 ec 0c             	sub    $0xc,%esp
  8011e4:	ff 75 18             	pushl  0x18(%ebp)
  8011e7:	83 eb 01             	sub    $0x1,%ebx
  8011ea:	53                   	push   %ebx
  8011eb:	50                   	push   %eax
  8011ec:	83 ec 08             	sub    $0x8,%esp
  8011ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011fb:	e8 50 0a 00 00       	call   801c50 <__udivdi3>
  801200:	83 c4 18             	add    $0x18,%esp
  801203:	52                   	push   %edx
  801204:	50                   	push   %eax
  801205:	89 f2                	mov    %esi,%edx
  801207:	89 f8                	mov    %edi,%eax
  801209:	e8 9f ff ff ff       	call   8011ad <printnum>
  80120e:	83 c4 20             	add    $0x20,%esp
  801211:	eb 13                	jmp    801226 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	56                   	push   %esi
  801217:	ff 75 18             	pushl  0x18(%ebp)
  80121a:	ff d7                	call   *%edi
  80121c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80121f:	83 eb 01             	sub    $0x1,%ebx
  801222:	85 db                	test   %ebx,%ebx
  801224:	7f ed                	jg     801213 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	56                   	push   %esi
  80122a:	83 ec 04             	sub    $0x4,%esp
  80122d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801230:	ff 75 e0             	pushl  -0x20(%ebp)
  801233:	ff 75 dc             	pushl  -0x24(%ebp)
  801236:	ff 75 d8             	pushl  -0x28(%ebp)
  801239:	e8 22 0b 00 00       	call   801d60 <__umoddi3>
  80123e:	83 c4 14             	add    $0x14,%esp
  801241:	0f be 80 23 20 80 00 	movsbl 0x802023(%eax),%eax
  801248:	50                   	push   %eax
  801249:	ff d7                	call   *%edi
}
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5f                   	pop    %edi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801256:	f3 0f 1e fb          	endbr32 
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801260:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801264:	8b 10                	mov    (%eax),%edx
  801266:	3b 50 04             	cmp    0x4(%eax),%edx
  801269:	73 0a                	jae    801275 <sprintputch+0x1f>
		*b->buf++ = ch;
  80126b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80126e:	89 08                	mov    %ecx,(%eax)
  801270:	8b 45 08             	mov    0x8(%ebp),%eax
  801273:	88 02                	mov    %al,(%edx)
}
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <printfmt>:
{
  801277:	f3 0f 1e fb          	endbr32 
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801281:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801284:	50                   	push   %eax
  801285:	ff 75 10             	pushl  0x10(%ebp)
  801288:	ff 75 0c             	pushl  0xc(%ebp)
  80128b:	ff 75 08             	pushl  0x8(%ebp)
  80128e:	e8 05 00 00 00       	call   801298 <vprintfmt>
}
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <vprintfmt>:
{
  801298:	f3 0f 1e fb          	endbr32 
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	57                   	push   %edi
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 3c             	sub    $0x3c,%esp
  8012a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012ae:	e9 4a 03 00 00       	jmp    8015fd <vprintfmt+0x365>
		padc = ' ';
  8012b3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012b7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012be:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012cc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012d1:	8d 47 01             	lea    0x1(%edi),%eax
  8012d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d7:	0f b6 17             	movzbl (%edi),%edx
  8012da:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012dd:	3c 55                	cmp    $0x55,%al
  8012df:	0f 87 de 03 00 00    	ja     8016c3 <vprintfmt+0x42b>
  8012e5:	0f b6 c0             	movzbl %al,%eax
  8012e8:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  8012ef:	00 
  8012f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012f3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012f7:	eb d8                	jmp    8012d1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012fc:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801300:	eb cf                	jmp    8012d1 <vprintfmt+0x39>
  801302:	0f b6 d2             	movzbl %dl,%edx
  801305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
  80130d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801310:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801313:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801317:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80131a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80131d:	83 f9 09             	cmp    $0x9,%ecx
  801320:	77 55                	ja     801377 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801322:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801325:	eb e9                	jmp    801310 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801327:	8b 45 14             	mov    0x14(%ebp),%eax
  80132a:	8b 00                	mov    (%eax),%eax
  80132c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80132f:	8b 45 14             	mov    0x14(%ebp),%eax
  801332:	8d 40 04             	lea    0x4(%eax),%eax
  801335:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80133b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80133f:	79 90                	jns    8012d1 <vprintfmt+0x39>
				width = precision, precision = -1;
  801341:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801344:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801347:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80134e:	eb 81                	jmp    8012d1 <vprintfmt+0x39>
  801350:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801353:	85 c0                	test   %eax,%eax
  801355:	ba 00 00 00 00       	mov    $0x0,%edx
  80135a:	0f 49 d0             	cmovns %eax,%edx
  80135d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801363:	e9 69 ff ff ff       	jmp    8012d1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80136b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801372:	e9 5a ff ff ff       	jmp    8012d1 <vprintfmt+0x39>
  801377:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80137a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80137d:	eb bc                	jmp    80133b <vprintfmt+0xa3>
			lflag++;
  80137f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801385:	e9 47 ff ff ff       	jmp    8012d1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80138a:	8b 45 14             	mov    0x14(%ebp),%eax
  80138d:	8d 78 04             	lea    0x4(%eax),%edi
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	53                   	push   %ebx
  801394:	ff 30                	pushl  (%eax)
  801396:	ff d6                	call   *%esi
			break;
  801398:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80139b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80139e:	e9 57 02 00 00       	jmp    8015fa <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a6:	8d 78 04             	lea    0x4(%eax),%edi
  8013a9:	8b 00                	mov    (%eax),%eax
  8013ab:	99                   	cltd   
  8013ac:	31 d0                	xor    %edx,%eax
  8013ae:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013b0:	83 f8 0f             	cmp    $0xf,%eax
  8013b3:	7f 23                	jg     8013d8 <vprintfmt+0x140>
  8013b5:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013bc:	85 d2                	test   %edx,%edx
  8013be:	74 18                	je     8013d8 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013c0:	52                   	push   %edx
  8013c1:	68 c6 1f 80 00       	push   $0x801fc6
  8013c6:	53                   	push   %ebx
  8013c7:	56                   	push   %esi
  8013c8:	e8 aa fe ff ff       	call   801277 <printfmt>
  8013cd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013d0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013d3:	e9 22 02 00 00       	jmp    8015fa <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  8013d8:	50                   	push   %eax
  8013d9:	68 3b 20 80 00       	push   $0x80203b
  8013de:	53                   	push   %ebx
  8013df:	56                   	push   %esi
  8013e0:	e8 92 fe ff ff       	call   801277 <printfmt>
  8013e5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013e8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8013eb:	e9 0a 02 00 00       	jmp    8015fa <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  8013f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f3:	83 c0 04             	add    $0x4,%eax
  8013f6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8013f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fc:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8013fe:	85 d2                	test   %edx,%edx
  801400:	b8 34 20 80 00       	mov    $0x802034,%eax
  801405:	0f 45 c2             	cmovne %edx,%eax
  801408:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80140b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80140f:	7e 06                	jle    801417 <vprintfmt+0x17f>
  801411:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801415:	75 0d                	jne    801424 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801417:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80141a:	89 c7                	mov    %eax,%edi
  80141c:	03 45 e0             	add    -0x20(%ebp),%eax
  80141f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801422:	eb 55                	jmp    801479 <vprintfmt+0x1e1>
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	ff 75 d8             	pushl  -0x28(%ebp)
  80142a:	ff 75 cc             	pushl  -0x34(%ebp)
  80142d:	e8 45 03 00 00       	call   801777 <strnlen>
  801432:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801435:	29 c2                	sub    %eax,%edx
  801437:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80143f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801443:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801446:	85 ff                	test   %edi,%edi
  801448:	7e 11                	jle    80145b <vprintfmt+0x1c3>
					putch(padc, putdat);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	53                   	push   %ebx
  80144e:	ff 75 e0             	pushl  -0x20(%ebp)
  801451:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801453:	83 ef 01             	sub    $0x1,%edi
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb eb                	jmp    801446 <vprintfmt+0x1ae>
  80145b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80145e:	85 d2                	test   %edx,%edx
  801460:	b8 00 00 00 00       	mov    $0x0,%eax
  801465:	0f 49 c2             	cmovns %edx,%eax
  801468:	29 c2                	sub    %eax,%edx
  80146a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80146d:	eb a8                	jmp    801417 <vprintfmt+0x17f>
					putch(ch, putdat);
  80146f:	83 ec 08             	sub    $0x8,%esp
  801472:	53                   	push   %ebx
  801473:	52                   	push   %edx
  801474:	ff d6                	call   *%esi
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80147c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147e:	83 c7 01             	add    $0x1,%edi
  801481:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801485:	0f be d0             	movsbl %al,%edx
  801488:	85 d2                	test   %edx,%edx
  80148a:	74 4b                	je     8014d7 <vprintfmt+0x23f>
  80148c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801490:	78 06                	js     801498 <vprintfmt+0x200>
  801492:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801496:	78 1e                	js     8014b6 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  801498:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80149c:	74 d1                	je     80146f <vprintfmt+0x1d7>
  80149e:	0f be c0             	movsbl %al,%eax
  8014a1:	83 e8 20             	sub    $0x20,%eax
  8014a4:	83 f8 5e             	cmp    $0x5e,%eax
  8014a7:	76 c6                	jbe    80146f <vprintfmt+0x1d7>
					putch('?', putdat);
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	53                   	push   %ebx
  8014ad:	6a 3f                	push   $0x3f
  8014af:	ff d6                	call   *%esi
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	eb c3                	jmp    801479 <vprintfmt+0x1e1>
  8014b6:	89 cf                	mov    %ecx,%edi
  8014b8:	eb 0e                	jmp    8014c8 <vprintfmt+0x230>
				putch(' ', putdat);
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	53                   	push   %ebx
  8014be:	6a 20                	push   $0x20
  8014c0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014c2:	83 ef 01             	sub    $0x1,%edi
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 ff                	test   %edi,%edi
  8014ca:	7f ee                	jg     8014ba <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014cc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d2:	e9 23 01 00 00       	jmp    8015fa <vprintfmt+0x362>
  8014d7:	89 cf                	mov    %ecx,%edi
  8014d9:	eb ed                	jmp    8014c8 <vprintfmt+0x230>
	if (lflag >= 2)
  8014db:	83 f9 01             	cmp    $0x1,%ecx
  8014de:	7f 1b                	jg     8014fb <vprintfmt+0x263>
	else if (lflag)
  8014e0:	85 c9                	test   %ecx,%ecx
  8014e2:	74 63                	je     801547 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8014e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e7:	8b 00                	mov    (%eax),%eax
  8014e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ec:	99                   	cltd   
  8014ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8d 40 04             	lea    0x4(%eax),%eax
  8014f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f9:	eb 17                	jmp    801512 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8014fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fe:	8b 50 04             	mov    0x4(%eax),%edx
  801501:	8b 00                	mov    (%eax),%eax
  801503:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801506:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801509:	8b 45 14             	mov    0x14(%ebp),%eax
  80150c:	8d 40 08             	lea    0x8(%eax),%eax
  80150f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801512:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801515:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801518:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80151d:	85 c9                	test   %ecx,%ecx
  80151f:	0f 89 bb 00 00 00    	jns    8015e0 <vprintfmt+0x348>
				putch('-', putdat);
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	53                   	push   %ebx
  801529:	6a 2d                	push   $0x2d
  80152b:	ff d6                	call   *%esi
				num = -(long long) num;
  80152d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801530:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801533:	f7 da                	neg    %edx
  801535:	83 d1 00             	adc    $0x0,%ecx
  801538:	f7 d9                	neg    %ecx
  80153a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80153d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801542:	e9 99 00 00 00       	jmp    8015e0 <vprintfmt+0x348>
		return va_arg(*ap, int);
  801547:	8b 45 14             	mov    0x14(%ebp),%eax
  80154a:	8b 00                	mov    (%eax),%eax
  80154c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154f:	99                   	cltd   
  801550:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801553:	8b 45 14             	mov    0x14(%ebp),%eax
  801556:	8d 40 04             	lea    0x4(%eax),%eax
  801559:	89 45 14             	mov    %eax,0x14(%ebp)
  80155c:	eb b4                	jmp    801512 <vprintfmt+0x27a>
	if (lflag >= 2)
  80155e:	83 f9 01             	cmp    $0x1,%ecx
  801561:	7f 1b                	jg     80157e <vprintfmt+0x2e6>
	else if (lflag)
  801563:	85 c9                	test   %ecx,%ecx
  801565:	74 2c                	je     801593 <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  801567:	8b 45 14             	mov    0x14(%ebp),%eax
  80156a:	8b 10                	mov    (%eax),%edx
  80156c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801571:	8d 40 04             	lea    0x4(%eax),%eax
  801574:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801577:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80157c:	eb 62                	jmp    8015e0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  80157e:	8b 45 14             	mov    0x14(%ebp),%eax
  801581:	8b 10                	mov    (%eax),%edx
  801583:	8b 48 04             	mov    0x4(%eax),%ecx
  801586:	8d 40 08             	lea    0x8(%eax),%eax
  801589:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80158c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  801591:	eb 4d                	jmp    8015e0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  801593:	8b 45 14             	mov    0x14(%ebp),%eax
  801596:	8b 10                	mov    (%eax),%edx
  801598:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159d:	8d 40 04             	lea    0x4(%eax),%eax
  8015a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015a3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015a8:	eb 36                	jmp    8015e0 <vprintfmt+0x348>
	if (lflag >= 2)
  8015aa:	83 f9 01             	cmp    $0x1,%ecx
  8015ad:	7f 17                	jg     8015c6 <vprintfmt+0x32e>
	else if (lflag)
  8015af:	85 c9                	test   %ecx,%ecx
  8015b1:	74 6e                	je     801621 <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b6:	8b 10                	mov    (%eax),%edx
  8015b8:	89 d0                	mov    %edx,%eax
  8015ba:	99                   	cltd   
  8015bb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015be:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015c1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015c4:	eb 11                	jmp    8015d7 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c9:	8b 50 04             	mov    0x4(%eax),%edx
  8015cc:	8b 00                	mov    (%eax),%eax
  8015ce:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015d1:	8d 49 08             	lea    0x8(%ecx),%ecx
  8015d4:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  8015d7:	89 d1                	mov    %edx,%ecx
  8015d9:	89 c2                	mov    %eax,%edx
            base = 8;
  8015db:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8015e7:	57                   	push   %edi
  8015e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015eb:	50                   	push   %eax
  8015ec:	51                   	push   %ecx
  8015ed:	52                   	push   %edx
  8015ee:	89 da                	mov    %ebx,%edx
  8015f0:	89 f0                	mov    %esi,%eax
  8015f2:	e8 b6 fb ff ff       	call   8011ad <printnum>
			break;
  8015f7:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8015fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015fd:	83 c7 01             	add    $0x1,%edi
  801600:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801604:	83 f8 25             	cmp    $0x25,%eax
  801607:	0f 84 a6 fc ff ff    	je     8012b3 <vprintfmt+0x1b>
			if (ch == '\0')
  80160d:	85 c0                	test   %eax,%eax
  80160f:	0f 84 ce 00 00 00    	je     8016e3 <vprintfmt+0x44b>
			putch(ch, putdat);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	53                   	push   %ebx
  801619:	50                   	push   %eax
  80161a:	ff d6                	call   *%esi
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	eb dc                	jmp    8015fd <vprintfmt+0x365>
		return va_arg(*ap, int);
  801621:	8b 45 14             	mov    0x14(%ebp),%eax
  801624:	8b 10                	mov    (%eax),%edx
  801626:	89 d0                	mov    %edx,%eax
  801628:	99                   	cltd   
  801629:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80162c:	8d 49 04             	lea    0x4(%ecx),%ecx
  80162f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801632:	eb a3                	jmp    8015d7 <vprintfmt+0x33f>
			putch('0', putdat);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	53                   	push   %ebx
  801638:	6a 30                	push   $0x30
  80163a:	ff d6                	call   *%esi
			putch('x', putdat);
  80163c:	83 c4 08             	add    $0x8,%esp
  80163f:	53                   	push   %ebx
  801640:	6a 78                	push   $0x78
  801642:	ff d6                	call   *%esi
			num = (unsigned long long)
  801644:	8b 45 14             	mov    0x14(%ebp),%eax
  801647:	8b 10                	mov    (%eax),%edx
  801649:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80164e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801651:	8d 40 04             	lea    0x4(%eax),%eax
  801654:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801657:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80165c:	eb 82                	jmp    8015e0 <vprintfmt+0x348>
	if (lflag >= 2)
  80165e:	83 f9 01             	cmp    $0x1,%ecx
  801661:	7f 1e                	jg     801681 <vprintfmt+0x3e9>
	else if (lflag)
  801663:	85 c9                	test   %ecx,%ecx
  801665:	74 32                	je     801699 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  801667:	8b 45 14             	mov    0x14(%ebp),%eax
  80166a:	8b 10                	mov    (%eax),%edx
  80166c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801671:	8d 40 04             	lea    0x4(%eax),%eax
  801674:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801677:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80167c:	e9 5f ff ff ff       	jmp    8015e0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  801681:	8b 45 14             	mov    0x14(%ebp),%eax
  801684:	8b 10                	mov    (%eax),%edx
  801686:	8b 48 04             	mov    0x4(%eax),%ecx
  801689:	8d 40 08             	lea    0x8(%eax),%eax
  80168c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80168f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801694:	e9 47 ff ff ff       	jmp    8015e0 <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  801699:	8b 45 14             	mov    0x14(%ebp),%eax
  80169c:	8b 10                	mov    (%eax),%edx
  80169e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016a3:	8d 40 04             	lea    0x4(%eax),%eax
  8016a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016a9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016ae:	e9 2d ff ff ff       	jmp    8015e0 <vprintfmt+0x348>
			putch(ch, putdat);
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	53                   	push   %ebx
  8016b7:	6a 25                	push   $0x25
  8016b9:	ff d6                	call   *%esi
			break;
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	e9 37 ff ff ff       	jmp    8015fa <vprintfmt+0x362>
			putch('%', putdat);
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	53                   	push   %ebx
  8016c7:	6a 25                	push   $0x25
  8016c9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	89 f8                	mov    %edi,%eax
  8016d0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8016d4:	74 05                	je     8016db <vprintfmt+0x443>
  8016d6:	83 e8 01             	sub    $0x1,%eax
  8016d9:	eb f5                	jmp    8016d0 <vprintfmt+0x438>
  8016db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016de:	e9 17 ff ff ff       	jmp    8015fa <vprintfmt+0x362>
}
  8016e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5e                   	pop    %esi
  8016e8:	5f                   	pop    %edi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016eb:	f3 0f 1e fb          	endbr32 
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	83 ec 18             	sub    $0x18,%esp
  8016f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801702:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801705:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80170c:	85 c0                	test   %eax,%eax
  80170e:	74 26                	je     801736 <vsnprintf+0x4b>
  801710:	85 d2                	test   %edx,%edx
  801712:	7e 22                	jle    801736 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801714:	ff 75 14             	pushl  0x14(%ebp)
  801717:	ff 75 10             	pushl  0x10(%ebp)
  80171a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80171d:	50                   	push   %eax
  80171e:	68 56 12 80 00       	push   $0x801256
  801723:	e8 70 fb ff ff       	call   801298 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801728:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80172b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80172e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801731:	83 c4 10             	add    $0x10,%esp
}
  801734:	c9                   	leave  
  801735:	c3                   	ret    
		return -E_INVAL;
  801736:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173b:	eb f7                	jmp    801734 <vsnprintf+0x49>

0080173d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80173d:	f3 0f 1e fb          	endbr32 
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801747:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80174a:	50                   	push   %eax
  80174b:	ff 75 10             	pushl  0x10(%ebp)
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	ff 75 08             	pushl  0x8(%ebp)
  801754:	e8 92 ff ff ff       	call   8016eb <vsnprintf>
	va_end(ap);

	return rc;
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80175b:	f3 0f 1e fb          	endbr32 
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801765:	b8 00 00 00 00       	mov    $0x0,%eax
  80176a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80176e:	74 05                	je     801775 <strlen+0x1a>
		n++;
  801770:	83 c0 01             	add    $0x1,%eax
  801773:	eb f5                	jmp    80176a <strlen+0xf>
	return n;
}
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801777:	f3 0f 1e fb          	endbr32 
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801781:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
  801789:	39 d0                	cmp    %edx,%eax
  80178b:	74 0d                	je     80179a <strnlen+0x23>
  80178d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801791:	74 05                	je     801798 <strnlen+0x21>
		n++;
  801793:	83 c0 01             	add    $0x1,%eax
  801796:	eb f1                	jmp    801789 <strnlen+0x12>
  801798:	89 c2                	mov    %eax,%edx
	return n;
}
  80179a:	89 d0                	mov    %edx,%eax
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80179e:	f3 0f 1e fb          	endbr32 
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	53                   	push   %ebx
  8017a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017b5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017b8:	83 c0 01             	add    $0x1,%eax
  8017bb:	84 d2                	test   %dl,%dl
  8017bd:	75 f2                	jne    8017b1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017bf:	89 c8                	mov    %ecx,%eax
  8017c1:	5b                   	pop    %ebx
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017c4:	f3 0f 1e fb          	endbr32 
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	53                   	push   %ebx
  8017cc:	83 ec 10             	sub    $0x10,%esp
  8017cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017d2:	53                   	push   %ebx
  8017d3:	e8 83 ff ff ff       	call   80175b <strlen>
  8017d8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8017db:	ff 75 0c             	pushl  0xc(%ebp)
  8017de:	01 d8                	add    %ebx,%eax
  8017e0:	50                   	push   %eax
  8017e1:	e8 b8 ff ff ff       	call   80179e <strcpy>
	return dst;
}
  8017e6:	89 d8                	mov    %ebx,%eax
  8017e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8017ed:	f3 0f 1e fb          	endbr32 
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fc:	89 f3                	mov    %esi,%ebx
  8017fe:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801801:	89 f0                	mov    %esi,%eax
  801803:	39 d8                	cmp    %ebx,%eax
  801805:	74 11                	je     801818 <strncpy+0x2b>
		*dst++ = *src;
  801807:	83 c0 01             	add    $0x1,%eax
  80180a:	0f b6 0a             	movzbl (%edx),%ecx
  80180d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801810:	80 f9 01             	cmp    $0x1,%cl
  801813:	83 da ff             	sbb    $0xffffffff,%edx
  801816:	eb eb                	jmp    801803 <strncpy+0x16>
	}
	return ret;
}
  801818:	89 f0                	mov    %esi,%eax
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80181e:	f3 0f 1e fb          	endbr32 
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	56                   	push   %esi
  801826:	53                   	push   %ebx
  801827:	8b 75 08             	mov    0x8(%ebp),%esi
  80182a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80182d:	8b 55 10             	mov    0x10(%ebp),%edx
  801830:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801832:	85 d2                	test   %edx,%edx
  801834:	74 21                	je     801857 <strlcpy+0x39>
  801836:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80183a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80183c:	39 c2                	cmp    %eax,%edx
  80183e:	74 14                	je     801854 <strlcpy+0x36>
  801840:	0f b6 19             	movzbl (%ecx),%ebx
  801843:	84 db                	test   %bl,%bl
  801845:	74 0b                	je     801852 <strlcpy+0x34>
			*dst++ = *src++;
  801847:	83 c1 01             	add    $0x1,%ecx
  80184a:	83 c2 01             	add    $0x1,%edx
  80184d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801850:	eb ea                	jmp    80183c <strlcpy+0x1e>
  801852:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801854:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801857:	29 f0                	sub    %esi,%eax
}
  801859:	5b                   	pop    %ebx
  80185a:	5e                   	pop    %esi
  80185b:	5d                   	pop    %ebp
  80185c:	c3                   	ret    

0080185d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80185d:	f3 0f 1e fb          	endbr32 
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801867:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80186a:	0f b6 01             	movzbl (%ecx),%eax
  80186d:	84 c0                	test   %al,%al
  80186f:	74 0c                	je     80187d <strcmp+0x20>
  801871:	3a 02                	cmp    (%edx),%al
  801873:	75 08                	jne    80187d <strcmp+0x20>
		p++, q++;
  801875:	83 c1 01             	add    $0x1,%ecx
  801878:	83 c2 01             	add    $0x1,%edx
  80187b:	eb ed                	jmp    80186a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80187d:	0f b6 c0             	movzbl %al,%eax
  801880:	0f b6 12             	movzbl (%edx),%edx
  801883:	29 d0                	sub    %edx,%eax
}
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801887:	f3 0f 1e fb          	endbr32 
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	53                   	push   %ebx
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	8b 55 0c             	mov    0xc(%ebp),%edx
  801895:	89 c3                	mov    %eax,%ebx
  801897:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80189a:	eb 06                	jmp    8018a2 <strncmp+0x1b>
		n--, p++, q++;
  80189c:	83 c0 01             	add    $0x1,%eax
  80189f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018a2:	39 d8                	cmp    %ebx,%eax
  8018a4:	74 16                	je     8018bc <strncmp+0x35>
  8018a6:	0f b6 08             	movzbl (%eax),%ecx
  8018a9:	84 c9                	test   %cl,%cl
  8018ab:	74 04                	je     8018b1 <strncmp+0x2a>
  8018ad:	3a 0a                	cmp    (%edx),%cl
  8018af:	74 eb                	je     80189c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018b1:	0f b6 00             	movzbl (%eax),%eax
  8018b4:	0f b6 12             	movzbl (%edx),%edx
  8018b7:	29 d0                	sub    %edx,%eax
}
  8018b9:	5b                   	pop    %ebx
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    
		return 0;
  8018bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c1:	eb f6                	jmp    8018b9 <strncmp+0x32>

008018c3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018c3:	f3 0f 1e fb          	endbr32 
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018d1:	0f b6 10             	movzbl (%eax),%edx
  8018d4:	84 d2                	test   %dl,%dl
  8018d6:	74 09                	je     8018e1 <strchr+0x1e>
		if (*s == c)
  8018d8:	38 ca                	cmp    %cl,%dl
  8018da:	74 0a                	je     8018e6 <strchr+0x23>
	for (; *s; s++)
  8018dc:	83 c0 01             	add    $0x1,%eax
  8018df:	eb f0                	jmp    8018d1 <strchr+0xe>
			return (char *) s;
	return 0;
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8018e8:	f3 0f 1e fb          	endbr32 
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018f6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8018f9:	38 ca                	cmp    %cl,%dl
  8018fb:	74 09                	je     801906 <strfind+0x1e>
  8018fd:	84 d2                	test   %dl,%dl
  8018ff:	74 05                	je     801906 <strfind+0x1e>
	for (; *s; s++)
  801901:	83 c0 01             	add    $0x1,%eax
  801904:	eb f0                	jmp    8018f6 <strfind+0xe>
			break;
	return (char *) s;
}
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801908:	f3 0f 1e fb          	endbr32 
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	57                   	push   %edi
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	8b 7d 08             	mov    0x8(%ebp),%edi
  801915:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801918:	85 c9                	test   %ecx,%ecx
  80191a:	74 31                	je     80194d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80191c:	89 f8                	mov    %edi,%eax
  80191e:	09 c8                	or     %ecx,%eax
  801920:	a8 03                	test   $0x3,%al
  801922:	75 23                	jne    801947 <memset+0x3f>
		c &= 0xFF;
  801924:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801928:	89 d3                	mov    %edx,%ebx
  80192a:	c1 e3 08             	shl    $0x8,%ebx
  80192d:	89 d0                	mov    %edx,%eax
  80192f:	c1 e0 18             	shl    $0x18,%eax
  801932:	89 d6                	mov    %edx,%esi
  801934:	c1 e6 10             	shl    $0x10,%esi
  801937:	09 f0                	or     %esi,%eax
  801939:	09 c2                	or     %eax,%edx
  80193b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80193d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801940:	89 d0                	mov    %edx,%eax
  801942:	fc                   	cld    
  801943:	f3 ab                	rep stos %eax,%es:(%edi)
  801945:	eb 06                	jmp    80194d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194a:	fc                   	cld    
  80194b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80194d:	89 f8                	mov    %edi,%eax
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5f                   	pop    %edi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801954:	f3 0f 1e fb          	endbr32 
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	57                   	push   %edi
  80195c:	56                   	push   %esi
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	8b 75 0c             	mov    0xc(%ebp),%esi
  801963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801966:	39 c6                	cmp    %eax,%esi
  801968:	73 32                	jae    80199c <memmove+0x48>
  80196a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80196d:	39 c2                	cmp    %eax,%edx
  80196f:	76 2b                	jbe    80199c <memmove+0x48>
		s += n;
		d += n;
  801971:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801974:	89 fe                	mov    %edi,%esi
  801976:	09 ce                	or     %ecx,%esi
  801978:	09 d6                	or     %edx,%esi
  80197a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801980:	75 0e                	jne    801990 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801982:	83 ef 04             	sub    $0x4,%edi
  801985:	8d 72 fc             	lea    -0x4(%edx),%esi
  801988:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80198b:	fd                   	std    
  80198c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80198e:	eb 09                	jmp    801999 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801990:	83 ef 01             	sub    $0x1,%edi
  801993:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801996:	fd                   	std    
  801997:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801999:	fc                   	cld    
  80199a:	eb 1a                	jmp    8019b6 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80199c:	89 c2                	mov    %eax,%edx
  80199e:	09 ca                	or     %ecx,%edx
  8019a0:	09 f2                	or     %esi,%edx
  8019a2:	f6 c2 03             	test   $0x3,%dl
  8019a5:	75 0a                	jne    8019b1 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019a7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019aa:	89 c7                	mov    %eax,%edi
  8019ac:	fc                   	cld    
  8019ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019af:	eb 05                	jmp    8019b6 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019b1:	89 c7                	mov    %eax,%edi
  8019b3:	fc                   	cld    
  8019b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019b6:	5e                   	pop    %esi
  8019b7:	5f                   	pop    %edi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019ba:	f3 0f 1e fb          	endbr32 
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019c4:	ff 75 10             	pushl  0x10(%ebp)
  8019c7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ca:	ff 75 08             	pushl  0x8(%ebp)
  8019cd:	e8 82 ff ff ff       	call   801954 <memmove>
}
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8019d4:	f3 0f 1e fb          	endbr32 
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e3:	89 c6                	mov    %eax,%esi
  8019e5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8019e8:	39 f0                	cmp    %esi,%eax
  8019ea:	74 1c                	je     801a08 <memcmp+0x34>
		if (*s1 != *s2)
  8019ec:	0f b6 08             	movzbl (%eax),%ecx
  8019ef:	0f b6 1a             	movzbl (%edx),%ebx
  8019f2:	38 d9                	cmp    %bl,%cl
  8019f4:	75 08                	jne    8019fe <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8019f6:	83 c0 01             	add    $0x1,%eax
  8019f9:	83 c2 01             	add    $0x1,%edx
  8019fc:	eb ea                	jmp    8019e8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8019fe:	0f b6 c1             	movzbl %cl,%eax
  801a01:	0f b6 db             	movzbl %bl,%ebx
  801a04:	29 d8                	sub    %ebx,%eax
  801a06:	eb 05                	jmp    801a0d <memcmp+0x39>
	}

	return 0;
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5d                   	pop    %ebp
  801a10:	c3                   	ret    

00801a11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a11:	f3 0f 1e fb          	endbr32 
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a1e:	89 c2                	mov    %eax,%edx
  801a20:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a23:	39 d0                	cmp    %edx,%eax
  801a25:	73 09                	jae    801a30 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a27:	38 08                	cmp    %cl,(%eax)
  801a29:	74 05                	je     801a30 <memfind+0x1f>
	for (; s < ends; s++)
  801a2b:	83 c0 01             	add    $0x1,%eax
  801a2e:	eb f3                	jmp    801a23 <memfind+0x12>
			break;
	return (void *) s;
}
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a32:	f3 0f 1e fb          	endbr32 
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	57                   	push   %edi
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a42:	eb 03                	jmp    801a47 <strtol+0x15>
		s++;
  801a44:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a47:	0f b6 01             	movzbl (%ecx),%eax
  801a4a:	3c 20                	cmp    $0x20,%al
  801a4c:	74 f6                	je     801a44 <strtol+0x12>
  801a4e:	3c 09                	cmp    $0x9,%al
  801a50:	74 f2                	je     801a44 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a52:	3c 2b                	cmp    $0x2b,%al
  801a54:	74 2a                	je     801a80 <strtol+0x4e>
	int neg = 0;
  801a56:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a5b:	3c 2d                	cmp    $0x2d,%al
  801a5d:	74 2b                	je     801a8a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a5f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a65:	75 0f                	jne    801a76 <strtol+0x44>
  801a67:	80 39 30             	cmpb   $0x30,(%ecx)
  801a6a:	74 28                	je     801a94 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a6c:	85 db                	test   %ebx,%ebx
  801a6e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a73:	0f 44 d8             	cmove  %eax,%ebx
  801a76:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801a7e:	eb 46                	jmp    801ac6 <strtol+0x94>
		s++;
  801a80:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801a83:	bf 00 00 00 00       	mov    $0x0,%edi
  801a88:	eb d5                	jmp    801a5f <strtol+0x2d>
		s++, neg = 1;
  801a8a:	83 c1 01             	add    $0x1,%ecx
  801a8d:	bf 01 00 00 00       	mov    $0x1,%edi
  801a92:	eb cb                	jmp    801a5f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a94:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a98:	74 0e                	je     801aa8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801a9a:	85 db                	test   %ebx,%ebx
  801a9c:	75 d8                	jne    801a76 <strtol+0x44>
		s++, base = 8;
  801a9e:	83 c1 01             	add    $0x1,%ecx
  801aa1:	bb 08 00 00 00       	mov    $0x8,%ebx
  801aa6:	eb ce                	jmp    801a76 <strtol+0x44>
		s += 2, base = 16;
  801aa8:	83 c1 02             	add    $0x2,%ecx
  801aab:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ab0:	eb c4                	jmp    801a76 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801ab2:	0f be d2             	movsbl %dl,%edx
  801ab5:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ab8:	3b 55 10             	cmp    0x10(%ebp),%edx
  801abb:	7d 3a                	jge    801af7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801abd:	83 c1 01             	add    $0x1,%ecx
  801ac0:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ac4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801ac6:	0f b6 11             	movzbl (%ecx),%edx
  801ac9:	8d 72 d0             	lea    -0x30(%edx),%esi
  801acc:	89 f3                	mov    %esi,%ebx
  801ace:	80 fb 09             	cmp    $0x9,%bl
  801ad1:	76 df                	jbe    801ab2 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801ad3:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ad6:	89 f3                	mov    %esi,%ebx
  801ad8:	80 fb 19             	cmp    $0x19,%bl
  801adb:	77 08                	ja     801ae5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801add:	0f be d2             	movsbl %dl,%edx
  801ae0:	83 ea 57             	sub    $0x57,%edx
  801ae3:	eb d3                	jmp    801ab8 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801ae5:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ae8:	89 f3                	mov    %esi,%ebx
  801aea:	80 fb 19             	cmp    $0x19,%bl
  801aed:	77 08                	ja     801af7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801aef:	0f be d2             	movsbl %dl,%edx
  801af2:	83 ea 37             	sub    $0x37,%edx
  801af5:	eb c1                	jmp    801ab8 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801af7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801afb:	74 05                	je     801b02 <strtol+0xd0>
		*endptr = (char *) s;
  801afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b00:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	f7 da                	neg    %edx
  801b06:	85 ff                	test   %edi,%edi
  801b08:	0f 45 c2             	cmovne %edx,%eax
}
  801b0b:	5b                   	pop    %ebx
  801b0c:	5e                   	pop    %esi
  801b0d:	5f                   	pop    %edi
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b10:	f3 0f 1e fb          	endbr32 
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b22:	85 c0                	test   %eax,%eax
  801b24:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b29:	0f 44 c2             	cmove  %edx,%eax
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	50                   	push   %eax
  801b30:	e8 1b e8 ff ff       	call   800350 <sys_ipc_recv>
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 24                	js     801b60 <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b3c:	85 f6                	test   %esi,%esi
  801b3e:	74 0a                	je     801b4a <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b40:	a1 04 40 80 00       	mov    0x804004,%eax
  801b45:	8b 40 78             	mov    0x78(%eax),%eax
  801b48:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b4a:	85 db                	test   %ebx,%ebx
  801b4c:	74 0a                	je     801b58 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b4e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b53:	8b 40 74             	mov    0x74(%eax),%eax
  801b56:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b58:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b67:	f3 0f 1e fb          	endbr32 
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	57                   	push   %edi
  801b6f:	56                   	push   %esi
  801b70:	53                   	push   %ebx
  801b71:	83 ec 1c             	sub    $0x1c,%esp
  801b74:	8b 45 10             	mov    0x10(%ebp),%eax
  801b77:	85 c0                	test   %eax,%eax
  801b79:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b7e:	0f 45 d0             	cmovne %eax,%edx
  801b81:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801b83:	be 01 00 00 00       	mov    $0x1,%esi
  801b88:	eb 1f                	jmp    801ba9 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801b8a:	e8 d2 e5 ff ff       	call   800161 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801b8f:	83 c3 01             	add    $0x1,%ebx
  801b92:	39 de                	cmp    %ebx,%esi
  801b94:	7f f4                	jg     801b8a <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801b96:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801b98:	83 fe 11             	cmp    $0x11,%esi
  801b9b:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba0:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801ba3:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801ba7:	75 1c                	jne    801bc5 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801ba9:	ff 75 14             	pushl  0x14(%ebp)
  801bac:	57                   	push   %edi
  801bad:	ff 75 0c             	pushl  0xc(%ebp)
  801bb0:	ff 75 08             	pushl  0x8(%ebp)
  801bb3:	e8 71 e7 ff ff       	call   800329 <sys_ipc_try_send>
  801bb8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc3:	eb cd                	jmp    801b92 <ipc_send+0x2b>
}
  801bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5f                   	pop    %edi
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bcd:	f3 0f 1e fb          	endbr32 
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bd7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bdc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bdf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801be5:	8b 52 50             	mov    0x50(%edx),%edx
  801be8:	39 ca                	cmp    %ecx,%edx
  801bea:	74 11                	je     801bfd <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bec:	83 c0 01             	add    $0x1,%eax
  801bef:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bf4:	75 e6                	jne    801bdc <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfb:	eb 0b                	jmp    801c08 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801bfd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c00:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c05:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c0a:	f3 0f 1e fb          	endbr32 
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c14:	89 c2                	mov    %eax,%edx
  801c16:	c1 ea 16             	shr    $0x16,%edx
  801c19:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c20:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c25:	f6 c1 01             	test   $0x1,%cl
  801c28:	74 1c                	je     801c46 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c2a:	c1 e8 0c             	shr    $0xc,%eax
  801c2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c34:	a8 01                	test   $0x1,%al
  801c36:	74 0e                	je     801c46 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c38:	c1 e8 0c             	shr    $0xc,%eax
  801c3b:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c42:	ef 
  801c43:	0f b7 d2             	movzwl %dx,%edx
}
  801c46:	89 d0                	mov    %edx,%eax
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__udivdi3>:
  801c50:	f3 0f 1e fb          	endbr32 
  801c54:	55                   	push   %ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 1c             	sub    $0x1c,%esp
  801c5b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c63:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c6b:	85 d2                	test   %edx,%edx
  801c6d:	75 19                	jne    801c88 <__udivdi3+0x38>
  801c6f:	39 f3                	cmp    %esi,%ebx
  801c71:	76 4d                	jbe    801cc0 <__udivdi3+0x70>
  801c73:	31 ff                	xor    %edi,%edi
  801c75:	89 e8                	mov    %ebp,%eax
  801c77:	89 f2                	mov    %esi,%edx
  801c79:	f7 f3                	div    %ebx
  801c7b:	89 fa                	mov    %edi,%edx
  801c7d:	83 c4 1c             	add    $0x1c,%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5f                   	pop    %edi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	8d 76 00             	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	76 14                	jbe    801ca0 <__udivdi3+0x50>
  801c8c:	31 ff                	xor    %edi,%edi
  801c8e:	31 c0                	xor    %eax,%eax
  801c90:	89 fa                	mov    %edi,%edx
  801c92:	83 c4 1c             	add    $0x1c,%esp
  801c95:	5b                   	pop    %ebx
  801c96:	5e                   	pop    %esi
  801c97:	5f                   	pop    %edi
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    
  801c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca0:	0f bd fa             	bsr    %edx,%edi
  801ca3:	83 f7 1f             	xor    $0x1f,%edi
  801ca6:	75 48                	jne    801cf0 <__udivdi3+0xa0>
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	72 06                	jb     801cb2 <__udivdi3+0x62>
  801cac:	31 c0                	xor    %eax,%eax
  801cae:	39 eb                	cmp    %ebp,%ebx
  801cb0:	77 de                	ja     801c90 <__udivdi3+0x40>
  801cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb7:	eb d7                	jmp    801c90 <__udivdi3+0x40>
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d9                	mov    %ebx,%ecx
  801cc2:	85 db                	test   %ebx,%ebx
  801cc4:	75 0b                	jne    801cd1 <__udivdi3+0x81>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f3                	div    %ebx
  801ccf:	89 c1                	mov    %eax,%ecx
  801cd1:	31 d2                	xor    %edx,%edx
  801cd3:	89 f0                	mov    %esi,%eax
  801cd5:	f7 f1                	div    %ecx
  801cd7:	89 c6                	mov    %eax,%esi
  801cd9:	89 e8                	mov    %ebp,%eax
  801cdb:	89 f7                	mov    %esi,%edi
  801cdd:	f7 f1                	div    %ecx
  801cdf:	89 fa                	mov    %edi,%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 f9                	mov    %edi,%ecx
  801cf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cf7:	29 f8                	sub    %edi,%eax
  801cf9:	d3 e2                	shl    %cl,%edx
  801cfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	89 da                	mov    %ebx,%edx
  801d03:	d3 ea                	shr    %cl,%edx
  801d05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d09:	09 d1                	or     %edx,%ecx
  801d0b:	89 f2                	mov    %esi,%edx
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e3                	shl    %cl,%ebx
  801d15:	89 c1                	mov    %eax,%ecx
  801d17:	d3 ea                	shr    %cl,%edx
  801d19:	89 f9                	mov    %edi,%ecx
  801d1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d1f:	89 eb                	mov    %ebp,%ebx
  801d21:	d3 e6                	shl    %cl,%esi
  801d23:	89 c1                	mov    %eax,%ecx
  801d25:	d3 eb                	shr    %cl,%ebx
  801d27:	09 de                	or     %ebx,%esi
  801d29:	89 f0                	mov    %esi,%eax
  801d2b:	f7 74 24 08          	divl   0x8(%esp)
  801d2f:	89 d6                	mov    %edx,%esi
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	f7 64 24 0c          	mull   0xc(%esp)
  801d37:	39 d6                	cmp    %edx,%esi
  801d39:	72 15                	jb     801d50 <__udivdi3+0x100>
  801d3b:	89 f9                	mov    %edi,%ecx
  801d3d:	d3 e5                	shl    %cl,%ebp
  801d3f:	39 c5                	cmp    %eax,%ebp
  801d41:	73 04                	jae    801d47 <__udivdi3+0xf7>
  801d43:	39 d6                	cmp    %edx,%esi
  801d45:	74 09                	je     801d50 <__udivdi3+0x100>
  801d47:	89 d8                	mov    %ebx,%eax
  801d49:	31 ff                	xor    %edi,%edi
  801d4b:	e9 40 ff ff ff       	jmp    801c90 <__udivdi3+0x40>
  801d50:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d53:	31 ff                	xor    %edi,%edi
  801d55:	e9 36 ff ff ff       	jmp    801c90 <__udivdi3+0x40>
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	f3 0f 1e fb          	endbr32 
  801d64:	55                   	push   %ebp
  801d65:	57                   	push   %edi
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	83 ec 1c             	sub    $0x1c,%esp
  801d6b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d6f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d73:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d77:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	75 19                	jne    801d98 <__umoddi3+0x38>
  801d7f:	39 df                	cmp    %ebx,%edi
  801d81:	76 5d                	jbe    801de0 <__umoddi3+0x80>
  801d83:	89 f0                	mov    %esi,%eax
  801d85:	89 da                	mov    %ebx,%edx
  801d87:	f7 f7                	div    %edi
  801d89:	89 d0                	mov    %edx,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	83 c4 1c             	add    $0x1c,%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	89 f2                	mov    %esi,%edx
  801d9a:	39 d8                	cmp    %ebx,%eax
  801d9c:	76 12                	jbe    801db0 <__umoddi3+0x50>
  801d9e:	89 f0                	mov    %esi,%eax
  801da0:	89 da                	mov    %ebx,%edx
  801da2:	83 c4 1c             	add    $0x1c,%esp
  801da5:	5b                   	pop    %ebx
  801da6:	5e                   	pop    %esi
  801da7:	5f                   	pop    %edi
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    
  801daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db0:	0f bd e8             	bsr    %eax,%ebp
  801db3:	83 f5 1f             	xor    $0x1f,%ebp
  801db6:	75 50                	jne    801e08 <__umoddi3+0xa8>
  801db8:	39 d8                	cmp    %ebx,%eax
  801dba:	0f 82 e0 00 00 00    	jb     801ea0 <__umoddi3+0x140>
  801dc0:	89 d9                	mov    %ebx,%ecx
  801dc2:	39 f7                	cmp    %esi,%edi
  801dc4:	0f 86 d6 00 00 00    	jbe    801ea0 <__umoddi3+0x140>
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	89 ca                	mov    %ecx,%edx
  801dce:	83 c4 1c             	add    $0x1c,%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5f                   	pop    %edi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
  801dd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	89 fd                	mov    %edi,%ebp
  801de2:	85 ff                	test   %edi,%edi
  801de4:	75 0b                	jne    801df1 <__umoddi3+0x91>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
  801df7:	89 f0                	mov    %esi,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	31 d2                	xor    %edx,%edx
  801dff:	eb 8c                	jmp    801d8d <__umoddi3+0x2d>
  801e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e0f:	29 ea                	sub    %ebp,%edx
  801e11:	d3 e0                	shl    %cl,%eax
  801e13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 f8                	mov    %edi,%eax
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e21:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e25:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e29:	09 c1                	or     %eax,%ecx
  801e2b:	89 d8                	mov    %ebx,%eax
  801e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e31:	89 e9                	mov    %ebp,%ecx
  801e33:	d3 e7                	shl    %cl,%edi
  801e35:	89 d1                	mov    %edx,%ecx
  801e37:	d3 e8                	shr    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e3f:	d3 e3                	shl    %cl,%ebx
  801e41:	89 c7                	mov    %eax,%edi
  801e43:	89 d1                	mov    %edx,%ecx
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	89 fa                	mov    %edi,%edx
  801e4d:	d3 e6                	shl    %cl,%esi
  801e4f:	09 d8                	or     %ebx,%eax
  801e51:	f7 74 24 08          	divl   0x8(%esp)
  801e55:	89 d1                	mov    %edx,%ecx
  801e57:	89 f3                	mov    %esi,%ebx
  801e59:	f7 64 24 0c          	mull   0xc(%esp)
  801e5d:	89 c6                	mov    %eax,%esi
  801e5f:	89 d7                	mov    %edx,%edi
  801e61:	39 d1                	cmp    %edx,%ecx
  801e63:	72 06                	jb     801e6b <__umoddi3+0x10b>
  801e65:	75 10                	jne    801e77 <__umoddi3+0x117>
  801e67:	39 c3                	cmp    %eax,%ebx
  801e69:	73 0c                	jae    801e77 <__umoddi3+0x117>
  801e6b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e6f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e73:	89 d7                	mov    %edx,%edi
  801e75:	89 c6                	mov    %eax,%esi
  801e77:	89 ca                	mov    %ecx,%edx
  801e79:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e7e:	29 f3                	sub    %esi,%ebx
  801e80:	19 fa                	sbb    %edi,%edx
  801e82:	89 d0                	mov    %edx,%eax
  801e84:	d3 e0                	shl    %cl,%eax
  801e86:	89 e9                	mov    %ebp,%ecx
  801e88:	d3 eb                	shr    %cl,%ebx
  801e8a:	d3 ea                	shr    %cl,%edx
  801e8c:	09 d8                	or     %ebx,%eax
  801e8e:	83 c4 1c             	add    $0x1c,%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    
  801e96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	29 fe                	sub    %edi,%esi
  801ea2:	19 c3                	sbb    %eax,%ebx
  801ea4:	89 f2                	mov    %esi,%edx
  801ea6:	89 d9                	mov    %ebx,%ecx
  801ea8:	e9 1d ff ff ff       	jmp    801dca <__umoddi3+0x6a>
