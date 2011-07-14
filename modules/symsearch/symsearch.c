/* symsearch: - looks up also for unexproted symbols in the kernel
 * exports function:
 * 
 * unsigned long lookup_symbol_address(const char *name); 
 *
 * Created by Skrilax_CZ
 * GPL
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/string.h>

extern int 
kallsyms_on_each_symbol(int (*fn)(void *, const char *, struct module *,
				      unsigned long),
			    void *data);

/* Calling a C function if I know the address
 * a) declare it exactly as it was, add the naked attribute
 * b) body:
 *
 * asm volatile("ldr r12,=function_address\n\t"
 *              "ldr pc,[r12,#0]");
 *
 * c) function_address is a variable storing the address
 * 
 * Below is an example.
 */

static unsigned long kallsyms_lookup_name_address = 0;

//unsigned long kallsyms_lookup_name(const char *name) 
unsigned long __attribute__((naked)) 
lookup_symbol_address(const char *name)
{
	//just change the pc value to the address, so it returns to previous caller
	//note that first instruction will actually put a pointer to r12
	asm volatile("ldr r12,=kallsyms_lookup_name_address\n\t"
	             "ldr pc,[r12,#0]");
	//lr value remains original, so it returns to the caller
}

EXPORT_SYMBOL(lookup_symbol_address);

static int 
find_kallsyms_lookup_name(void* data, const char* name, 
                          struct module * module, unsigned long address)
{
	//kallsyms_lookup_name is our friend
	if (!strcmp(name, "kallsyms_lookup_name"))
	{
		printk(KERN_INFO "symsearch: found kallsyms_lookup_name on 0x%lx.\n", address);
		kallsyms_lookup_name_address = address;
		return 1;
	}
	
	return 0;
} 
	
static int __init 
symsearch_init(void)
{
	//kallsyms export the kallsyms_on_each_symbol so use that
	kallsyms_on_each_symbol(&find_kallsyms_lookup_name, NULL);
	return kallsyms_lookup_name_address == 0;
}

module_init(symsearch_init);
MODULE_LICENSE("GPL");