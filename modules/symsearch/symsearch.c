/*
 * symsearch: - looks up also for unexproted symbols in the kernel
 *
 * exports function:
 * unsigned long lookup_symbol_address(const char *name);
 *
 * Created by Skrilax_CZ
 * GPL
 *
 * Copyright (C) 2010 Skrilax_CZ
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/string.h>
#include "symsearch.h"

extern int
kallsyms_on_each_symbol(int (*fn)(void *, const char *, struct module *,
				      unsigned long),
			    void *data);

SYMSEARCH_INIT_FUNCTION(lookup_symbol_address);
EXPORT_SYMBOL(lookup_symbol_address);

static int
find_kallsyms_lookup_name(void* data, const char* name,
                          struct module * module, unsigned long address)
{
	//kallsyms_lookup_name is our friend
	if (!strcmp(name, "kallsyms_lookup_name"))
	{
		printk(KERN_INFO "symsearch: found kallsyms_lookup_name on 0x%lx.\n", address);
		lookup_symbol_address = (lookup_symbol_address_fp)address;
		return 1;
	}

	return 0;
}

static int __init
symsearch_init(void)
{
	//kallsyms export the kallsyms_on_each_symbol so use that
	kallsyms_on_each_symbol(&find_kallsyms_lookup_name, NULL);
	if(!lookup_symbol_address)
	{
		printk(KERN_INFO "symsearch: could not find kallsyms_lookup_name.\n");
		return -EBUSY;
	}
	return 0;
}

module_init(symsearch_init);
MODULE_ALIAS("symsearch");
MODULE_VERSION("1.1");
MODULE_AUTHOR("Skrilax_CZ, verified by CyanogenDefy");
MODULE_DESCRIPTION("symsearch - lookup kernel symbols helper to fix signed kernel features");
MODULE_LICENSE("GPL");

