/*
 * logcap - cpcap io sniffer module for Motorola Defy
 *
 * hooking taken from "n - for testing kernel function hooking" by Nothize
 * require symsearch module by Skrilaz
 *
 * Copyright (C) 2011 CyanogenDefy
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
#include <linux/device.h>
#include <linux/proc_fs.h>
#include <linux/vmalloc.h>

#include <linux/spi/cpcap.h>

#include "hook.h"
#include "regs-cpcap.h"
#include "../symsearch/symsearch.h"

#define TAG "logcap"
struct proc_dir_entry *proc_root;

#define MAX_REGS 0x100
#define REG_FMT "%02x"

// storage for register last states
typedef struct {
	enum cpcap_reg reg;
	struct proc_dir_entry* proc_dir;
	struct proc_dir_entry* proc_mask;
	unsigned short mask_wr;
	struct proc_dir_entry* proc_value;
	unsigned short last_value;
} st_logcap_reg;

typedef struct {
	st_logcap_reg r[MAX_REGS];
	//struct cpcap_device *last_cpcap;
} ar_logcap_regs;

static ar_logcap_regs *store;

// Log vars

#define L_DMESG  1
#define L_PROC   2

static int log_enable = L_DMESG | L_PROC;
static int log_reg_min = 0;
static int log_reg_max = MAX_REGS;

module_param(log_enable , int, 0); //1: dmesg, 2: /proc
MODULE_PARM_DESC(log_enable,  "Log type 1:dmesg 2:proc 3:both");
module_param(log_reg_min, int, 0); //first reg in logs
MODULE_PARM_DESC(log_reg_min, "First register to log (default 0)");
module_param(log_reg_max, int, 0); //last  reg in logs
MODULE_PARM_DESC(log_reg_max, "Last register to log (default max)");

// Stats
static int rd_count = 0;
static int wr_count = 0;

static char buf[32];
static bool hooked = false;

#define DBG(format, ...) if (log_enable & L_DMESG) printk(KERN_DEBUG TAG ": " format, ## __VA_ARGS__)

SYMSEARCH_DECLARE_FUNCTION_STATIC(
	int, _cpcap_direct_misc_write, unsigned short reg, unsigned short value, unsigned short mask);


/*
 * sub /proc/<reg>/prop r/w
 */
static int proc_reg_mask_read(char *buffer, char **start, off_t offset, int count, int *eof, void *data) {
	int ret = 0;
	st_logcap_reg* reg = data;
	if (!offset && data) {
		ret = scnprintf(buffer, count, "0x%x\n", reg->mask_wr);
	}
	return ret;
}

static int proc_reg_val_read(char *buffer, char **start, off_t offset, int count, int *eof, void *data) {
	int ret = 0;
	st_logcap_reg* reg = data;
	if (!offset && data) {
		ret = scnprintf(buffer, count, "0x%x\n", reg->last_value);
	}
	return ret;
}

static int proc_reg_val_write(struct file *filp, const char __user *buffer, unsigned long len, void *data) {

	uint32_t newval=0;
	int ret;
	unsigned short val=0;
	st_logcap_reg* reg = data;

	if (!len || len >= sizeof(buf))
		return -ENOSPC;
	if (copy_from_user(buf, buffer, len))
		return -EFAULT;
	buf[len] = 0;

	if (sscanf(buf, "0x%x", (uint32_t *) &newval) > 0) {

		printk(KERN_INFO TAG": mask=0x%x newval=0x%x res=0x%x\n", reg->mask_wr, newval, reg->mask_wr & newval);
		newval &= reg->mask_wr;
		val = (unsigned short) newval;
		if (reg->reg && hooked) {
			SYMSEARCH_BIND_FUNCTION_TO(logcap, cpcap_direct_misc_write, _cpcap_direct_misc_write);
			ret = _cpcap_direct_misc_write(reg->reg, val, reg->mask_wr);
			if (ret < 0) {
				printk(KERN_ERR TAG": cpcap_direct_misc_write error %d !\n", ret);
			}
		}

		printk(KERN_INFO TAG": checked val=0x%x\n", val);

	} else
		printk(KERN_ERR TAG": wrong parameter, missing hexa prefix (0x....) !\n");

	return len;
}

void map_rep(st_logcap_reg *rst, enum cpcap_reg reg) {

	scnprintf(buf, sizeof(buf), REG_FMT, reg);
	rst->proc_dir = proc_mkdir(buf, proc_root);

	rst->proc_mask = create_proc_read_entry("mask", 0444, rst->proc_dir, &proc_reg_mask_read, rst);
	rst->proc_value = create_proc_read_entry("val", 0644, rst->proc_dir, &proc_reg_val_read, rst);
	rst->proc_value->write_proc = proc_reg_val_write;

	rst->reg = reg;
}

/*
 * The 2 hooked functions (io reg read/write)
 */
int cpcap_regacc_read(struct cpcap_device *cpcap, enum cpcap_reg reg, unsigned short *value_ptr) {
	int ret = 0;
	unsigned short val=0;
	st_logcap_reg *rst;

	ret = HOOK_INVOKE(cpcap_regacc_read, cpcap, reg, value_ptr);
	rd_count ++;

	if (reg > MAX_REGS) return ret;

	memcpy(&val, value_ptr, sizeof(val));
	if (log_enable && reg < log_reg_max && reg > log_reg_min) {

		DBG("read  %10s(0x"REG_FMT") 0x%04x\n", capcap_regname(reg), (unsigned int) reg, val);

		if (log_enable & L_PROC) {

			rst = &store->r[reg];
			if (!rst->reg) {
				map_rep(rst, reg);
				//store->last_cpcap = cpcap;
			}
		}
	}
	store->r[reg].last_value = val;

	return ret;
}

int cpcap_regacc_write(struct cpcap_device *cpcap, enum cpcap_reg reg, unsigned short value, unsigned short mask) {
	int ret = 0;
	st_logcap_reg *rst;
/*
	if (reg == 0x9e && value == 0x7f) {
		value = 0x3f;
		printk(KERN_INFO TAG": rewrited to 0x" REG_FMT "(%d.) set/mask %4x/%4x\n", (unsigned int) reg, reg, value, mask);
	}
*/
	ret = HOOK_INVOKE(cpcap_regacc_write, cpcap, reg, value, mask);
	wr_count ++;

	if (reg > MAX_REGS) return ret;

	if (log_enable && reg < log_reg_max && reg > log_reg_min) {

		DBG("write %10s(0x"REG_FMT") set/mask %4x/%04x\n", capcap_regname(reg), (unsigned int) reg, value, mask);

		if (log_enable & L_PROC) {

			rst = &store->r[reg];
			if (!rst->reg) {
				map_rep(rst, reg);
			}
		}
	}
	rst = &store->r[reg];
	rst->mask_wr |= mask;

	return ret;
}

/*
 * /proc read/write functions
 */
static int proc_rd_count_read(char *buffer, char **start, off_t offset, int count, int *eof, void *data) {
	int ret = 0;
	if (!offset) ret = scnprintf(buffer, count, "%u\n", rd_count);
	return ret;
}

static int proc_wr_count_read(char *buffer, char **start, off_t offset, int count, int *eof, void *data) {
	int ret = 0;
	if (!offset) ret = scnprintf(buffer, count, "%u\n", wr_count);
	return ret;
}

static int proc_log_enable_read(char *buffer, char **start, off_t offset, int count, int *eof, void *data) {
	int ret=0;
	if (!offset) ret = scnprintf(buffer, count, "%u\n", log_enable);
	return ret;
}

//set log type (1: simple dmesg, 2: /proc entries)
static int proc_log_enable_write(struct file *filp, const char __user *buffer, unsigned long len, void *data) {

	int enable=0;
	if (!len || len >= sizeof(buf))
		return -ENOSPC;
	if (copy_from_user(buf, buffer, len))
		return -EFAULT;
	buf[len] = 0;
	if (sscanf(buf, "%u", (uint32_t *) &enable) == 1) {

		printk(KERN_INFO TAG": log type=%d\n", enable);
		log_enable = enable;

	} else
		printk(KERN_ERR TAG": wrong parameter !\n");
	return len;
}

// dump all regs cache : cat /proc/logcap/map
static int proc_map_read(char *page, char **start, off_t offset, int count, int *eof, void *data) {
	int r, wr=0;
	unsigned int state=0;

	for (r=0; r<MAX_REGS; r++) if (store->r[r].reg) {

		state = (0xff & (unsigned int) store->r[r].last_value);
		wr += scnprintf(page + wr, count - wr, REG_FMT ":%s:%04x:%x\n", (unsigned int) r, capcap_regname(r), store->r[r].mask_wr, state);
	}

	if (wr <= offset + count) *eof=1;

	*start = page + offset;
	wr -= offset;
	if (wr > count) wr = count;
	if (wr < 0) wr = 0;

	return wr;
}

/*
 * Module init & exit
 */
struct hook_info g_hi[] = {
	HOOK_INIT(cpcap_regacc_read),
	HOOK_INIT(cpcap_regacc_write),
	HOOK_INIT_END
};

static int __init logcap_init(void) {
	struct proc_dir_entry *proc_entry;

	printk(KERN_DEBUG TAG": allocate storage for %d registers, %d bytes\n", MAX_REGS, sizeof(ar_logcap_regs));
	store = vmalloc(sizeof(ar_logcap_regs));
	memset(store, 0, sizeof(ar_logcap_regs));

	proc_root = proc_mkdir(TAG, NULL);
	create_proc_read_entry("rd_count", 0444, proc_root, proc_rd_count_read, NULL);
	create_proc_read_entry("wr_count", 0444, proc_root, proc_wr_count_read, NULL);

	create_proc_read_entry("map", 0444, proc_root, proc_map_read, NULL);

	proc_entry = create_proc_read_entry("log_enable", 0666, proc_root, proc_log_enable_read, NULL);
	proc_entry->write_proc = proc_log_enable_write;

	if (log_enable & L_DMESG) capcap_dumpnames();

	hook_init();
	hooked = true;

	return 0;
}

static void __exit logcap_exit(void) {
	int r;
	st_logcap_reg *rst;

	if (hooked) {
		hook_exit();
		hooked = false;
	}

	remove_proc_entry("rd_count", proc_root);
	remove_proc_entry("wr_count", proc_root);
	remove_proc_entry("log_enable", proc_root);

	remove_proc_entry("map", proc_root);

	//proc cleanup
	for (r=0; r<MAX_REGS; r++) if (store->r[r].reg) {

		rst = &store->r[r];

		if (rst->proc_mask != NULL) {
			remove_proc_entry("mask", rst->proc_dir);
			rst->proc_mask = NULL;
		}
		if (rst->proc_value != NULL) {
			remove_proc_entry("val", rst->proc_dir);
			rst->proc_value = NULL;
		}

		scnprintf(buf, sizeof(buf), REG_FMT, r);
		remove_proc_entry(buf, proc_root);
		rst->reg = 0;
	}
	vfree(store);
	remove_proc_entry(TAG, NULL);
}

module_init(logcap_init);
module_exit(logcap_exit);

MODULE_ALIAS(TAG);
MODULE_VERSION("1.2");
MODULE_DESCRIPTION("Log the cpcap registers read/write");
MODULE_AUTHOR("Tanguy Pruvot, CyanogenDefy");
MODULE_LICENSE("GPL");
