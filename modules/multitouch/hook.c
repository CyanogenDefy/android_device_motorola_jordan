/*
 * hook - Hook utilities.
 * use of Skrilax's symsearch added by Nadlabak
 *
 * Copyright (C) 2010 Nothize
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

#include "hook.h"
#include "../symsearch/symsearch.h"
#include <linux/module.h>
#include <linux/kallsyms.h>
#include <linux/smp_lock.h>

//#define DEBUG_HOOK
#ifdef DEBUG_HOOK
#define P(format, ...) printk(KERN_INFO "hook: " format, ## __VA_ARGS__)
#else
#define P(format, ...)
#endif

#define INFO(format, ...) (printk(KERN_INFO "hook:%s:%d " format, __FUNCTION__, __LINE__, ## __VA_ARGS__))

SYMSEARCH_DECLARE_FUNCTION_STATIC(unsigned long, pkallsyms_lookup_name, const char *);
SYMSEARCH_DECLARE_FUNCTION_STATIC(const char *, pkallsyms_lookup, unsigned long, unsigned long *, unsigned long *, char **, char *);

/* Only ARM is supported and the target will crash if there involves
   PC related addressing in the first instruction. Because that
   instruction will be moved to hook_info for execution.
*/
int hook(struct hook_info *hi) {
	char targetName[KSYM_NAME_LEN];
	char *ptargetName;
	if ( !hi->target ) {
		if ( hi->targetName ) {
			hi->target = (unsigned int*)pkallsyms_lookup_name(hi->targetName);
		}
		if ( !hi->target ) {
			P("Target address is not defined and targetName(%s) cannot be found.\n", hi->targetName ?
					hi->targetName : "");
			return -1;
		}
		ptargetName = hi->targetName;
	} else {
		pkallsyms_lookup((unsigned int)hi->target, NULL, NULL, NULL, targetName);
		ptargetName = targetName;
	}

	// Save the first 2 instructions from target.
	P("target = %p(%s), newf = %x\n", hi->target, ptargetName, hi->newfunc);
	P("*target = %x\n", hi->target[0]);
	hi->asm0 = hi->target[0];

	// Use 1 instruction static replacement.
	hi->target[0] = 0xea000000 + (0xffffff & (hi->newfunc - ((unsigned int)hi->target + 8)) / 4);
	P("*target = %x\n", hi->target[0]);

	// Setup jmp table to first non-overwritten offset.
	hi->jmp = 0xe51ff004;
	hi->target_cont = hi->target+1;
	P("&invoke = %p, target_cont = %p\n", &hi->asm0, hi->target_cont);

	INFO("hooked %s\n", ptargetName);
	return 0;
}

int unhook(struct hook_info *hi) {
	if ( hi->target ) {
		// Restore the first 2 instructions to target.
		hi->target[0] = hi->asm0;
		INFO("unhooked %p\n", hi->target);
	}
	return 0;
}

int hook_init(void) {
	int i;
	SYMSEARCH_BIND_FUNCTION_TO(multitouch, kallsyms_lookup_name, pkallsyms_lookup_name);
	SYMSEARCH_BIND_FUNCTION_TO(multitouch, kallsyms_lookup, pkallsyms_lookup);
	lock_kernel();
	for (i = 0; g_hi[i].newfunc; ++i) {
		hook(&g_hi[i]);
	}
	unlock_kernel();
	return 0;
}

void hook_exit(void) {
	int i;
	lock_kernel();
	for (i = 0; g_hi[i].newfunc; ++i) {
		unhook(&g_hi[i]);
	}
	unlock_kernel();
}
