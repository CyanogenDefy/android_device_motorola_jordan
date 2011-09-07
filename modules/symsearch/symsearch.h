/*
 * symsearch: - looks up for unexported kernel symbols
 *
 * Copyright (C) 2010 Skrilax_CZ
 * GPL
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

#ifndef _SYMSEARCH_H_
#define _SYMSEARCH_H_

//macros to call functions declared in C but addressed manually

//ret -> return type
//name -> function name
//... parameter list
//expname -> name under which the function is exported

//addresses

#define SYMSEARCH_DECLARE_ADDRESS(name) \
	extern unsigned long name##_address

#define SYMSEARCH_DECLARE_ADDRESS_STATIC(name) \
	static unsigned long name##_address = 0

#define SYMSEARCH_INIT_ADDRESS(name) \
	unsigned long name##_address = 0

#define SYMSEARCH_GET_ADDRESS(name) \
	name##_address

//functions

#define SYMSEARCH_DECLARE_FUNCTION(ret,name,...) \
	typedef	ret (*name##_fp) ( __VA_ARGS__ ); \
	extern name##_fp name

#define SYMSEARCH_DECLARE_FUNCTION_STATIC(ret,name,...) \
	typedef	ret (*name##_fp) ( __VA_ARGS__ ); \
	static name##_fp name = 0

#define SYMSEARCH_INIT_FUNCTION(name) \
	name##_fp name = (name##_fp)0

//binding (call this in module_init and module is the module name)

#define SYMSEARCH_BIND_ADDRESS(module,name) \
	name##_address = lookup_symbol_address(#name); \
	if(!name##_address) \
	{ \
		printk(KERN_INFO #module ": Could not find symbol: " #name ".\n"); \
		return -EBUSY; \
	}

#define SYMSEARCH_BIND_ADDRESS_TO(module,name,sym) \
	sym##_address = lookup_symbol_address(#name); \
	if(!sym##_address) \
	{ \
		printk(KERN_INFO #module ": Could not find symbol: " #name ".\n"); \
		return -EBUSY; \
	}

#define SYMSEARCH_BIND_FUNCTION(module,name) \
	name = (name##_fp)lookup_symbol_address(#name); \
	if(!name) \
	{ \
		printk(KERN_INFO #module ": Could not find symbol: " #name ".\n"); \
		return -EBUSY; \
	}

#define SYMSEARCH_BIND_FUNCTION_TO(module,name,sym) \
	sym = (sym##_fp)lookup_symbol_address(#name); \
	if(!sym) \
	{ \
		printk(KERN_INFO #module ": Could not find symbol: " #name ".\n"); \
		return -EBUSY; \
	}

#define SYMSEARCH_BIND_FUNCTION_TO_NORET(module,name,sym) \
	sym = (sym##_fp)lookup_symbol_address(#name); \
	if(!sym) \
	{ \
		printk(KERN_INFO #module ": Could not find symbol: " #name ".\n"); \
		return; \
	}

//hijacking function
//injects a Branch instruction to the function beginning

//ARM MODE only !!!

struct hijack_info
{
	unsigned long hijack_address;
	unsigned long redirection_address;
	unsigned long instruction_backup;
};

SYMSEARCH_DECLARE_FUNCTION(unsigned long, lookup_symbol_address, const char *name);

struct hijack_info hijack_function(unsigned long hijack_address, unsigned long redirection_address);
void restore_function(struct hijack_info hijack);

#endif
