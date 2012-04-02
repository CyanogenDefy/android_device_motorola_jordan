/*
 * clockfix - fixup module for Motorola Defy/Defy+
 *
 * hooking taken from "n - for testing kernel function hooking" by Nothize
 * require symsearch module by Skrilaz
 *
 * Copyright (C) 2012 CyanogenDefy
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
#include <linux/moduleparam.h>

#include <linux/clk.h>
#include <linux/proc_fs.h>

#include <plat/clock.h>
#include <plat/clockdomain.h>
#include <plat/cpu.h>

#include "hook.h"

#define MODULE_TAG "clockfix"

static int hook_count = 0;
static int debug = 0;
module_param(debug, int, 0);

static bool hooked = false;

static struct dpll_data *p1_data = NULL;
static struct dpll_data *p2_data = NULL;

static void dump_pll_data(struct dpll_data *pll, const char * name)
{
	if (pll == NULL) return;
	pr_info("struct %s->dpll_data :\n", name);
	pr_info(" void __iomem  *mult_div1_reg=0x%p\n", pll->mult_div1_reg);
	pr_info(" u32            mult_mask=0x%x\n", pll->mult_mask);
	pr_info(" u32            div1_mask=0x%x\n", pll->div1_mask);
	pr_info(" struct clk    *clk_bypass=%s\n", pll->clk_bypass ? pll->clk_bypass->name : "null");
	pr_info(" struct clk    *clk_ref=%s\n", pll->clk_ref->name);
	pr_info(" void __iomem  *control_reg=0x%p\n", pll->control_reg);
	pr_info(" u32            enable_mask=0x%x\n", pll->enable_mask);
	pr_info(" unsigned int   rate_tolerance=%u\n", pll->rate_tolerance);
	pr_info(" unsigned long  last_rounded_rate=%lu\n", pll->last_rounded_rate);
	pr_info(" unsigned long  default_rate=%lu\n", pll->default_rate);
	pr_info(" u16            last_rounded_m=%u\n", pll->last_rounded_m);
	pr_info(" u8             last_rounded_n=%u\n", pll->last_rounded_n);
	pr_info(" u8             min_divider=%u\n", pll->min_divider);
	pr_info(" u8             max_divider=%u\n", pll->max_divider);
	pr_info(" u32            max_tolerance=%u\n", pll->max_tolerance);
	pr_info(" u16            max_multiplier=%u\n", pll->max_multiplier);
	pr_info(" u8             modes=%u\n", pll->modes);
	pr_info(" void __iomem  *autoidle_reg=0x%p\n", pll->autoidle_reg);
	pr_info(" void __iomem  *idlest_reg=0x%p\n", pll->idlest_reg);
	pr_info(" u32            autoidle_mask=0x%x\n", pll->autoidle_mask);
	pr_info(" u32            freqsel_mask=0x%x\n", pll->freqsel_mask);
	pr_info(" u32            idlest_mask=0x%x\n", pll->idlest_mask);
	pr_info(" u8             auto_recal_bit=%u\n", pll->auto_recal_bit);
	pr_info(" u8             recal_en_bit=%u\n", pll->recal_en_bit);
	pr_info(" u8             recal_st_bit=%u\n", pll->recal_st_bit);
	pr_info(" u32            dco_sel_mask=0x%x\n", pll->dco_sel_mask);
	pr_info(" u32            sd_div_mask=0x%x\n", pll->sd_div_mask);
	pr_info(" u8             jtype=%u\n\n", pll->jtype);
}

/* Hooked Function */
static long omap2_dpll_round_rate(struct clk *clk, unsigned long target_rate) {
	struct dpll_data *dd;
	long ret;
	unsigned long fint;
	struct clk *ref;

	ret = HOOK_INVOKE(omap2_dpll_round_rate, clk, target_rate);

	hook_count ++;
	if (clk == NULL)
		return ret;

	dd = clk->dpll_data;
	if (strcmp(clk->name, "dpll1_ck") == 0) {
		if (debug) {
			printk(KERN_INFO MODULE_TAG": set %s rate to %lu KHz, last_rounded : m=%d, n=%d, rate=%lu KHz\n",
				clk->name, target_rate/1000, dd->last_rounded_m, dd->last_rounded_n, dd->last_rounded_rate/1000);
		}
		if (dd->last_rounded_n == 1 && dd->last_rounded_m < 1024) {
			dd->last_rounded_n = 2;
			dd->last_rounded_m = dd->last_rounded_m * 2;
			if (debug) {
				printk(KERN_INFO MODULE_TAG": clock divider fixed.");
			}
		}
		if (dd->last_rounded_n != 0) {
			ref = dd->clk_ref;
			fint = ref->rate / dd->last_rounded_n;
			if (debug) {
				printk(KERN_INFO MODULE_TAG": ref clk %s->rate %lu KHz / n = %lu KHz (fint) \n",
				       ref->name, ref->rate/1000, fint/1000);
			}
		}
		// dump once in dmesg
		if (debug && p1_data == NULL) {
			dump_pll_data(dd, clk->name);
		}
		// keep ref on DPLL1
		p1_data = dd;
	}
	else if (debug && strcmp(clk->name, "dpll2_ck") == 0) {
		if (p2_data == NULL) {
			dump_pll_data(dd, clk->name);
		}
		// keep ref on DPLL2
		p2_data = dd;
	}

	return ret;
}

static int proc_hook_count_read(char *buffer, char **buffer_location,
								off_t offset, int count, int *eof, void *data) {
	int ret = 0;
	if (offset == 0)
		ret = scnprintf(buffer, count, "%u\n", hook_count);
	return ret;
}

static int proc_freq_read(char *buffer, char **buffer_location,
								off_t offset, int count, int *eof, void *data) {
	int ret = 0;
	unsigned long current_freq = 0;
	if (p1_data != NULL) {
		current_freq = p1_data->last_rounded_rate;
	}
	if (offset == 0)
		ret = scnprintf(buffer, count, "%lu\n", current_freq);
	return ret;
}

struct hook_info g_hi[] = {
	HOOK_INIT(omap2_dpll_round_rate),
	HOOK_INIT_END
};

static int __init clockfix_init(void) {
	struct proc_dir_entry *proc_entry;

	proc_mkdir(MODULE_TAG, NULL);
	proc_entry = create_proc_read_entry(MODULE_TAG"/hook_count", 0444, NULL, proc_hook_count_read, NULL);
	proc_entry = create_proc_read_entry(MODULE_TAG"/freq", 0444, NULL, proc_freq_read, NULL);

	hook_init();
	hooked = true;

	return 0;
}

static void __exit clockfix_exit(void) {
	if (hooked) hook_exit();
	remove_proc_entry(MODULE_TAG"/hook_count", NULL);
	remove_proc_entry(MODULE_TAG"/freq", NULL);
	remove_proc_entry(MODULE_TAG, NULL);
}

module_init(clockfix_init);
module_exit(clockfix_exit);

MODULE_ALIAS(MODULE_TAG);
MODULE_VERSION("1.0");
MODULE_DESCRIPTION("Fix omap clocks multiple of 26000 like 1.3Ghz, buggy when divider N=1");
MODULE_AUTHOR("Tanguy Pruvot, CyanogenDefy");
MODULE_LICENSE("GPL");
