
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
  80012d:	68 ea 1e 80 00       	push   $0x801eea
  800132:	6a 23                	push   $0x23
  800134:	68 07 1f 80 00       	push   $0x801f07
  800139:	e8 9c 0f 00 00       	call   8010da <_panic>

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
  8001ba:	68 ea 1e 80 00       	push   $0x801eea
  8001bf:	6a 23                	push   $0x23
  8001c1:	68 07 1f 80 00       	push   $0x801f07
  8001c6:	e8 0f 0f 00 00       	call   8010da <_panic>

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
  800200:	68 ea 1e 80 00       	push   $0x801eea
  800205:	6a 23                	push   $0x23
  800207:	68 07 1f 80 00       	push   $0x801f07
  80020c:	e8 c9 0e 00 00       	call   8010da <_panic>

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
  800246:	68 ea 1e 80 00       	push   $0x801eea
  80024b:	6a 23                	push   $0x23
  80024d:	68 07 1f 80 00       	push   $0x801f07
  800252:	e8 83 0e 00 00       	call   8010da <_panic>

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
  80028c:	68 ea 1e 80 00       	push   $0x801eea
  800291:	6a 23                	push   $0x23
  800293:	68 07 1f 80 00       	push   $0x801f07
  800298:	e8 3d 0e 00 00       	call   8010da <_panic>

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
  8002d2:	68 ea 1e 80 00       	push   $0x801eea
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 07 1f 80 00       	push   $0x801f07
  8002de:	e8 f7 0d 00 00       	call   8010da <_panic>

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
  800318:	68 ea 1e 80 00       	push   $0x801eea
  80031d:	6a 23                	push   $0x23
  80031f:	68 07 1f 80 00       	push   $0x801f07
  800324:	e8 b1 0d 00 00       	call   8010da <_panic>

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
  800384:	68 ea 1e 80 00       	push   $0x801eea
  800389:	6a 23                	push   $0x23
  80038b:	68 07 1f 80 00       	push   $0x801f07
  800390:	e8 45 0d 00 00       	call   8010da <_panic>

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
  80047b:	ba 94 1f 80 00       	mov    $0x801f94,%edx
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
  80049f:	68 18 1f 80 00       	push   $0x801f18
  8004a4:	e8 18 0d 00 00       	call   8011c1 <cprintf>
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
  80070d:	68 59 1f 80 00       	push   $0x801f59
  800712:	e8 aa 0a 00 00       	call   8011c1 <cprintf>
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
  8007de:	68 75 1f 80 00       	push   $0x801f75
  8007e3:	e8 d9 09 00 00       	call   8011c1 <cprintf>
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
  80088e:	68 38 1f 80 00       	push   $0x801f38
  800893:	e8 29 09 00 00       	call   8011c1 <cprintf>
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
  800932:	e8 fb 01 00 00       	call   800b32 <open>
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
  800984:	e8 0a 12 00 00       	call   801b93 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800989:	83 c4 0c             	add    $0xc,%esp
  80098c:	6a 00                	push   $0x0
  80098e:	53                   	push   %ebx
  80098f:	6a 00                	push   $0x0
  800991:	e8 a6 11 00 00       	call   801b3c <ipc_recv>
}
  800996:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80099d:	83 ec 0c             	sub    $0xc,%esp
  8009a0:	6a 01                	push   $0x1
  8009a2:	e8 52 12 00 00       	call   801bf9 <ipc_find_env>
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
  800a3a:	e8 8b 0d 00 00       	call   8017ca <strcpy>
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
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
	n = n > size_max ? size_max : n;
  800a6f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a74:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a79:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a82:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a88:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a8d:	50                   	push   %eax
  800a8e:	ff 75 0c             	pushl  0xc(%ebp)
  800a91:	68 08 50 80 00       	push   $0x805008
  800a96:	e8 e5 0e 00 00       	call   801980 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 04 00 00 00       	mov    $0x4,%eax
  800aa5:	e8 ba fe ff ff       	call   800964 <fsipc>
}
  800aaa:	c9                   	leave  
  800aab:	c3                   	ret    

00800aac <devfile_read>:
{
  800aac:	f3 0f 1e fb          	endbr32 
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 40 0c             	mov    0xc(%eax),%eax
  800abe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ac3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ace:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad3:	e8 8c fe ff ff       	call   800964 <fsipc>
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	85 c0                	test   %eax,%eax
  800adc:	78 1f                	js     800afd <devfile_read+0x51>
	assert(r <= n);
  800ade:	39 f0                	cmp    %esi,%eax
  800ae0:	77 24                	ja     800b06 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ae2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ae7:	7f 33                	jg     800b1c <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae9:	83 ec 04             	sub    $0x4,%esp
  800aec:	50                   	push   %eax
  800aed:	68 00 50 80 00       	push   $0x805000
  800af2:	ff 75 0c             	pushl  0xc(%ebp)
  800af5:	e8 86 0e 00 00       	call   801980 <memmove>
	return r;
  800afa:	83 c4 10             	add    $0x10,%esp
}
  800afd:	89 d8                	mov    %ebx,%eax
  800aff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    
	assert(r <= n);
  800b06:	68 a4 1f 80 00       	push   $0x801fa4
  800b0b:	68 ab 1f 80 00       	push   $0x801fab
  800b10:	6a 7c                	push   $0x7c
  800b12:	68 c0 1f 80 00       	push   $0x801fc0
  800b17:	e8 be 05 00 00       	call   8010da <_panic>
	assert(r <= PGSIZE);
  800b1c:	68 cb 1f 80 00       	push   $0x801fcb
  800b21:	68 ab 1f 80 00       	push   $0x801fab
  800b26:	6a 7d                	push   $0x7d
  800b28:	68 c0 1f 80 00       	push   $0x801fc0
  800b2d:	e8 a8 05 00 00       	call   8010da <_panic>

00800b32 <open>:
{
  800b32:	f3 0f 1e fb          	endbr32 
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 1c             	sub    $0x1c,%esp
  800b3e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b41:	56                   	push   %esi
  800b42:	e8 40 0c 00 00       	call   801787 <strlen>
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b4f:	7f 6c                	jg     800bbd <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b57:	50                   	push   %eax
  800b58:	e8 67 f8 ff ff       	call   8003c4 <fd_alloc>
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	83 c4 10             	add    $0x10,%esp
  800b62:	85 c0                	test   %eax,%eax
  800b64:	78 3c                	js     800ba2 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b66:	83 ec 08             	sub    $0x8,%esp
  800b69:	56                   	push   %esi
  800b6a:	68 00 50 80 00       	push   $0x805000
  800b6f:	e8 56 0c 00 00       	call   8017ca <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b84:	e8 db fd ff ff       	call   800964 <fsipc>
  800b89:	89 c3                	mov    %eax,%ebx
  800b8b:	83 c4 10             	add    $0x10,%esp
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	78 19                	js     800bab <open+0x79>
	return fd2num(fd);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	ff 75 f4             	pushl  -0xc(%ebp)
  800b98:	e8 f8 f7 ff ff       	call   800395 <fd2num>
  800b9d:	89 c3                	mov    %eax,%ebx
  800b9f:	83 c4 10             	add    $0x10,%esp
}
  800ba2:	89 d8                	mov    %ebx,%eax
  800ba4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    
		fd_close(fd, 0);
  800bab:	83 ec 08             	sub    $0x8,%esp
  800bae:	6a 00                	push   $0x0
  800bb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800bb3:	e8 10 f9 ff ff       	call   8004c8 <fd_close>
		return r;
  800bb8:	83 c4 10             	add    $0x10,%esp
  800bbb:	eb e5                	jmp    800ba2 <open+0x70>
		return -E_BAD_PATH;
  800bbd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bc2:	eb de                	jmp    800ba2 <open+0x70>

00800bc4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd3:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd8:	e8 87 fd ff ff       	call   800964 <fsipc>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bdf:	f3 0f 1e fb          	endbr32 
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	ff 75 08             	pushl  0x8(%ebp)
  800bf1:	e8 b3 f7 ff ff       	call   8003a9 <fd2data>
  800bf6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bf8:	83 c4 08             	add    $0x8,%esp
  800bfb:	68 d7 1f 80 00       	push   $0x801fd7
  800c00:	53                   	push   %ebx
  800c01:	e8 c4 0b 00 00       	call   8017ca <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c06:	8b 46 04             	mov    0x4(%esi),%eax
  800c09:	2b 06                	sub    (%esi),%eax
  800c0b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c11:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c18:	00 00 00 
	stat->st_dev = &devpipe;
  800c1b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c22:	30 80 00 
	return 0;
}
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c31:	f3 0f 1e fb          	endbr32 
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c3f:	53                   	push   %ebx
  800c40:	6a 00                	push   $0x0
  800c42:	e8 ca f5 ff ff       	call   800211 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c47:	89 1c 24             	mov    %ebx,(%esp)
  800c4a:	e8 5a f7 ff ff       	call   8003a9 <fd2data>
  800c4f:	83 c4 08             	add    $0x8,%esp
  800c52:	50                   	push   %eax
  800c53:	6a 00                	push   $0x0
  800c55:	e8 b7 f5 ff ff       	call   800211 <sys_page_unmap>
}
  800c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <_pipeisclosed>:
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 1c             	sub    $0x1c,%esp
  800c68:	89 c7                	mov    %eax,%edi
  800c6a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c6c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c71:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	57                   	push   %edi
  800c78:	e8 b9 0f 00 00       	call   801c36 <pageref>
  800c7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c80:	89 34 24             	mov    %esi,(%esp)
  800c83:	e8 ae 0f 00 00       	call   801c36 <pageref>
		nn = thisenv->env_runs;
  800c88:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c8e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	39 cb                	cmp    %ecx,%ebx
  800c96:	74 1b                	je     800cb3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c98:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c9b:	75 cf                	jne    800c6c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c9d:	8b 42 58             	mov    0x58(%edx),%eax
  800ca0:	6a 01                	push   $0x1
  800ca2:	50                   	push   %eax
  800ca3:	53                   	push   %ebx
  800ca4:	68 de 1f 80 00       	push   $0x801fde
  800ca9:	e8 13 05 00 00       	call   8011c1 <cprintf>
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	eb b9                	jmp    800c6c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800cb3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800cb6:	0f 94 c0             	sete   %al
  800cb9:	0f b6 c0             	movzbl %al,%eax
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <devpipe_write>:
{
  800cc4:	f3 0f 1e fb          	endbr32 
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 28             	sub    $0x28,%esp
  800cd1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800cd4:	56                   	push   %esi
  800cd5:	e8 cf f6 ff ff       	call   8003a9 <fd2data>
  800cda:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce7:	74 4f                	je     800d38 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ce9:	8b 43 04             	mov    0x4(%ebx),%eax
  800cec:	8b 0b                	mov    (%ebx),%ecx
  800cee:	8d 51 20             	lea    0x20(%ecx),%edx
  800cf1:	39 d0                	cmp    %edx,%eax
  800cf3:	72 14                	jb     800d09 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cf5:	89 da                	mov    %ebx,%edx
  800cf7:	89 f0                	mov    %esi,%eax
  800cf9:	e8 61 ff ff ff       	call   800c5f <_pipeisclosed>
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	75 3b                	jne    800d3d <devpipe_write+0x79>
			sys_yield();
  800d02:	e8 5a f4 ff ff       	call   800161 <sys_yield>
  800d07:	eb e0                	jmp    800ce9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800d10:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d13:	89 c2                	mov    %eax,%edx
  800d15:	c1 fa 1f             	sar    $0x1f,%edx
  800d18:	89 d1                	mov    %edx,%ecx
  800d1a:	c1 e9 1b             	shr    $0x1b,%ecx
  800d1d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d20:	83 e2 1f             	and    $0x1f,%edx
  800d23:	29 ca                	sub    %ecx,%edx
  800d25:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d29:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d2d:	83 c0 01             	add    $0x1,%eax
  800d30:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d33:	83 c7 01             	add    $0x1,%edi
  800d36:	eb ac                	jmp    800ce4 <devpipe_write+0x20>
	return i;
  800d38:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3b:	eb 05                	jmp    800d42 <devpipe_write+0x7e>
				return 0;
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <devpipe_read>:
{
  800d4a:	f3 0f 1e fb          	endbr32 
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 18             	sub    $0x18,%esp
  800d57:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d5a:	57                   	push   %edi
  800d5b:	e8 49 f6 ff ff       	call   8003a9 <fd2data>
  800d60:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	be 00 00 00 00       	mov    $0x0,%esi
  800d6a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d6d:	75 14                	jne    800d83 <devpipe_read+0x39>
	return i;
  800d6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d72:	eb 02                	jmp    800d76 <devpipe_read+0x2c>
				return i;
  800d74:	89 f0                	mov    %esi,%eax
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
			sys_yield();
  800d7e:	e8 de f3 ff ff       	call   800161 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d83:	8b 03                	mov    (%ebx),%eax
  800d85:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d88:	75 18                	jne    800da2 <devpipe_read+0x58>
			if (i > 0)
  800d8a:	85 f6                	test   %esi,%esi
  800d8c:	75 e6                	jne    800d74 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d8e:	89 da                	mov    %ebx,%edx
  800d90:	89 f8                	mov    %edi,%eax
  800d92:	e8 c8 fe ff ff       	call   800c5f <_pipeisclosed>
  800d97:	85 c0                	test   %eax,%eax
  800d99:	74 e3                	je     800d7e <devpipe_read+0x34>
				return 0;
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800da0:	eb d4                	jmp    800d76 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800da2:	99                   	cltd   
  800da3:	c1 ea 1b             	shr    $0x1b,%edx
  800da6:	01 d0                	add    %edx,%eax
  800da8:	83 e0 1f             	and    $0x1f,%eax
  800dab:	29 d0                	sub    %edx,%eax
  800dad:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800db8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800dbb:	83 c6 01             	add    $0x1,%esi
  800dbe:	eb aa                	jmp    800d6a <devpipe_read+0x20>

00800dc0 <pipe>:
{
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800dcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dcf:	50                   	push   %eax
  800dd0:	e8 ef f5 ff ff       	call   8003c4 <fd_alloc>
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	83 c4 10             	add    $0x10,%esp
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	0f 88 23 01 00 00    	js     800f05 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de2:	83 ec 04             	sub    $0x4,%esp
  800de5:	68 07 04 00 00       	push   $0x407
  800dea:	ff 75 f4             	pushl  -0xc(%ebp)
  800ded:	6a 00                	push   $0x0
  800def:	e8 90 f3 ff ff       	call   800184 <sys_page_alloc>
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	0f 88 04 01 00 00    	js     800f05 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e07:	50                   	push   %eax
  800e08:	e8 b7 f5 ff ff       	call   8003c4 <fd_alloc>
  800e0d:	89 c3                	mov    %eax,%ebx
  800e0f:	83 c4 10             	add    $0x10,%esp
  800e12:	85 c0                	test   %eax,%eax
  800e14:	0f 88 db 00 00 00    	js     800ef5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	68 07 04 00 00       	push   $0x407
  800e22:	ff 75 f0             	pushl  -0x10(%ebp)
  800e25:	6a 00                	push   $0x0
  800e27:	e8 58 f3 ff ff       	call   800184 <sys_page_alloc>
  800e2c:	89 c3                	mov    %eax,%ebx
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	85 c0                	test   %eax,%eax
  800e33:	0f 88 bc 00 00 00    	js     800ef5 <pipe+0x135>
	va = fd2data(fd0);
  800e39:	83 ec 0c             	sub    $0xc,%esp
  800e3c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3f:	e8 65 f5 ff ff       	call   8003a9 <fd2data>
  800e44:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e46:	83 c4 0c             	add    $0xc,%esp
  800e49:	68 07 04 00 00       	push   $0x407
  800e4e:	50                   	push   %eax
  800e4f:	6a 00                	push   $0x0
  800e51:	e8 2e f3 ff ff       	call   800184 <sys_page_alloc>
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	0f 88 82 00 00 00    	js     800ee5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	ff 75 f0             	pushl  -0x10(%ebp)
  800e69:	e8 3b f5 ff ff       	call   8003a9 <fd2data>
  800e6e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e75:	50                   	push   %eax
  800e76:	6a 00                	push   $0x0
  800e78:	56                   	push   %esi
  800e79:	6a 00                	push   $0x0
  800e7b:	e8 4b f3 ff ff       	call   8001cb <sys_page_map>
  800e80:	89 c3                	mov    %eax,%ebx
  800e82:	83 c4 20             	add    $0x20,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	78 4e                	js     800ed7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e89:	a1 20 30 80 00       	mov    0x803020,%eax
  800e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e91:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e93:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e96:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e9d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ea0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb2:	e8 de f4 ff ff       	call   800395 <fd2num>
  800eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eba:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ebc:	83 c4 04             	add    $0x4,%esp
  800ebf:	ff 75 f0             	pushl  -0x10(%ebp)
  800ec2:	e8 ce f4 ff ff       	call   800395 <fd2num>
  800ec7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eca:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed5:	eb 2e                	jmp    800f05 <pipe+0x145>
	sys_page_unmap(0, va);
  800ed7:	83 ec 08             	sub    $0x8,%esp
  800eda:	56                   	push   %esi
  800edb:	6a 00                	push   $0x0
  800edd:	e8 2f f3 ff ff       	call   800211 <sys_page_unmap>
  800ee2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	ff 75 f0             	pushl  -0x10(%ebp)
  800eeb:	6a 00                	push   $0x0
  800eed:	e8 1f f3 ff ff       	call   800211 <sys_page_unmap>
  800ef2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	ff 75 f4             	pushl  -0xc(%ebp)
  800efb:	6a 00                	push   $0x0
  800efd:	e8 0f f3 ff ff       	call   800211 <sys_page_unmap>
  800f02:	83 c4 10             	add    $0x10,%esp
}
  800f05:	89 d8                	mov    %ebx,%eax
  800f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <pipeisclosed>:
{
  800f0e:	f3 0f 1e fb          	endbr32 
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1b:	50                   	push   %eax
  800f1c:	ff 75 08             	pushl  0x8(%ebp)
  800f1f:	e8 f6 f4 ff ff       	call   80041a <fd_lookup>
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	78 18                	js     800f43 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f31:	e8 73 f4 ff ff       	call   8003a9 <fd2data>
  800f36:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f3b:	e8 1f fd ff ff       	call   800c5f <_pipeisclosed>
  800f40:	83 c4 10             	add    $0x10,%esp
}
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f45:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	c3                   	ret    

00800f4f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f4f:	f3 0f 1e fb          	endbr32 
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f59:	68 f6 1f 80 00       	push   $0x801ff6
  800f5e:	ff 75 0c             	pushl  0xc(%ebp)
  800f61:	e8 64 08 00 00       	call   8017ca <strcpy>
	return 0;
}
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <devcons_write>:
{
  800f6d:	f3 0f 1e fb          	endbr32 
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f7d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f82:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f88:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f8b:	73 31                	jae    800fbe <devcons_write+0x51>
		m = n - tot;
  800f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f90:	29 f3                	sub    %esi,%ebx
  800f92:	83 fb 7f             	cmp    $0x7f,%ebx
  800f95:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f9a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	53                   	push   %ebx
  800fa1:	89 f0                	mov    %esi,%eax
  800fa3:	03 45 0c             	add    0xc(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	57                   	push   %edi
  800fa8:	e8 d3 09 00 00       	call   801980 <memmove>
		sys_cputs(buf, m);
  800fad:	83 c4 08             	add    $0x8,%esp
  800fb0:	53                   	push   %ebx
  800fb1:	57                   	push   %edi
  800fb2:	e8 fd f0 ff ff       	call   8000b4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800fb7:	01 de                	add    %ebx,%esi
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	eb ca                	jmp    800f88 <devcons_write+0x1b>
}
  800fbe:	89 f0                	mov    %esi,%eax
  800fc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <devcons_read>:
{
  800fc8:	f3 0f 1e fb          	endbr32 
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 08             	sub    $0x8,%esp
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fdb:	74 21                	je     800ffe <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fdd:	e8 f4 f0 ff ff       	call   8000d6 <sys_cgetc>
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	75 07                	jne    800fed <devcons_read+0x25>
		sys_yield();
  800fe6:	e8 76 f1 ff ff       	call   800161 <sys_yield>
  800feb:	eb f0                	jmp    800fdd <devcons_read+0x15>
	if (c < 0)
  800fed:	78 0f                	js     800ffe <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fef:	83 f8 04             	cmp    $0x4,%eax
  800ff2:	74 0c                	je     801000 <devcons_read+0x38>
	*(char*)vbuf = c;
  800ff4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff7:	88 02                	mov    %al,(%edx)
	return 1;
  800ff9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    
		return 0;
  801000:	b8 00 00 00 00       	mov    $0x0,%eax
  801005:	eb f7                	jmp    800ffe <devcons_read+0x36>

00801007 <cputchar>:
{
  801007:	f3 0f 1e fb          	endbr32 
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801011:	8b 45 08             	mov    0x8(%ebp),%eax
  801014:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801017:	6a 01                	push   $0x1
  801019:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80101c:	50                   	push   %eax
  80101d:	e8 92 f0 ff ff       	call   8000b4 <sys_cputs>
}
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <getchar>:
{
  801027:	f3 0f 1e fb          	endbr32 
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801031:	6a 01                	push   $0x1
  801033:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	6a 00                	push   $0x0
  801039:	e8 5f f6 ff ff       	call   80069d <read>
	if (r < 0)
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	78 06                	js     80104b <getchar+0x24>
	if (r < 1)
  801045:	74 06                	je     80104d <getchar+0x26>
	return c;
  801047:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    
		return -E_EOF;
  80104d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801052:	eb f7                	jmp    80104b <getchar+0x24>

00801054 <iscons>:
{
  801054:	f3 0f 1e fb          	endbr32 
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	ff 75 08             	pushl  0x8(%ebp)
  801065:	e8 b0 f3 ff ff       	call   80041a <fd_lookup>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	78 11                	js     801082 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801074:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80107a:	39 10                	cmp    %edx,(%eax)
  80107c:	0f 94 c0             	sete   %al
  80107f:	0f b6 c0             	movzbl %al,%eax
}
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <opencons>:
{
  801084:	f3 0f 1e fb          	endbr32 
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80108e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801091:	50                   	push   %eax
  801092:	e8 2d f3 ff ff       	call   8003c4 <fd_alloc>
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	78 3a                	js     8010d8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80109e:	83 ec 04             	sub    $0x4,%esp
  8010a1:	68 07 04 00 00       	push   $0x407
  8010a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 d4 f0 ff ff       	call   800184 <sys_page_alloc>
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	78 21                	js     8010d8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8010b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8010c0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8010c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	50                   	push   %eax
  8010d0:	e8 c0 f2 ff ff       	call   800395 <fd2num>
  8010d5:	83 c4 10             	add    $0x10,%esp
}
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    

008010da <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010da:	f3 0f 1e fb          	endbr32 
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010e3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010e6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010ec:	e8 4d f0 ff ff       	call   80013e <sys_getenvid>
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	ff 75 0c             	pushl  0xc(%ebp)
  8010f7:	ff 75 08             	pushl  0x8(%ebp)
  8010fa:	56                   	push   %esi
  8010fb:	50                   	push   %eax
  8010fc:	68 04 20 80 00       	push   $0x802004
  801101:	e8 bb 00 00 00       	call   8011c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801106:	83 c4 18             	add    $0x18,%esp
  801109:	53                   	push   %ebx
  80110a:	ff 75 10             	pushl  0x10(%ebp)
  80110d:	e8 5a 00 00 00       	call   80116c <vcprintf>
	cprintf("\n");
  801112:	c7 04 24 ef 1f 80 00 	movl   $0x801fef,(%esp)
  801119:	e8 a3 00 00 00       	call   8011c1 <cprintf>
  80111e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801121:	cc                   	int3   
  801122:	eb fd                	jmp    801121 <_panic+0x47>

00801124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801124:	f3 0f 1e fb          	endbr32 
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	53                   	push   %ebx
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801132:	8b 13                	mov    (%ebx),%edx
  801134:	8d 42 01             	lea    0x1(%edx),%eax
  801137:	89 03                	mov    %eax,(%ebx)
  801139:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801140:	3d ff 00 00 00       	cmp    $0xff,%eax
  801145:	74 09                	je     801150 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801147:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80114b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801150:	83 ec 08             	sub    $0x8,%esp
  801153:	68 ff 00 00 00       	push   $0xff
  801158:	8d 43 08             	lea    0x8(%ebx),%eax
  80115b:	50                   	push   %eax
  80115c:	e8 53 ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  801161:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	eb db                	jmp    801147 <putch+0x23>

0080116c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80116c:	f3 0f 1e fb          	endbr32 
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801179:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801180:	00 00 00 
	b.cnt = 0;
  801183:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80118a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80118d:	ff 75 0c             	pushl  0xc(%ebp)
  801190:	ff 75 08             	pushl  0x8(%ebp)
  801193:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	68 24 11 80 00       	push   $0x801124
  80119f:	e8 20 01 00 00       	call   8012c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8011ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	e8 fb ee ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8011b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    

008011c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8011c1:	f3 0f 1e fb          	endbr32 
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8011cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8011ce:	50                   	push   %eax
  8011cf:	ff 75 08             	pushl  0x8(%ebp)
  8011d2:	e8 95 ff ff ff       	call   80116c <vcprintf>
	va_end(ap);

	return cnt;
}
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    

008011d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 1c             	sub    $0x1c,%esp
  8011e2:	89 c7                	mov    %eax,%edi
  8011e4:	89 d6                	mov    %edx,%esi
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ec:	89 d1                	mov    %edx,%ecx
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801206:	39 c2                	cmp    %eax,%edx
  801208:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80120b:	72 3e                	jb     80124b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	ff 75 18             	pushl  0x18(%ebp)
  801213:	83 eb 01             	sub    $0x1,%ebx
  801216:	53                   	push   %ebx
  801217:	50                   	push   %eax
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80121e:	ff 75 e0             	pushl  -0x20(%ebp)
  801221:	ff 75 dc             	pushl  -0x24(%ebp)
  801224:	ff 75 d8             	pushl  -0x28(%ebp)
  801227:	e8 54 0a 00 00       	call   801c80 <__udivdi3>
  80122c:	83 c4 18             	add    $0x18,%esp
  80122f:	52                   	push   %edx
  801230:	50                   	push   %eax
  801231:	89 f2                	mov    %esi,%edx
  801233:	89 f8                	mov    %edi,%eax
  801235:	e8 9f ff ff ff       	call   8011d9 <printnum>
  80123a:	83 c4 20             	add    $0x20,%esp
  80123d:	eb 13                	jmp    801252 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80123f:	83 ec 08             	sub    $0x8,%esp
  801242:	56                   	push   %esi
  801243:	ff 75 18             	pushl  0x18(%ebp)
  801246:	ff d7                	call   *%edi
  801248:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80124b:	83 eb 01             	sub    $0x1,%ebx
  80124e:	85 db                	test   %ebx,%ebx
  801250:	7f ed                	jg     80123f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	56                   	push   %esi
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125c:	ff 75 e0             	pushl  -0x20(%ebp)
  80125f:	ff 75 dc             	pushl  -0x24(%ebp)
  801262:	ff 75 d8             	pushl  -0x28(%ebp)
  801265:	e8 26 0b 00 00       	call   801d90 <__umoddi3>
  80126a:	83 c4 14             	add    $0x14,%esp
  80126d:	0f be 80 27 20 80 00 	movsbl 0x802027(%eax),%eax
  801274:	50                   	push   %eax
  801275:	ff d7                	call   *%edi
}
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801282:	f3 0f 1e fb          	endbr32 
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80128c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801290:	8b 10                	mov    (%eax),%edx
  801292:	3b 50 04             	cmp    0x4(%eax),%edx
  801295:	73 0a                	jae    8012a1 <sprintputch+0x1f>
		*b->buf++ = ch;
  801297:	8d 4a 01             	lea    0x1(%edx),%ecx
  80129a:	89 08                	mov    %ecx,(%eax)
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
  80129f:	88 02                	mov    %al,(%edx)
}
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <printfmt>:
{
  8012a3:	f3 0f 1e fb          	endbr32 
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012b0:	50                   	push   %eax
  8012b1:	ff 75 10             	pushl  0x10(%ebp)
  8012b4:	ff 75 0c             	pushl  0xc(%ebp)
  8012b7:	ff 75 08             	pushl  0x8(%ebp)
  8012ba:	e8 05 00 00 00       	call   8012c4 <vprintfmt>
}
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <vprintfmt>:
{
  8012c4:	f3 0f 1e fb          	endbr32 
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	57                   	push   %edi
  8012cc:	56                   	push   %esi
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 3c             	sub    $0x3c,%esp
  8012d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012da:	e9 4a 03 00 00       	jmp    801629 <vprintfmt+0x365>
		padc = ' ';
  8012df:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012e3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012ea:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012fd:	8d 47 01             	lea    0x1(%edi),%eax
  801300:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801303:	0f b6 17             	movzbl (%edi),%edx
  801306:	8d 42 dd             	lea    -0x23(%edx),%eax
  801309:	3c 55                	cmp    $0x55,%al
  80130b:	0f 87 de 03 00 00    	ja     8016ef <vprintfmt+0x42b>
  801311:	0f b6 c0             	movzbl %al,%eax
  801314:	3e ff 24 85 60 21 80 	notrack jmp *0x802160(,%eax,4)
  80131b:	00 
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80131f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801323:	eb d8                	jmp    8012fd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801328:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80132c:	eb cf                	jmp    8012fd <vprintfmt+0x39>
  80132e:	0f b6 d2             	movzbl %dl,%edx
  801331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801334:	b8 00 00 00 00       	mov    $0x0,%eax
  801339:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80133c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80133f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801343:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801346:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801349:	83 f9 09             	cmp    $0x9,%ecx
  80134c:	77 55                	ja     8013a3 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80134e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801351:	eb e9                	jmp    80133c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801353:	8b 45 14             	mov    0x14(%ebp),%eax
  801356:	8b 00                	mov    (%eax),%eax
  801358:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80135b:	8b 45 14             	mov    0x14(%ebp),%eax
  80135e:	8d 40 04             	lea    0x4(%eax),%eax
  801361:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136b:	79 90                	jns    8012fd <vprintfmt+0x39>
				width = precision, precision = -1;
  80136d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801373:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80137a:	eb 81                	jmp    8012fd <vprintfmt+0x39>
  80137c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137f:	85 c0                	test   %eax,%eax
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
  801386:	0f 49 d0             	cmovns %eax,%edx
  801389:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80138c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80138f:	e9 69 ff ff ff       	jmp    8012fd <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801397:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80139e:	e9 5a ff ff ff       	jmp    8012fd <vprintfmt+0x39>
  8013a3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013a9:	eb bc                	jmp    801367 <vprintfmt+0xa3>
			lflag++;
  8013ab:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013b1:	e9 47 ff ff ff       	jmp    8012fd <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b9:	8d 78 04             	lea    0x4(%eax),%edi
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	53                   	push   %ebx
  8013c0:	ff 30                	pushl  (%eax)
  8013c2:	ff d6                	call   *%esi
			break;
  8013c4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8013c7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8013ca:	e9 57 02 00 00       	jmp    801626 <vprintfmt+0x362>
			err = va_arg(ap, int);
  8013cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d2:	8d 78 04             	lea    0x4(%eax),%edi
  8013d5:	8b 00                	mov    (%eax),%eax
  8013d7:	99                   	cltd   
  8013d8:	31 d0                	xor    %edx,%eax
  8013da:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013dc:	83 f8 0f             	cmp    $0xf,%eax
  8013df:	7f 23                	jg     801404 <vprintfmt+0x140>
  8013e1:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8013e8:	85 d2                	test   %edx,%edx
  8013ea:	74 18                	je     801404 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8013ec:	52                   	push   %edx
  8013ed:	68 bd 1f 80 00       	push   $0x801fbd
  8013f2:	53                   	push   %ebx
  8013f3:	56                   	push   %esi
  8013f4:	e8 aa fe ff ff       	call   8012a3 <printfmt>
  8013f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8013fc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8013ff:	e9 22 02 00 00       	jmp    801626 <vprintfmt+0x362>
				printfmt(putch, putdat, "error %d", err);
  801404:	50                   	push   %eax
  801405:	68 3f 20 80 00       	push   $0x80203f
  80140a:	53                   	push   %ebx
  80140b:	56                   	push   %esi
  80140c:	e8 92 fe ff ff       	call   8012a3 <printfmt>
  801411:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801414:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801417:	e9 0a 02 00 00       	jmp    801626 <vprintfmt+0x362>
			if ((p = va_arg(ap, char *)) == NULL)
  80141c:	8b 45 14             	mov    0x14(%ebp),%eax
  80141f:	83 c0 04             	add    $0x4,%eax
  801422:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801425:	8b 45 14             	mov    0x14(%ebp),%eax
  801428:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80142a:	85 d2                	test   %edx,%edx
  80142c:	b8 38 20 80 00       	mov    $0x802038,%eax
  801431:	0f 45 c2             	cmovne %edx,%eax
  801434:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801437:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80143b:	7e 06                	jle    801443 <vprintfmt+0x17f>
  80143d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801441:	75 0d                	jne    801450 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801443:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801446:	89 c7                	mov    %eax,%edi
  801448:	03 45 e0             	add    -0x20(%ebp),%eax
  80144b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80144e:	eb 55                	jmp    8014a5 <vprintfmt+0x1e1>
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	ff 75 d8             	pushl  -0x28(%ebp)
  801456:	ff 75 cc             	pushl  -0x34(%ebp)
  801459:	e8 45 03 00 00       	call   8017a3 <strnlen>
  80145e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801461:	29 c2                	sub    %eax,%edx
  801463:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80146b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80146f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801472:	85 ff                	test   %edi,%edi
  801474:	7e 11                	jle    801487 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	53                   	push   %ebx
  80147a:	ff 75 e0             	pushl  -0x20(%ebp)
  80147d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80147f:	83 ef 01             	sub    $0x1,%edi
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	eb eb                	jmp    801472 <vprintfmt+0x1ae>
  801487:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80148a:	85 d2                	test   %edx,%edx
  80148c:	b8 00 00 00 00       	mov    $0x0,%eax
  801491:	0f 49 c2             	cmovns %edx,%eax
  801494:	29 c2                	sub    %eax,%edx
  801496:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801499:	eb a8                	jmp    801443 <vprintfmt+0x17f>
					putch(ch, putdat);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	53                   	push   %ebx
  80149f:	52                   	push   %edx
  8014a0:	ff d6                	call   *%esi
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014a8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014aa:	83 c7 01             	add    $0x1,%edi
  8014ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b1:	0f be d0             	movsbl %al,%edx
  8014b4:	85 d2                	test   %edx,%edx
  8014b6:	74 4b                	je     801503 <vprintfmt+0x23f>
  8014b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014bc:	78 06                	js     8014c4 <vprintfmt+0x200>
  8014be:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014c2:	78 1e                	js     8014e2 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8014c4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014c8:	74 d1                	je     80149b <vprintfmt+0x1d7>
  8014ca:	0f be c0             	movsbl %al,%eax
  8014cd:	83 e8 20             	sub    $0x20,%eax
  8014d0:	83 f8 5e             	cmp    $0x5e,%eax
  8014d3:	76 c6                	jbe    80149b <vprintfmt+0x1d7>
					putch('?', putdat);
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	53                   	push   %ebx
  8014d9:	6a 3f                	push   $0x3f
  8014db:	ff d6                	call   *%esi
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	eb c3                	jmp    8014a5 <vprintfmt+0x1e1>
  8014e2:	89 cf                	mov    %ecx,%edi
  8014e4:	eb 0e                	jmp    8014f4 <vprintfmt+0x230>
				putch(' ', putdat);
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	53                   	push   %ebx
  8014ea:	6a 20                	push   $0x20
  8014ec:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8014ee:	83 ef 01             	sub    $0x1,%edi
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 ff                	test   %edi,%edi
  8014f6:	7f ee                	jg     8014e6 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8014f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8014fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8014fe:	e9 23 01 00 00       	jmp    801626 <vprintfmt+0x362>
  801503:	89 cf                	mov    %ecx,%edi
  801505:	eb ed                	jmp    8014f4 <vprintfmt+0x230>
	if (lflag >= 2)
  801507:	83 f9 01             	cmp    $0x1,%ecx
  80150a:	7f 1b                	jg     801527 <vprintfmt+0x263>
	else if (lflag)
  80150c:	85 c9                	test   %ecx,%ecx
  80150e:	74 63                	je     801573 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801510:	8b 45 14             	mov    0x14(%ebp),%eax
  801513:	8b 00                	mov    (%eax),%eax
  801515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801518:	99                   	cltd   
  801519:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80151c:	8b 45 14             	mov    0x14(%ebp),%eax
  80151f:	8d 40 04             	lea    0x4(%eax),%eax
  801522:	89 45 14             	mov    %eax,0x14(%ebp)
  801525:	eb 17                	jmp    80153e <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801527:	8b 45 14             	mov    0x14(%ebp),%eax
  80152a:	8b 50 04             	mov    0x4(%eax),%edx
  80152d:	8b 00                	mov    (%eax),%eax
  80152f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801532:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801535:	8b 45 14             	mov    0x14(%ebp),%eax
  801538:	8d 40 08             	lea    0x8(%eax),%eax
  80153b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80153e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801541:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801544:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801549:	85 c9                	test   %ecx,%ecx
  80154b:	0f 89 bb 00 00 00    	jns    80160c <vprintfmt+0x348>
				putch('-', putdat);
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	53                   	push   %ebx
  801555:	6a 2d                	push   $0x2d
  801557:	ff d6                	call   *%esi
				num = -(long long) num;
  801559:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80155c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80155f:	f7 da                	neg    %edx
  801561:	83 d1 00             	adc    $0x0,%ecx
  801564:	f7 d9                	neg    %ecx
  801566:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80156e:	e9 99 00 00 00       	jmp    80160c <vprintfmt+0x348>
		return va_arg(*ap, int);
  801573:	8b 45 14             	mov    0x14(%ebp),%eax
  801576:	8b 00                	mov    (%eax),%eax
  801578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157b:	99                   	cltd   
  80157c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80157f:	8b 45 14             	mov    0x14(%ebp),%eax
  801582:	8d 40 04             	lea    0x4(%eax),%eax
  801585:	89 45 14             	mov    %eax,0x14(%ebp)
  801588:	eb b4                	jmp    80153e <vprintfmt+0x27a>
	if (lflag >= 2)
  80158a:	83 f9 01             	cmp    $0x1,%ecx
  80158d:	7f 1b                	jg     8015aa <vprintfmt+0x2e6>
	else if (lflag)
  80158f:	85 c9                	test   %ecx,%ecx
  801591:	74 2c                	je     8015bf <vprintfmt+0x2fb>
		return va_arg(*ap, unsigned long);
  801593:	8b 45 14             	mov    0x14(%ebp),%eax
  801596:	8b 10                	mov    (%eax),%edx
  801598:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159d:	8d 40 04             	lea    0x4(%eax),%eax
  8015a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015a3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8015a8:	eb 62                	jmp    80160c <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8015aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ad:	8b 10                	mov    (%eax),%edx
  8015af:	8b 48 04             	mov    0x4(%eax),%ecx
  8015b2:	8d 40 08             	lea    0x8(%eax),%eax
  8015b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015b8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8015bd:	eb 4d                	jmp    80160c <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8015bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c2:	8b 10                	mov    (%eax),%edx
  8015c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c9:	8d 40 04             	lea    0x4(%eax),%eax
  8015cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8015cf:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8015d4:	eb 36                	jmp    80160c <vprintfmt+0x348>
	if (lflag >= 2)
  8015d6:	83 f9 01             	cmp    $0x1,%ecx
  8015d9:	7f 17                	jg     8015f2 <vprintfmt+0x32e>
	else if (lflag)
  8015db:	85 c9                	test   %ecx,%ecx
  8015dd:	74 6e                	je     80164d <vprintfmt+0x389>
		return va_arg(*ap, long);
  8015df:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e2:	8b 10                	mov    (%eax),%edx
  8015e4:	89 d0                	mov    %edx,%eax
  8015e6:	99                   	cltd   
  8015e7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015ea:	8d 49 04             	lea    0x4(%ecx),%ecx
  8015ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8015f0:	eb 11                	jmp    801603 <vprintfmt+0x33f>
		return va_arg(*ap, long long);
  8015f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f5:	8b 50 04             	mov    0x4(%eax),%edx
  8015f8:	8b 00                	mov    (%eax),%eax
  8015fa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8015fd:	8d 49 08             	lea    0x8(%ecx),%ecx
  801600:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  801603:	89 d1                	mov    %edx,%ecx
  801605:	89 c2                	mov    %eax,%edx
            base = 8;
  801607:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801613:	57                   	push   %edi
  801614:	ff 75 e0             	pushl  -0x20(%ebp)
  801617:	50                   	push   %eax
  801618:	51                   	push   %ecx
  801619:	52                   	push   %edx
  80161a:	89 da                	mov    %ebx,%edx
  80161c:	89 f0                	mov    %esi,%eax
  80161e:	e8 b6 fb ff ff       	call   8011d9 <printnum>
			break;
  801623:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801629:	83 c7 01             	add    $0x1,%edi
  80162c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801630:	83 f8 25             	cmp    $0x25,%eax
  801633:	0f 84 a6 fc ff ff    	je     8012df <vprintfmt+0x1b>
			if (ch == '\0')
  801639:	85 c0                	test   %eax,%eax
  80163b:	0f 84 ce 00 00 00    	je     80170f <vprintfmt+0x44b>
			putch(ch, putdat);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	53                   	push   %ebx
  801645:	50                   	push   %eax
  801646:	ff d6                	call   *%esi
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb dc                	jmp    801629 <vprintfmt+0x365>
		return va_arg(*ap, int);
  80164d:	8b 45 14             	mov    0x14(%ebp),%eax
  801650:	8b 10                	mov    (%eax),%edx
  801652:	89 d0                	mov    %edx,%eax
  801654:	99                   	cltd   
  801655:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801658:	8d 49 04             	lea    0x4(%ecx),%ecx
  80165b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80165e:	eb a3                	jmp    801603 <vprintfmt+0x33f>
			putch('0', putdat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	53                   	push   %ebx
  801664:	6a 30                	push   $0x30
  801666:	ff d6                	call   *%esi
			putch('x', putdat);
  801668:	83 c4 08             	add    $0x8,%esp
  80166b:	53                   	push   %ebx
  80166c:	6a 78                	push   $0x78
  80166e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801670:	8b 45 14             	mov    0x14(%ebp),%eax
  801673:	8b 10                	mov    (%eax),%edx
  801675:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80167a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80167d:	8d 40 04             	lea    0x4(%eax),%eax
  801680:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801683:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801688:	eb 82                	jmp    80160c <vprintfmt+0x348>
	if (lflag >= 2)
  80168a:	83 f9 01             	cmp    $0x1,%ecx
  80168d:	7f 1e                	jg     8016ad <vprintfmt+0x3e9>
	else if (lflag)
  80168f:	85 c9                	test   %ecx,%ecx
  801691:	74 32                	je     8016c5 <vprintfmt+0x401>
		return va_arg(*ap, unsigned long);
  801693:	8b 45 14             	mov    0x14(%ebp),%eax
  801696:	8b 10                	mov    (%eax),%edx
  801698:	b9 00 00 00 00       	mov    $0x0,%ecx
  80169d:	8d 40 04             	lea    0x4(%eax),%eax
  8016a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016a3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8016a8:	e9 5f ff ff ff       	jmp    80160c <vprintfmt+0x348>
		return va_arg(*ap, unsigned long long);
  8016ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b0:	8b 10                	mov    (%eax),%edx
  8016b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8016b5:	8d 40 08             	lea    0x8(%eax),%eax
  8016b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016bb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8016c0:	e9 47 ff ff ff       	jmp    80160c <vprintfmt+0x348>
		return va_arg(*ap, unsigned int);
  8016c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c8:	8b 10                	mov    (%eax),%edx
  8016ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016cf:	8d 40 04             	lea    0x4(%eax),%eax
  8016d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8016d5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8016da:	e9 2d ff ff ff       	jmp    80160c <vprintfmt+0x348>
			putch(ch, putdat);
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	53                   	push   %ebx
  8016e3:	6a 25                	push   $0x25
  8016e5:	ff d6                	call   *%esi
			break;
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	e9 37 ff ff ff       	jmp    801626 <vprintfmt+0x362>
			putch('%', putdat);
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	53                   	push   %ebx
  8016f3:	6a 25                	push   $0x25
  8016f5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	89 f8                	mov    %edi,%eax
  8016fc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801700:	74 05                	je     801707 <vprintfmt+0x443>
  801702:	83 e8 01             	sub    $0x1,%eax
  801705:	eb f5                	jmp    8016fc <vprintfmt+0x438>
  801707:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80170a:	e9 17 ff ff ff       	jmp    801626 <vprintfmt+0x362>
}
  80170f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5f                   	pop    %edi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801717:	f3 0f 1e fb          	endbr32 
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	83 ec 18             	sub    $0x18,%esp
  801721:	8b 45 08             	mov    0x8(%ebp),%eax
  801724:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801727:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80172a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80172e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801731:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801738:	85 c0                	test   %eax,%eax
  80173a:	74 26                	je     801762 <vsnprintf+0x4b>
  80173c:	85 d2                	test   %edx,%edx
  80173e:	7e 22                	jle    801762 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801740:	ff 75 14             	pushl  0x14(%ebp)
  801743:	ff 75 10             	pushl  0x10(%ebp)
  801746:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	68 82 12 80 00       	push   $0x801282
  80174f:	e8 70 fb ff ff       	call   8012c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801754:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801757:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80175a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175d:	83 c4 10             	add    $0x10,%esp
}
  801760:	c9                   	leave  
  801761:	c3                   	ret    
		return -E_INVAL;
  801762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801767:	eb f7                	jmp    801760 <vsnprintf+0x49>

00801769 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801769:	f3 0f 1e fb          	endbr32 
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801776:	50                   	push   %eax
  801777:	ff 75 10             	pushl  0x10(%ebp)
  80177a:	ff 75 0c             	pushl  0xc(%ebp)
  80177d:	ff 75 08             	pushl  0x8(%ebp)
  801780:	e8 92 ff ff ff       	call   801717 <vsnprintf>
	va_end(ap);

	return rc;
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801787:	f3 0f 1e fb          	endbr32 
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801791:	b8 00 00 00 00       	mov    $0x0,%eax
  801796:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80179a:	74 05                	je     8017a1 <strlen+0x1a>
		n++;
  80179c:	83 c0 01             	add    $0x1,%eax
  80179f:	eb f5                	jmp    801796 <strlen+0xf>
	return n;
}
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8017a3:	f3 0f 1e fb          	endbr32 
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b5:	39 d0                	cmp    %edx,%eax
  8017b7:	74 0d                	je     8017c6 <strnlen+0x23>
  8017b9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8017bd:	74 05                	je     8017c4 <strnlen+0x21>
		n++;
  8017bf:	83 c0 01             	add    $0x1,%eax
  8017c2:	eb f1                	jmp    8017b5 <strnlen+0x12>
  8017c4:	89 c2                	mov    %eax,%edx
	return n;
}
  8017c6:	89 d0                	mov    %edx,%eax
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8017ca:	f3 0f 1e fb          	endbr32 
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017dd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8017e1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8017e4:	83 c0 01             	add    $0x1,%eax
  8017e7:	84 d2                	test   %dl,%dl
  8017e9:	75 f2                	jne    8017dd <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8017eb:	89 c8                	mov    %ecx,%eax
  8017ed:	5b                   	pop    %ebx
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8017f0:	f3 0f 1e fb          	endbr32 
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 10             	sub    $0x10,%esp
  8017fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8017fe:	53                   	push   %ebx
  8017ff:	e8 83 ff ff ff       	call   801787 <strlen>
  801804:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801807:	ff 75 0c             	pushl  0xc(%ebp)
  80180a:	01 d8                	add    %ebx,%eax
  80180c:	50                   	push   %eax
  80180d:	e8 b8 ff ff ff       	call   8017ca <strcpy>
	return dst;
}
  801812:	89 d8                	mov    %ebx,%eax
  801814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801819:	f3 0f 1e fb          	endbr32 
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
  801822:	8b 75 08             	mov    0x8(%ebp),%esi
  801825:	8b 55 0c             	mov    0xc(%ebp),%edx
  801828:	89 f3                	mov    %esi,%ebx
  80182a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80182d:	89 f0                	mov    %esi,%eax
  80182f:	39 d8                	cmp    %ebx,%eax
  801831:	74 11                	je     801844 <strncpy+0x2b>
		*dst++ = *src;
  801833:	83 c0 01             	add    $0x1,%eax
  801836:	0f b6 0a             	movzbl (%edx),%ecx
  801839:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80183c:	80 f9 01             	cmp    $0x1,%cl
  80183f:	83 da ff             	sbb    $0xffffffff,%edx
  801842:	eb eb                	jmp    80182f <strncpy+0x16>
	}
	return ret;
}
  801844:	89 f0                	mov    %esi,%eax
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80184a:	f3 0f 1e fb          	endbr32 
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	8b 75 08             	mov    0x8(%ebp),%esi
  801856:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801859:	8b 55 10             	mov    0x10(%ebp),%edx
  80185c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80185e:	85 d2                	test   %edx,%edx
  801860:	74 21                	je     801883 <strlcpy+0x39>
  801862:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801866:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801868:	39 c2                	cmp    %eax,%edx
  80186a:	74 14                	je     801880 <strlcpy+0x36>
  80186c:	0f b6 19             	movzbl (%ecx),%ebx
  80186f:	84 db                	test   %bl,%bl
  801871:	74 0b                	je     80187e <strlcpy+0x34>
			*dst++ = *src++;
  801873:	83 c1 01             	add    $0x1,%ecx
  801876:	83 c2 01             	add    $0x1,%edx
  801879:	88 5a ff             	mov    %bl,-0x1(%edx)
  80187c:	eb ea                	jmp    801868 <strlcpy+0x1e>
  80187e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801880:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801883:	29 f0                	sub    %esi,%eax
}
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    

00801889 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801889:	f3 0f 1e fb          	endbr32 
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801893:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801896:	0f b6 01             	movzbl (%ecx),%eax
  801899:	84 c0                	test   %al,%al
  80189b:	74 0c                	je     8018a9 <strcmp+0x20>
  80189d:	3a 02                	cmp    (%edx),%al
  80189f:	75 08                	jne    8018a9 <strcmp+0x20>
		p++, q++;
  8018a1:	83 c1 01             	add    $0x1,%ecx
  8018a4:	83 c2 01             	add    $0x1,%edx
  8018a7:	eb ed                	jmp    801896 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018a9:	0f b6 c0             	movzbl %al,%eax
  8018ac:	0f b6 12             	movzbl (%edx),%edx
  8018af:	29 d0                	sub    %edx,%eax
}
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018b3:	f3 0f 1e fb          	endbr32 
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	53                   	push   %ebx
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c1:	89 c3                	mov    %eax,%ebx
  8018c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8018c6:	eb 06                	jmp    8018ce <strncmp+0x1b>
		n--, p++, q++;
  8018c8:	83 c0 01             	add    $0x1,%eax
  8018cb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8018ce:	39 d8                	cmp    %ebx,%eax
  8018d0:	74 16                	je     8018e8 <strncmp+0x35>
  8018d2:	0f b6 08             	movzbl (%eax),%ecx
  8018d5:	84 c9                	test   %cl,%cl
  8018d7:	74 04                	je     8018dd <strncmp+0x2a>
  8018d9:	3a 0a                	cmp    (%edx),%cl
  8018db:	74 eb                	je     8018c8 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8018dd:	0f b6 00             	movzbl (%eax),%eax
  8018e0:	0f b6 12             	movzbl (%edx),%edx
  8018e3:	29 d0                	sub    %edx,%eax
}
  8018e5:	5b                   	pop    %ebx
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    
		return 0;
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ed:	eb f6                	jmp    8018e5 <strncmp+0x32>

008018ef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8018ef:	f3 0f 1e fb          	endbr32 
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8018fd:	0f b6 10             	movzbl (%eax),%edx
  801900:	84 d2                	test   %dl,%dl
  801902:	74 09                	je     80190d <strchr+0x1e>
		if (*s == c)
  801904:	38 ca                	cmp    %cl,%dl
  801906:	74 0a                	je     801912 <strchr+0x23>
	for (; *s; s++)
  801908:	83 c0 01             	add    $0x1,%eax
  80190b:	eb f0                	jmp    8018fd <strchr+0xe>
			return (char *) s;
	return 0;
  80190d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801914:	f3 0f 1e fb          	endbr32 
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	8b 45 08             	mov    0x8(%ebp),%eax
  80191e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801922:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801925:	38 ca                	cmp    %cl,%dl
  801927:	74 09                	je     801932 <strfind+0x1e>
  801929:	84 d2                	test   %dl,%dl
  80192b:	74 05                	je     801932 <strfind+0x1e>
	for (; *s; s++)
  80192d:	83 c0 01             	add    $0x1,%eax
  801930:	eb f0                	jmp    801922 <strfind+0xe>
			break;
	return (char *) s;
}
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801934:	f3 0f 1e fb          	endbr32 
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	57                   	push   %edi
  80193c:	56                   	push   %esi
  80193d:	53                   	push   %ebx
  80193e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801944:	85 c9                	test   %ecx,%ecx
  801946:	74 31                	je     801979 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801948:	89 f8                	mov    %edi,%eax
  80194a:	09 c8                	or     %ecx,%eax
  80194c:	a8 03                	test   $0x3,%al
  80194e:	75 23                	jne    801973 <memset+0x3f>
		c &= 0xFF;
  801950:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801954:	89 d3                	mov    %edx,%ebx
  801956:	c1 e3 08             	shl    $0x8,%ebx
  801959:	89 d0                	mov    %edx,%eax
  80195b:	c1 e0 18             	shl    $0x18,%eax
  80195e:	89 d6                	mov    %edx,%esi
  801960:	c1 e6 10             	shl    $0x10,%esi
  801963:	09 f0                	or     %esi,%eax
  801965:	09 c2                	or     %eax,%edx
  801967:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801969:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80196c:	89 d0                	mov    %edx,%eax
  80196e:	fc                   	cld    
  80196f:	f3 ab                	rep stos %eax,%es:(%edi)
  801971:	eb 06                	jmp    801979 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801973:	8b 45 0c             	mov    0xc(%ebp),%eax
  801976:	fc                   	cld    
  801977:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801979:	89 f8                	mov    %edi,%eax
  80197b:	5b                   	pop    %ebx
  80197c:	5e                   	pop    %esi
  80197d:	5f                   	pop    %edi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801980:	f3 0f 1e fb          	endbr32 
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	57                   	push   %edi
  801988:	56                   	push   %esi
  801989:	8b 45 08             	mov    0x8(%ebp),%eax
  80198c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80198f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801992:	39 c6                	cmp    %eax,%esi
  801994:	73 32                	jae    8019c8 <memmove+0x48>
  801996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801999:	39 c2                	cmp    %eax,%edx
  80199b:	76 2b                	jbe    8019c8 <memmove+0x48>
		s += n;
		d += n;
  80199d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019a0:	89 fe                	mov    %edi,%esi
  8019a2:	09 ce                	or     %ecx,%esi
  8019a4:	09 d6                	or     %edx,%esi
  8019a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019ac:	75 0e                	jne    8019bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019ae:	83 ef 04             	sub    $0x4,%edi
  8019b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8019b7:	fd                   	std    
  8019b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019ba:	eb 09                	jmp    8019c5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019bc:	83 ef 01             	sub    $0x1,%edi
  8019bf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8019c2:	fd                   	std    
  8019c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019c5:	fc                   	cld    
  8019c6:	eb 1a                	jmp    8019e2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019c8:	89 c2                	mov    %eax,%edx
  8019ca:	09 ca                	or     %ecx,%edx
  8019cc:	09 f2                	or     %esi,%edx
  8019ce:	f6 c2 03             	test   $0x3,%dl
  8019d1:	75 0a                	jne    8019dd <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019d3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8019d6:	89 c7                	mov    %eax,%edi
  8019d8:	fc                   	cld    
  8019d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019db:	eb 05                	jmp    8019e2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8019dd:	89 c7                	mov    %eax,%edi
  8019df:	fc                   	cld    
  8019e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8019e2:	5e                   	pop    %esi
  8019e3:	5f                   	pop    %edi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8019e6:	f3 0f 1e fb          	endbr32 
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8019f0:	ff 75 10             	pushl  0x10(%ebp)
  8019f3:	ff 75 0c             	pushl  0xc(%ebp)
  8019f6:	ff 75 08             	pushl  0x8(%ebp)
  8019f9:	e8 82 ff ff ff       	call   801980 <memmove>
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a00:	f3 0f 1e fb          	endbr32 
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	56                   	push   %esi
  801a08:	53                   	push   %ebx
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0f:	89 c6                	mov    %eax,%esi
  801a11:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a14:	39 f0                	cmp    %esi,%eax
  801a16:	74 1c                	je     801a34 <memcmp+0x34>
		if (*s1 != *s2)
  801a18:	0f b6 08             	movzbl (%eax),%ecx
  801a1b:	0f b6 1a             	movzbl (%edx),%ebx
  801a1e:	38 d9                	cmp    %bl,%cl
  801a20:	75 08                	jne    801a2a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801a22:	83 c0 01             	add    $0x1,%eax
  801a25:	83 c2 01             	add    $0x1,%edx
  801a28:	eb ea                	jmp    801a14 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801a2a:	0f b6 c1             	movzbl %cl,%eax
  801a2d:	0f b6 db             	movzbl %bl,%ebx
  801a30:	29 d8                	sub    %ebx,%eax
  801a32:	eb 05                	jmp    801a39 <memcmp+0x39>
	}

	return 0;
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a3d:	f3 0f 1e fb          	endbr32 
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	8b 45 08             	mov    0x8(%ebp),%eax
  801a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a4a:	89 c2                	mov    %eax,%edx
  801a4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a4f:	39 d0                	cmp    %edx,%eax
  801a51:	73 09                	jae    801a5c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a53:	38 08                	cmp    %cl,(%eax)
  801a55:	74 05                	je     801a5c <memfind+0x1f>
	for (; s < ends; s++)
  801a57:	83 c0 01             	add    $0x1,%eax
  801a5a:	eb f3                	jmp    801a4f <memfind+0x12>
			break;
	return (void *) s;
}
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a5e:	f3 0f 1e fb          	endbr32 
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	57                   	push   %edi
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a6e:	eb 03                	jmp    801a73 <strtol+0x15>
		s++;
  801a70:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801a73:	0f b6 01             	movzbl (%ecx),%eax
  801a76:	3c 20                	cmp    $0x20,%al
  801a78:	74 f6                	je     801a70 <strtol+0x12>
  801a7a:	3c 09                	cmp    $0x9,%al
  801a7c:	74 f2                	je     801a70 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801a7e:	3c 2b                	cmp    $0x2b,%al
  801a80:	74 2a                	je     801aac <strtol+0x4e>
	int neg = 0;
  801a82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801a87:	3c 2d                	cmp    $0x2d,%al
  801a89:	74 2b                	je     801ab6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a8b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801a91:	75 0f                	jne    801aa2 <strtol+0x44>
  801a93:	80 39 30             	cmpb   $0x30,(%ecx)
  801a96:	74 28                	je     801ac0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a98:	85 db                	test   %ebx,%ebx
  801a9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a9f:	0f 44 d8             	cmove  %eax,%ebx
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801aaa:	eb 46                	jmp    801af2 <strtol+0x94>
		s++;
  801aac:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801aaf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab4:	eb d5                	jmp    801a8b <strtol+0x2d>
		s++, neg = 1;
  801ab6:	83 c1 01             	add    $0x1,%ecx
  801ab9:	bf 01 00 00 00       	mov    $0x1,%edi
  801abe:	eb cb                	jmp    801a8b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ac0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ac4:	74 0e                	je     801ad4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801ac6:	85 db                	test   %ebx,%ebx
  801ac8:	75 d8                	jne    801aa2 <strtol+0x44>
		s++, base = 8;
  801aca:	83 c1 01             	add    $0x1,%ecx
  801acd:	bb 08 00 00 00       	mov    $0x8,%ebx
  801ad2:	eb ce                	jmp    801aa2 <strtol+0x44>
		s += 2, base = 16;
  801ad4:	83 c1 02             	add    $0x2,%ecx
  801ad7:	bb 10 00 00 00       	mov    $0x10,%ebx
  801adc:	eb c4                	jmp    801aa2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801ade:	0f be d2             	movsbl %dl,%edx
  801ae1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ae4:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ae7:	7d 3a                	jge    801b23 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801ae9:	83 c1 01             	add    $0x1,%ecx
  801aec:	0f af 45 10          	imul   0x10(%ebp),%eax
  801af0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801af2:	0f b6 11             	movzbl (%ecx),%edx
  801af5:	8d 72 d0             	lea    -0x30(%edx),%esi
  801af8:	89 f3                	mov    %esi,%ebx
  801afa:	80 fb 09             	cmp    $0x9,%bl
  801afd:	76 df                	jbe    801ade <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801aff:	8d 72 9f             	lea    -0x61(%edx),%esi
  801b02:	89 f3                	mov    %esi,%ebx
  801b04:	80 fb 19             	cmp    $0x19,%bl
  801b07:	77 08                	ja     801b11 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801b09:	0f be d2             	movsbl %dl,%edx
  801b0c:	83 ea 57             	sub    $0x57,%edx
  801b0f:	eb d3                	jmp    801ae4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801b11:	8d 72 bf             	lea    -0x41(%edx),%esi
  801b14:	89 f3                	mov    %esi,%ebx
  801b16:	80 fb 19             	cmp    $0x19,%bl
  801b19:	77 08                	ja     801b23 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801b1b:	0f be d2             	movsbl %dl,%edx
  801b1e:	83 ea 37             	sub    $0x37,%edx
  801b21:	eb c1                	jmp    801ae4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801b23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b27:	74 05                	je     801b2e <strtol+0xd0>
		*endptr = (char *) s;
  801b29:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b2c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801b2e:	89 c2                	mov    %eax,%edx
  801b30:	f7 da                	neg    %edx
  801b32:	85 ff                	test   %edi,%edi
  801b34:	0f 45 c2             	cmovne %edx,%eax
}
  801b37:	5b                   	pop    %ebx
  801b38:	5e                   	pop    %esi
  801b39:	5f                   	pop    %edi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b3c:	f3 0f 1e fb          	endbr32 
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
    int32_t ret;
    if ( (ret = sys_ipc_recv(pg == NULL ? (void*)-1 : pg)) < 0) {
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b55:	0f 44 c2             	cmove  %edx,%eax
  801b58:	83 ec 0c             	sub    $0xc,%esp
  801b5b:	50                   	push   %eax
  801b5c:	e8 ef e7 ff ff       	call   800350 <sys_ipc_recv>
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 24                	js     801b8c <ipc_recv+0x50>
        return ret;
    }

    if (perm_store) {
  801b68:	85 f6                	test   %esi,%esi
  801b6a:	74 0a                	je     801b76 <ipc_recv+0x3a>
        *perm_store = thisenv->env_ipc_perm;
  801b6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b71:	8b 40 78             	mov    0x78(%eax),%eax
  801b74:	89 06                	mov    %eax,(%esi)
    }

    if (from_env_store) {
  801b76:	85 db                	test   %ebx,%ebx
  801b78:	74 0a                	je     801b84 <ipc_recv+0x48>
        *from_env_store = thisenv->env_ipc_from;
  801b7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7f:	8b 40 74             	mov    0x74(%eax),%eax
  801b82:	89 03                	mov    %eax,(%ebx)
    }

	return thisenv->env_ipc_value;
  801b84:	a1 04 40 80 00       	mov    0x804004,%eax
  801b89:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5e                   	pop    %esi
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b93:	f3 0f 1e fb          	endbr32 
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	57                   	push   %edi
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 1c             	sub    $0x1c,%esp
  801ba0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801baa:	0f 45 d0             	cmovne %eax,%edx
  801bad:	89 d7                	mov    %edx,%edi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
    int32_t ret = -E_IPC_NOT_RECV;
    int threshold = 16;
    int cur_wait = 1;
  801baf:	be 01 00 00 00       	mov    $0x1,%esi
  801bb4:	eb 1f                	jmp    801bd5 <ipc_send+0x42>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
        //sys_yield();

        // exponential backoff
        for (int i=0; i<cur_wait; ++i) {
            sys_yield();
  801bb6:	e8 a6 e5 ff ff       	call   800161 <sys_yield>
        for (int i=0; i<cur_wait; ++i) {
  801bbb:	83 c3 01             	add    $0x1,%ebx
  801bbe:	39 de                	cmp    %ebx,%esi
  801bc0:	7f f4                	jg     801bb6 <ipc_send+0x23>
        }
        // update wait value
        cur_wait <<= 1;
  801bc2:	01 f6                	add    %esi,%esi
        if (cur_wait > threshold) {
            cur_wait = 1;
  801bc4:	83 fe 11             	cmp    $0x11,%esi
  801bc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801bcc:	0f 4d f0             	cmovge %eax,%esi
        }

    }
    while (ret == -E_IPC_NOT_RECV);
  801bcf:	83 7d e4 f9          	cmpl   $0xfffffff9,-0x1c(%ebp)
  801bd3:	75 1c                	jne    801bf1 <ipc_send+0x5e>
        ret = sys_ipc_try_send(to_env, val, pg == NULL ? (void*)-1 : pg, perm);
  801bd5:	ff 75 14             	pushl  0x14(%ebp)
  801bd8:	57                   	push   %edi
  801bd9:	ff 75 0c             	pushl  0xc(%ebp)
  801bdc:	ff 75 08             	pushl  0x8(%ebp)
  801bdf:	e8 45 e7 ff ff       	call   800329 <sys_ipc_try_send>
  801be4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int i=0; i<cur_wait; ++i) {
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bef:	eb cd                	jmp    801bbe <ipc_send+0x2b>
}
  801bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bf9:	f3 0f 1e fb          	endbr32 
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c08:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c0b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c11:	8b 52 50             	mov    0x50(%edx),%edx
  801c14:	39 ca                	cmp    %ecx,%edx
  801c16:	74 11                	je     801c29 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c18:	83 c0 01             	add    $0x1,%eax
  801c1b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c20:	75 e6                	jne    801c08 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
  801c27:	eb 0b                	jmp    801c34 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c29:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c2c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c31:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c36:	f3 0f 1e fb          	endbr32 
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	c1 ea 16             	shr    $0x16,%edx
  801c45:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c4c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c51:	f6 c1 01             	test   $0x1,%cl
  801c54:	74 1c                	je     801c72 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c56:	c1 e8 0c             	shr    $0xc,%eax
  801c59:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c60:	a8 01                	test   $0x1,%al
  801c62:	74 0e                	je     801c72 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c64:	c1 e8 0c             	shr    $0xc,%eax
  801c67:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c6e:	ef 
  801c6f:	0f b7 d2             	movzwl %dx,%edx
}
  801c72:	89 d0                	mov    %edx,%eax
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__udivdi3>:
  801c80:	f3 0f 1e fb          	endbr32 
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c93:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c9b:	85 d2                	test   %edx,%edx
  801c9d:	75 19                	jne    801cb8 <__udivdi3+0x38>
  801c9f:	39 f3                	cmp    %esi,%ebx
  801ca1:	76 4d                	jbe    801cf0 <__udivdi3+0x70>
  801ca3:	31 ff                	xor    %edi,%edi
  801ca5:	89 e8                	mov    %ebp,%eax
  801ca7:	89 f2                	mov    %esi,%edx
  801ca9:	f7 f3                	div    %ebx
  801cab:	89 fa                	mov    %edi,%edx
  801cad:	83 c4 1c             	add    $0x1c,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	76 14                	jbe    801cd0 <__udivdi3+0x50>
  801cbc:	31 ff                	xor    %edi,%edi
  801cbe:	31 c0                	xor    %eax,%eax
  801cc0:	89 fa                	mov    %edi,%edx
  801cc2:	83 c4 1c             	add    $0x1c,%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	0f bd fa             	bsr    %edx,%edi
  801cd3:	83 f7 1f             	xor    $0x1f,%edi
  801cd6:	75 48                	jne    801d20 <__udivdi3+0xa0>
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	72 06                	jb     801ce2 <__udivdi3+0x62>
  801cdc:	31 c0                	xor    %eax,%eax
  801cde:	39 eb                	cmp    %ebp,%ebx
  801ce0:	77 de                	ja     801cc0 <__udivdi3+0x40>
  801ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce7:	eb d7                	jmp    801cc0 <__udivdi3+0x40>
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 d9                	mov    %ebx,%ecx
  801cf2:	85 db                	test   %ebx,%ebx
  801cf4:	75 0b                	jne    801d01 <__udivdi3+0x81>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f3                	div    %ebx
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	31 d2                	xor    %edx,%edx
  801d03:	89 f0                	mov    %esi,%eax
  801d05:	f7 f1                	div    %ecx
  801d07:	89 c6                	mov    %eax,%esi
  801d09:	89 e8                	mov    %ebp,%eax
  801d0b:	89 f7                	mov    %esi,%edi
  801d0d:	f7 f1                	div    %ecx
  801d0f:	89 fa                	mov    %edi,%edx
  801d11:	83 c4 1c             	add    $0x1c,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5f                   	pop    %edi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 f9                	mov    %edi,%ecx
  801d22:	b8 20 00 00 00       	mov    $0x20,%eax
  801d27:	29 f8                	sub    %edi,%eax
  801d29:	d3 e2                	shl    %cl,%edx
  801d2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d2f:	89 c1                	mov    %eax,%ecx
  801d31:	89 da                	mov    %ebx,%edx
  801d33:	d3 ea                	shr    %cl,%edx
  801d35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d39:	09 d1                	or     %edx,%ecx
  801d3b:	89 f2                	mov    %esi,%edx
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	d3 e3                	shl    %cl,%ebx
  801d45:	89 c1                	mov    %eax,%ecx
  801d47:	d3 ea                	shr    %cl,%edx
  801d49:	89 f9                	mov    %edi,%ecx
  801d4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d4f:	89 eb                	mov    %ebp,%ebx
  801d51:	d3 e6                	shl    %cl,%esi
  801d53:	89 c1                	mov    %eax,%ecx
  801d55:	d3 eb                	shr    %cl,%ebx
  801d57:	09 de                	or     %ebx,%esi
  801d59:	89 f0                	mov    %esi,%eax
  801d5b:	f7 74 24 08          	divl   0x8(%esp)
  801d5f:	89 d6                	mov    %edx,%esi
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	f7 64 24 0c          	mull   0xc(%esp)
  801d67:	39 d6                	cmp    %edx,%esi
  801d69:	72 15                	jb     801d80 <__udivdi3+0x100>
  801d6b:	89 f9                	mov    %edi,%ecx
  801d6d:	d3 e5                	shl    %cl,%ebp
  801d6f:	39 c5                	cmp    %eax,%ebp
  801d71:	73 04                	jae    801d77 <__udivdi3+0xf7>
  801d73:	39 d6                	cmp    %edx,%esi
  801d75:	74 09                	je     801d80 <__udivdi3+0x100>
  801d77:	89 d8                	mov    %ebx,%eax
  801d79:	31 ff                	xor    %edi,%edi
  801d7b:	e9 40 ff ff ff       	jmp    801cc0 <__udivdi3+0x40>
  801d80:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d83:	31 ff                	xor    %edi,%edi
  801d85:	e9 36 ff ff ff       	jmp    801cc0 <__udivdi3+0x40>
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__umoddi3>:
  801d90:	f3 0f 1e fb          	endbr32 
  801d94:	55                   	push   %ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 1c             	sub    $0x1c,%esp
  801d9b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d9f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801da3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801da7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dab:	85 c0                	test   %eax,%eax
  801dad:	75 19                	jne    801dc8 <__umoddi3+0x38>
  801daf:	39 df                	cmp    %ebx,%edi
  801db1:	76 5d                	jbe    801e10 <__umoddi3+0x80>
  801db3:	89 f0                	mov    %esi,%eax
  801db5:	89 da                	mov    %ebx,%edx
  801db7:	f7 f7                	div    %edi
  801db9:	89 d0                	mov    %edx,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	83 c4 1c             	add    $0x1c,%esp
  801dc0:	5b                   	pop    %ebx
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    
  801dc5:	8d 76 00             	lea    0x0(%esi),%esi
  801dc8:	89 f2                	mov    %esi,%edx
  801dca:	39 d8                	cmp    %ebx,%eax
  801dcc:	76 12                	jbe    801de0 <__umoddi3+0x50>
  801dce:	89 f0                	mov    %esi,%eax
  801dd0:	89 da                	mov    %ebx,%edx
  801dd2:	83 c4 1c             	add    $0x1c,%esp
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5f                   	pop    %edi
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    
  801dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801de0:	0f bd e8             	bsr    %eax,%ebp
  801de3:	83 f5 1f             	xor    $0x1f,%ebp
  801de6:	75 50                	jne    801e38 <__umoddi3+0xa8>
  801de8:	39 d8                	cmp    %ebx,%eax
  801dea:	0f 82 e0 00 00 00    	jb     801ed0 <__umoddi3+0x140>
  801df0:	89 d9                	mov    %ebx,%ecx
  801df2:	39 f7                	cmp    %esi,%edi
  801df4:	0f 86 d6 00 00 00    	jbe    801ed0 <__umoddi3+0x140>
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	89 ca                	mov    %ecx,%edx
  801dfe:	83 c4 1c             	add    $0x1c,%esp
  801e01:	5b                   	pop    %ebx
  801e02:	5e                   	pop    %esi
  801e03:	5f                   	pop    %edi
  801e04:	5d                   	pop    %ebp
  801e05:	c3                   	ret    
  801e06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	89 fd                	mov    %edi,%ebp
  801e12:	85 ff                	test   %edi,%edi
  801e14:	75 0b                	jne    801e21 <__umoddi3+0x91>
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f7                	div    %edi
  801e1f:	89 c5                	mov    %eax,%ebp
  801e21:	89 d8                	mov    %ebx,%eax
  801e23:	31 d2                	xor    %edx,%edx
  801e25:	f7 f5                	div    %ebp
  801e27:	89 f0                	mov    %esi,%eax
  801e29:	f7 f5                	div    %ebp
  801e2b:	89 d0                	mov    %edx,%eax
  801e2d:	31 d2                	xor    %edx,%edx
  801e2f:	eb 8c                	jmp    801dbd <__umoddi3+0x2d>
  801e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e38:	89 e9                	mov    %ebp,%ecx
  801e3a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e3f:	29 ea                	sub    %ebp,%edx
  801e41:	d3 e0                	shl    %cl,%eax
  801e43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e47:	89 d1                	mov    %edx,%ecx
  801e49:	89 f8                	mov    %edi,%eax
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e55:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e59:	09 c1                	or     %eax,%ecx
  801e5b:	89 d8                	mov    %ebx,%eax
  801e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e61:	89 e9                	mov    %ebp,%ecx
  801e63:	d3 e7                	shl    %cl,%edi
  801e65:	89 d1                	mov    %edx,%ecx
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e6f:	d3 e3                	shl    %cl,%ebx
  801e71:	89 c7                	mov    %eax,%edi
  801e73:	89 d1                	mov    %edx,%ecx
  801e75:	89 f0                	mov    %esi,%eax
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	89 fa                	mov    %edi,%edx
  801e7d:	d3 e6                	shl    %cl,%esi
  801e7f:	09 d8                	or     %ebx,%eax
  801e81:	f7 74 24 08          	divl   0x8(%esp)
  801e85:	89 d1                	mov    %edx,%ecx
  801e87:	89 f3                	mov    %esi,%ebx
  801e89:	f7 64 24 0c          	mull   0xc(%esp)
  801e8d:	89 c6                	mov    %eax,%esi
  801e8f:	89 d7                	mov    %edx,%edi
  801e91:	39 d1                	cmp    %edx,%ecx
  801e93:	72 06                	jb     801e9b <__umoddi3+0x10b>
  801e95:	75 10                	jne    801ea7 <__umoddi3+0x117>
  801e97:	39 c3                	cmp    %eax,%ebx
  801e99:	73 0c                	jae    801ea7 <__umoddi3+0x117>
  801e9b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e9f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801ea3:	89 d7                	mov    %edx,%edi
  801ea5:	89 c6                	mov    %eax,%esi
  801ea7:	89 ca                	mov    %ecx,%edx
  801ea9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801eae:	29 f3                	sub    %esi,%ebx
  801eb0:	19 fa                	sbb    %edi,%edx
  801eb2:	89 d0                	mov    %edx,%eax
  801eb4:	d3 e0                	shl    %cl,%eax
  801eb6:	89 e9                	mov    %ebp,%ecx
  801eb8:	d3 eb                	shr    %cl,%ebx
  801eba:	d3 ea                	shr    %cl,%edx
  801ebc:	09 d8                	or     %ebx,%eax
  801ebe:	83 c4 1c             	add    $0x1c,%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    
  801ec6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	29 fe                	sub    %edi,%esi
  801ed2:	19 c3                	sbb    %eax,%ebx
  801ed4:	89 f2                	mov    %esi,%edx
  801ed6:	89 d9                	mov    %ebx,%ecx
  801ed8:	e9 1d ff ff ff       	jmp    801dfa <__umoddi3+0x6a>
