/*
 * ledsfix - cpcap io sniffer module for Motorola Defy
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
#include <linux/delay.h>
#include <linux/device.h>
#include <linux/earlysuspend.h>
#include <linux/proc_fs.h>
#include <linux/vmalloc.h>
#include <asm/uaccess.h>

#include <linux/spi/cpcap.h>
#include <linux/leds-ld-cpcap.h>

#include "hook.h"
#include "../symsearch/symsearch.h"

#define TAG "ledsfix"

#define BUF_SIZE 32
static char *buf=NULL;

#define REG_FMT "%02x"

// storage for register last states
typedef struct {
	enum cpcap_reg reg;
	unsigned short mask_wr;
	unsigned short last_value;
	//struct cpcap_device *cpcap;
} st_cpcap_reg;

static st_cpcap_reg *btreg;
struct proc_dir_entry *proc_root;

#define CPCAP_BUTTON_BACKLIGHT CPCAP_REG_ADLC
#define CPCAP_BUTTON_WR_MASK   LD_BUTTON_CPCAP_MASK

static int log_enable = 0;
module_param(log_enable , int, 0);
MODULE_PARM_DESC(log_enable,  "Enable dmesg logs (0/1)");

static int brightness = 48;
module_param(brightness, int, 0);
MODULE_PARM_DESC(brightness,  "Brightness level (0-255)");

static int animate = 1;
module_param(animate , int, 0);
MODULE_PARM_DESC(brightness,  "Animation on module load (default 1)");

// Stats
static int wr_count = 0;

static bool hooked = false;

SYMSEARCH_DECLARE_FUNCTION_STATIC(
	int, _cpcap_direct_misc_write, unsigned short reg, unsigned short value, unsigned short mask);

/*
 * Conversion 0-255 to CPCAP REG
 */
unsigned short bright_to_cpcap(int level) {

	unsigned short val=0;
	unsigned int newval;

	//allowed: 0 1f 2f 3f 4f 5f 6f 7f  .. 3ff (64 levels)
	level = level & 0xFF;
	newval = (level * 4) | 0xF;

	if (level == 0) newval=0;
	else if (newval < 1) newval=0xF;

	val = (unsigned short) newval & btreg->mask_wr;

	if (log_enable & 1)
		printk(KERN_DEBUG TAG": brightness: %d -> 0x%x\n", level, val);

	return val;
}

/*
 * Animation
 */
int test_anim(int level) {
	int n;
	unsigned short val;

	SYMSEARCH_BIND_FUNCTION_TO(ledsfix, cpcap_direct_misc_write, _cpcap_direct_misc_write);
	for (n=1; n <=31; n++) {
		val = bright_to_cpcap(n*8 - 1);
		_cpcap_direct_misc_write(btreg->reg, val, btreg->mask_wr);
		msleep_interruptible(3);
	}
	for (n=30; n >= 1; n--) {
		val = bright_to_cpcap(n*8 - 1);
		_cpcap_direct_misc_write(btreg->reg, val, btreg->mask_wr);
		if ((n*8) < level) break;
		msleep_interruptible(1);
	}
	return 0;
}

/*
 * hooked function (io reg write)
 */
int cpcap_regacc_write(struct cpcap_device *cpcap, enum cpcap_reg reg, unsigned short value, unsigned short mask) {
	int ret = 0;

	if (reg == CPCAP_BUTTON_BACKLIGHT && value > 1) {
		if (log_enable & 1)
			printk(KERN_DEBUG TAG": got value 0x%x(%d) mask %x\n", value, value, mask);
		value = bright_to_cpcap(brightness);
		if (log_enable & 1)
			printk(KERN_DEBUG TAG": override brightness set 0x%x(%d) mask %x\n", value, value, mask);
	}
	ret = HOOK_INVOKE(cpcap_regacc_write, cpcap, reg, value, mask);

	if (reg != CPCAP_BUTTON_BACKLIGHT) return ret;
	wr_count ++;

	btreg->mask_wr |= mask;
	btreg->last_value = value;

	if (log_enable & 1)
		printk(KERN_DEBUG TAG": write REG 0x"REG_FMT"(%d.) set/mask %x/%x\n", (unsigned int) reg, reg, value, mask);

	return ret;
}

/*
 * /proc read/write functions 
 */
static int proc_brightness_read(char *buffer, char **start, off_t offset, int count, int *eof, void *data) {
	int ret = 0;
	if (!offset) ret = scnprintf(buffer, count, "%u\n", brightness);
	return ret;
}

static int proc_brightness_write(struct file *filp, const char __user *buffer, unsigned long len, void *data) {

	uint32_t newval=0;
	int ret;
	unsigned short val=0;

	if (!len || len >= BUF_SIZE)
		return -ENOSPC;
	if (copy_from_user(buf, buffer, len))
		return -EFAULT;
	buf[len] = 0;

	if (sscanf(buf, "%d", (uint32_t *) &newval) > 0) {

		brightness = newval & 0xff;
		val = bright_to_cpcap(newval);

		printk(KERN_INFO TAG": brightness=%x\n", val);
		SYMSEARCH_BIND_FUNCTION_TO(ledsfix, cpcap_direct_misc_write, _cpcap_direct_misc_write);
		ret = _cpcap_direct_misc_write(btreg->reg, val, btreg->mask_wr);
		if (ret < 0) {
			printk(KERN_ERR TAG": cpcap_direct_misc_write error %d !\n", ret);
		}

	} else
		printk(KERN_ERR TAG": wrong parameter !\n");

	return len;
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

	uint32_t enable=0;
	if (!len || len >= BUF_SIZE)
		return -ENOSPC;
	if (copy_from_user(buf, buffer, len))
		return -EFAULT;
	buf[len] = 0;
	if (sscanf(buf, "%u", (uint32_t *) &enable) == 1) {

		printk(KERN_INFO TAG": log enable=%d\n", enable);
		log_enable = (int) enable;

	} else
		printk(KERN_ERR TAG": wrong parameter !\n");
	return len;
}

/*
 * Module init & exit
 */
struct hook_info g_hi[] = {
	HOOK_INIT(cpcap_regacc_write),
	HOOK_INIT_END
};

static int __init ledsfix_init(void) {
	struct proc_dir_entry *proc_entry;

	printk(KERN_INFO  TAG": loading button backlight brightness fix.\n");
	printk(KERN_DEBUG TAG": CPCAP_REG_ADLC=0x%x CPCAP_REG_KLC=0x%x CPCAP_REG_MDLC=0x%x\n", 
		CPCAP_REG_ADLC, CPCAP_REG_KLC, CPCAP_REG_MDLC);

	buf = (char *)vmalloc(BUF_SIZE);
	btreg = (st_cpcap_reg *)vmalloc(sizeof(st_cpcap_reg));

	memset(btreg, 0, sizeof(st_cpcap_reg));
	btreg->reg = CPCAP_BUTTON_BACKLIGHT;
	btreg->mask_wr = CPCAP_BUTTON_WR_MASK;

	proc_root = proc_mkdir(TAG, NULL);
	create_proc_read_entry(TAG"/wr_count", 0444, NULL, proc_wr_count_read, NULL);

	proc_entry = create_proc_read_entry(TAG"/log_enable", 0666, NULL, proc_log_enable_read, NULL);
	proc_entry->write_proc = proc_log_enable_write;

	proc_entry = create_proc_read_entry(TAG"/brightness", 0666, NULL, proc_brightness_read, NULL);
	proc_entry->write_proc = proc_brightness_write;

	//allowed: 0 1f 2f 3f 4f 5f 6f 7f  .. 3ff (64 levels)
	brightness &= 0xFF;

	if (animate)
	test_anim(brightness);

	hook_init();
	hooked = true;

	return 0;
}

static void __exit ledsfix_exit(void) {

	if (hooked) {
		hook_exit();
		hooked = false;
	}

	remove_proc_entry("brightness", proc_root);
	remove_proc_entry("wr_count", proc_root);
	remove_proc_entry("log_enable", proc_root);
	remove_proc_entry(TAG, NULL);

	vfree(btreg);
	vfree(buf);
}

module_init(ledsfix_init);
module_exit(ledsfix_exit);

MODULE_ALIAS(TAG);
MODULE_VERSION("1.0");
MODULE_DESCRIPTION("Fix button backlight brightness level");
MODULE_AUTHOR("Tanguy Pruvot, CyanogenDefy");
MODULE_LICENSE("GPL");
