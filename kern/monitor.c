// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>
#include <kern/trap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

// LAB 1: add your command to here...
static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display function backtrace information", mon_backtrace },
	{ "showmappings", "Display physical page mappings and their permissions in the current address space", mon_showmappings },
	{ "si", "step through a single instruction", mon_si },
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// LAB 1: Your code here.
	//Pushing a value into the stack involves decreasing the stack pointer and then writing the value to the place the stack pointer points to
	//Poping a value from the stack involves reading the value the stack pointer points to and then increasing the stack pointer.

    // HINT 1: use read_ebp().
	//variable declarations
		//step 12 aditions
	int index;
	int length;
	int offset;
	char fileName = {0};
	struct Eipdebuginfo info;
		//step 11
	uint32_t ebp = read_ebp();
	uint32_t *p = (uint32_t *)ebp;

	//Print Header 
	cprintf("Stack backtrace:\n");

	//iterate through args 
	while(p)
	{
		//print ebp and eip 
		// HINT 2: print the current ebp on the first line (not current_ebp[0])
		cprintf("  ebp %08x  eip %08x  args", p, *(p+1));

		//iterate throught the args 
		for(index = 0; index < 5; index++)
		{
			//print the args 
			cprintf(" %08x", *(p+2+index));
		}
		//move to new line 
		cprintf("\n");

			//step 12 aditions
		debuginfo_eip(*(p+1), &info);

		cprintf("         %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(p+1) - info.eip_fn_addr );

		//update p
		p = (uint32_t *) *p;
	}
	//return 0 when completed
	return 0;
}

int mon_showmappings(int argc, char **argv, struct Trapframe *tf) {
	uintptr_t lo = 0, hi = 0, curr;
	bool pte_p, pte_w, pte_u, pte_avail;
	if (argc == 2) {
		lo = strtol(argv[1], NULL, 16);
		hi = lo + PGSIZE;
	} else if (argc == 3) {
		lo = strtol(argv[1], NULL, 16);
		hi = strtol(argv[2], NULL, 16);
	} else {
		cprintf("showmappings: please provide an address range [0xlow, 0xhigh) in the form:\n	showmappings 0x<low> 0x<high>\nor a single address:\n	showmappings 0x<low>\n");
	}

	//adjust hi, lo to fit page boundaries
	lo = ROUNDUP(lo - PGSIZE + 1, PGSIZE);
	hi = ROUNDUP(hi - PGSIZE + 1, PGSIZE);

	cprintf("Physical mappings for virtual address range 0x%lx-0x%lx\n", lo, hi);

	assert(kern_pgdir);
	for (size_t i = lo; i < hi; i += PGSIZE) {
		curr = (uintptr_t) pgdir_walk(kern_pgdir, (void *) i, 0);
		if (curr) {
			pte_p = BOOL(curr & PTE_P);
			pte_w = BOOL(curr & PTE_W);
			pte_u = BOOL(curr & PTE_U);
		} else {
			pte_p = false;
			pte_w = false;
			pte_u = false;
		}

		cprintf("0x%08.8lx -> 0x%08.8lx, PTE_P: %1.d, PTE_W: %1.d, PTE_U: %1.d\n", i & ~0xfff, (*(pte_t *) curr) & ~0xfff, pte_p, pte_w, pte_u);
	}


	return 0;
}

int mon_si(int argc, char **argv, struct Trapframe *tf) {
	uint32_t eflags = read_eflags();
	eflags |= FL_TF;
	write_eflags(eflags);
	return 0;
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
