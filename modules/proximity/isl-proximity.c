/*
 * proximity - Module for Motorola Defy
 *
 * Copyright (C) 2011 Tanguy Pruvot, CyanogenDefy
 *                    use the symsearch module by Skrilax
 *
 * ISL29028/30 datasheet : http://www.intersil.com/data/fn/fn6780.pdf
 *
 * can be tweeked in /proc/proximity/...
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
#include <linux/device.h>
#include <linux/proc_fs.h>
#include <linux/delay.h>

#include <linux/earlysuspend.h>
#include <linux/i2c.h>
#include <linux/input.h>
#include <linux/miscdevice.h>
#include <linux/platform_device.h>
#include <linux/isl29030.h>
#include <asm/uaccess.h>

#include "../symsearch/symsearch.h"

#define DEBUG 0
#define TAG "proximity"

static struct proc_dir_entry *proc_root=NULL;
static char buf[32];

#ifndef ISL29030_IOCTL_GET_LIGHT_ENABLE
//defy std
struct isl29030_data {
	struct input_dev *idev;
	struct input_dev *adev;
	struct i2c_client *client;
	struct work_struct wq;
	struct workqueue_struct *working_queue;
	struct isl29030_platform_data *pdata;
	struct mutex lock;    /* Mutex to lock read and write */
	struct mutex bit_lock; /* Mutex to lock single bit function */
	struct early_suspend early_suspend;
	unsigned int lux_level;
	atomic_t prox_enabled;
	atomic_t als_enabled;
	atomic_t prox_near;
	atomic_t prox_reported_near;
	atomic_t als_needs_enable_flag;
	atomic_t irq_enabled;
};
#else
//defy plus
struct isl29030_data {
	struct input_dev *dev;
	struct i2c_client *client;
	struct regulator *regulator;
	struct work_struct work;
	struct workqueue_struct *workqueue;
	struct isl29030_platform_data *pdata;
	struct miscdevice miscdevice;
	struct notifier_block pm_notifier;
	struct mutex mutex;
	unsigned int suspended;
	unsigned int hw_initialized;
	unsigned int prox_enabled;
	unsigned int als_enabled;
	unsigned int prox_near;
	unsigned int last_prox_near;
	unsigned int lux_level;
};
#endif

struct isl29030_data *isl29030_misc_data = NULL;

struct isl29030_reg {
	const char *name;
	u8 reg;
} isl29030_regs[] = {
	{ "CHIP_ID",    ISL29030_CHIPID },    //0: 0xC1

	{ "CONFIGURE",  ISL29030_CONFIGURE }, //1: PROX_EN PROX_SLP[2:0] PROX_DR ALS_EN ALS_RANGE ALSIR_MODE
	{ "INTERRUPT",  ISL29030_INTERRUPT }, //2: PROX_FLAG PROX_PRST[1:0] 0 ALS_FLAG ALS_PRST[1:0] INT_CTRL
	{ "PROX_LT",    ISL29030_PROX_LT },   //3: 8-bit interrupt low threshold for proximity sensing
	{ "PROX_HT",    ISL29030_PROX_HT },   //4: 8-bit interrupt high threshold for proximity sensing
	{ "ALS_IR_TH1", ISL29030_ALSIR_TH1 }, //5: Lower 8 bits (of 12 bits) for ALS/IR low interrupt threshold, ALSIR_LT[7:0]
	{ "ALS_IR_TH2", ISL29030_ALSIR_TH2 }, //6: ALSIR_HT[3:0] / ALSIR_LT[11:8]
	{ "ALS_IR_TH3", ISL29030_ALSIR_TH3 }, //7: Upper 8 bits (of 12 bits) for ALS/IR high interrupt threshold, ALSIR_LT[11:4]
	{ "PROX_DATA",  ISL29030_PROX_DATA }, //8: Results of 8-bit proximity sensor ADC conversion
	{ "ALS_IR_DT1", ISL29030_ALSIR_DT1 }, //9: Lower 8 bits (of 12 bits) from result of ALS/IR sensor conversion
	{ "ALS_IR_DT2", ISL29030_ALSIR_DT2 }, //A: Upper 4 bits (of 12 bits) from result of ALS/IR sensor conversion

	{ "ENABLE",     ISL29030_TEST1 },     //E: Test mode register. When 0x00, in normal operation
	{ "DISABLE",    ISL29030_TEST2 },     //F: Test mode register. When 0x00, in normal operation.
};

//Proximity real data:
static unsigned int distance=0;

static unsigned int low_threshold=0;
static unsigned int high_threshold=0;
static unsigned int enabled=0;
static unsigned int speed=0;
static unsigned int highpower=0;

//static unsigned int als_data=0;

#define DBG(format, ...) if (DEBUG) printk(KERN_DEBUG TAG ": " format, ## __VA_ARGS__)

SYMSEARCH_DECLARE_FUNCTION_STATIC(int, ss_isl29030_misc_open, struct inode *inode, struct file *file);
SYMSEARCH_DECLARE_FUNCTION_STATIC(ssize_t, ss_ld_isl29030_registers_show, struct device *dev, struct device_attribute *attr, char *buf);

// We could use existing functions, but defy+ ones seems better than old defy ones :)
//SYMSEARCH_DECLARE_FUNCTION_STATIC(int, ss_isl29030_read_reg, struct isl29030_data *isl, u8 reg, u8 *value);
//SYMSEARCH_DECLARE_FUNCTION_STATIC(int, ss_isl29030_write_reg, struct isl29030_data *isl, u8 reg, u8 value);

//READ/WRITE REGISTERS
//read_reg function from defy+ sources:
static int defy_isl_read_reg(struct isl29030_data *isl, u8 reg, u8 *value)
{
	int error = 0;
	int i = 0;
	u8 dest_buffer;

	do {
		dest_buffer = reg;
		error = i2c_master_send(isl->client, &dest_buffer, 1);
		if (error == 1) {
			error = i2c_master_recv(isl->client,
				&dest_buffer, LD_ISL29030_ALLOWED_R_BYTES);
		}
		if (error != LD_ISL29030_ALLOWED_R_BYTES) {
			pr_err("%s: read[%i] failed: %d\n", __func__, i, error);
			msleep_interruptible(LD_ISL29030_I2C_RETRY_DELAY);
		}
	} while ((error != LD_ISL29030_ALLOWED_R_BYTES) &&
			((++i) < LD_ISL29030_MAX_RW_RETRIES));

	if (error == LD_ISL29030_ALLOWED_R_BYTES) {
		error = 0;
		if (value)
			*value = dest_buffer;
	}
	return error;
}
// write_reg function from defy+ sources:
static int defy_isl_write_reg(struct isl29030_data *isl, u8 reg, u8 value)
{
	u8 buf[LD_ISL29030_ALLOWED_W_BYTES] = { reg, value };
	int bytes;
	int i = 0;

	do {
		bytes = i2c_master_send(isl->client, buf, LD_ISL29030_ALLOWED_W_BYTES);

		if (bytes != LD_ISL29030_ALLOWED_W_BYTES) {
			pr_err("%s: write %d failed: %d\n", __func__, i, bytes);
			msleep_interruptible(LD_ISL29030_I2C_RETRY_DELAY);
		}
	} while ((bytes != (LD_ISL29030_ALLOWED_W_BYTES))
		&& ((++i) < LD_ISL29030_MAX_RW_RETRIES));

	if (bytes != LD_ISL29030_ALLOWED_W_BYTES) {
		pr_err("%s: i2c_master_send error\n", __func__);
		return -EIO;
	}
	return 0;
}
// our simple read/write functions
static int isl_read_reg(u8 reg, int *val)
{
	int ret=0;
	u8 value=0;
	if (isl29030_misc_data==NULL) return -1;
	//SYMSEARCH_BIND_FUNCTION_TO(proximity, isl29030_read_reg, ss_isl29030_read_reg);
	//ret = ss_isl29030_read_reg(isl29030_misc_data, reg, &value);
	ret = defy_isl_read_reg(isl29030_misc_data, reg, &value);
	if (ret == 0) {
		*val = value;
	}
	return ret;
}
static int isl_write_reg(u8 reg, int val)
{
	int ret=0;
	u8 value=val & 0xFF;
	if (isl29030_misc_data==NULL) return -1;
	//SYMSEARCH_BIND_FUNCTION_TO(proximity, isl29030_write_reg, ss_isl29030_write_reg);
	//ret = ss_isl29030_write_reg(isl29030_misc_data, reg, value);
	ret = defy_isl_write_reg(isl29030_misc_data, reg, value);
	return ret;
}

static int isl_enable(int onoff)
{
	int ret, regv;
	ret = isl_read_reg(ISL29030_CONFIGURE, &regv);
	if (ret == 0) {
		if (onoff)
			regv |= 0x80;
		else
			regv &= 0x7F;
		ret = isl_write_reg(ISL29030_CONFIGURE, regv);
	}
	return ret;
}

//PROX_LT
static int proc_low_threshold_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data)
{
	int ret;
	if (offset > 0) return 0;
	isl_read_reg(ISL29030_PROX_LT, &low_threshold);
	ret = scnprintf(buffer, count, "%d\n", low_threshold);
	return ret;
}
static int proc_low_threshold_write(struct file *filp, const char __user *buffer, unsigned long len, void *data)
{
	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;

	buf[len] = 0;
	if (sscanf(buf, "%u", &low_threshold) >= 1) {
		isl_write_reg(ISL29030_PROX_LT, low_threshold);
	}
	return len;
}

//PROX_HT
static int proc_high_threshold_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data)
{
	int ret;
	if (offset > 0) return 0;
	isl_read_reg(ISL29030_PROX_HT, &high_threshold);
	ret = scnprintf(buffer, count, "%d\n", high_threshold);
	return ret;
}
static int proc_high_threshold_write(struct file *filp, const char __user *buffer, unsigned long len, void *data)
{
	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;

	buf[len] = 0;
	if (sscanf(buf, "%u", &high_threshold) >= 1) {
		isl_write_reg(ISL29030_PROX_HT, high_threshold);
	}
	return len;
}

//PROX_EN
static int proc_enabled_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data)
{
	int ret, regv=0;
	if (offset > 0) return 0;
	isl_read_reg(ISL29030_CONFIGURE, &regv);
	enabled = ((regv & 0x80) != 0);
	ret = scnprintf(buffer, count, "%d\n", enabled);
	return ret;
}

static int proc_enabled_write(struct file *filp, const char __user *buffer, unsigned long len, void *data)
{
	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;

	buf[len] = 0;
	if (sscanf(buf, "%u", &enabled) >= 1) {
		isl_enable(enabled);
	}
	return len;
}

/* PROX_DR: IR LED brightness
 * 1 220ma
 * 0 110mA (normal)
 */
static int proc_highpower_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data)
{
	int ret, regv=0;
	if (offset > 0) return 0;
	isl_read_reg(ISL29030_CONFIGURE, &regv);
	highpower = (regv & 0x08) >> 3;
	ret = scnprintf(buffer, count, "%d\n", highpower);
	return ret;
}
static int proc_highpower_write(struct file *filp, const char __user *buffer, unsigned long len, void *data)
{
	int ret, regv=0;
	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;

	buf[len] = 0;
	if (sscanf(buf, "%u", &highpower) == 1) {
		isl_read_reg(ISL29030_CONFIGURE, &regv);
		if (highpower)
			regv |= 0x8;
		else
			regv &= 0xF7;
		ret = isl_write_reg(ISL29030_CONFIGURE, regv);
		if (ret != 0)
			printk(KERN_ERR TAG ": err %d !", ret);
		highpower = (regv & 0x08) >> 3;
	}
	return len;
}

/* PROX_SLP: sleep time between prox IR LED pulses
 * 7 111; always (disabled to reduce risks)
 * 6 110; 12.5ms
 * 5 101; 50ms
 * 4 100; 75ms
 * 3 011; 100ms
 * 2 010; 200ms
 * 1 001; 400ms
 * 0 000; 800ms
 */
static int proc_speed_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data)
{
	int ret, regv=0;
	if (offset > 0) return 0;
	ret = isl_read_reg(ISL29030_CONFIGURE, &regv);
	if (ret == 0) {
		speed = (regv & 0x70) >> 4;
		ret = scnprintf(buffer, count, "%d\n", speed);
	}
	return ret;
}
static int proc_speed_write(struct file *filp, const char __user *buffer, unsigned long len, void *data)
{
	int ret, regv=0, sleep;
	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;

	buf[len] = 0;
	if (sscanf(buf, "%u", &speed) == 1) {
		if (speed > 6) speed = 6;
		isl_read_reg(ISL29030_CONFIGURE, &regv);
		regv &= 0x8F;
		sleep = (speed << 4) & 0x70;
		regv |= sleep;
		ret = isl_write_reg(ISL29030_CONFIGURE, regv);
		if (ret != 0)
			printk(KERN_ERR TAG ": err %d !", ret);
	}
	return len;
}
//PROX_DATA
static int proc_distance_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data)
{
	int ret, regv=0;
	if (offset > 0) return 0;
		
	isl_read_reg(ISL29030_CONFIGURE, &regv);
	enabled = ((regv & 0x80) != 0);
	if (!enabled) {
		// temporary enable
		isl_enable(1);
		msleep_interruptible(1);
		isl_read_reg(ISL29030_PROX_DATA, &distance);
		// then restore original state
		ret = isl_write_reg(ISL29030_CONFIGURE, regv);
	} else {
		isl_read_reg(ISL29030_PROX_DATA, &distance);
	}
	ret = scnprintf(buffer, count, "%d\n", distance);
	return ret;
}
/*
//ALS DATA
static int proc_als_data_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data)
{
	int ret, adj, value=0;
	if (offset > 0) return 0;
	ret = isl_read_reg(ISL29030_ALSIR_DT1, &value);
	adj = value;
	ret |= isl_read_reg(ISL29030_ALSIR_DT2, &value);
	adj |= 0x100 * (value & 0xF) ;
	if (ret == 0) {
		als_data = value;
		ret = scnprintf(buffer, count, "0x%x\n", als_data);
	}
	return ret;
}
static int proc_adj_write(struct file *filp, const char __user *buffer, unsigned long len, void *data)
{
	int adj, value=0;
	if (isl29030_misc_data==NULL) return 0;
	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;

	buf[len] = 0;
	if (sscanf(buf, "%u", &adj) >= 1) {
		value = adj & 0xFF;
		isl_write_reg(ISL29030_ALSIR_DT1, value);
		value = (adj & 0x0F00) / 0x100;
		isl_write_reg(ISL29030_ALSIR_DT2, value);
	}
	return len;
}
*/

//REGISTERS FULL DUMP
static int proc_regs_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data)
{
	int ret = 0;
	char regdata[512];
	if (offset > 0 || isl29030_misc_data==NULL) return 0;
	SYMSEARCH_BIND_FUNCTION_TO(proximity, ld_isl29030_registers_show, ss_ld_isl29030_registers_show);
	if (isl29030_misc_data->client != NULL) {
		ss_ld_isl29030_registers_show(&isl29030_misc_data->client->dev, NULL, &regdata[0]);
		ret = scnprintf(buffer, count, "%s\n", &regdata[0]);
	}
	return ret;
}

static int __init proximity_init(void) {
	struct proc_dir_entry *proc_entry;
	struct inode inode;
	struct file f;
	int ret=0;

	//This function allow us to get the isl29030_misc_data pointer
	SYMSEARCH_BIND_FUNCTION_TO(proximity, isl29030_misc_open, ss_isl29030_misc_open);

	memset(&f, 0, sizeof(f));
	ret = ss_isl29030_misc_open(&inode,&f);
	if (f.private_data == NULL) {
		printk(KERN_ERR TAG ": sensor data not found !");
		return -EFAULT;
	}
	isl29030_misc_data = f.private_data;
	printk(KERN_INFO TAG ": sensor data found.");

	memset(&buf, 0, sizeof(buf));

	proc_root = proc_mkdir(TAG, NULL);
	proc_entry = create_proc_read_entry("registers", 0444, proc_root, proc_regs_read, NULL);

	proc_entry = create_proc_read_entry("distance", 0444, proc_root, proc_distance_read, NULL);

	proc_entry = create_proc_read_entry("highpower", 0664, proc_root, proc_highpower_read, NULL);
	proc_entry->write_proc = proc_highpower_write;
	proc_entry = create_proc_read_entry("speed", 0664, proc_root, proc_speed_read, NULL);
	proc_entry->write_proc = proc_speed_write;

	proc_entry = create_proc_read_entry("low_threshold",  0664, proc_root, proc_low_threshold_read, NULL);
	proc_entry->write_proc = proc_low_threshold_write;
	proc_entry = create_proc_read_entry("high_threshold", 0664, proc_root, proc_high_threshold_read, NULL);
	proc_entry->write_proc = proc_high_threshold_write;

	proc_entry = create_proc_read_entry("enabled", 0664, proc_root, proc_enabled_read, NULL);
	proc_entry->write_proc = proc_enabled_write;

	//proc_entry = create_proc_read_entry("light", 0444, proc_root, proc_als_data_read, NULL);

	return ret;
}

static void __exit proximity_exit(void) {
	if (proc_root) {
		remove_proc_entry("registers", proc_root);

		remove_proc_entry("distance", proc_root);
		remove_proc_entry("highpower", proc_root);
		remove_proc_entry("speed", proc_root);

		remove_proc_entry("low_threshold", proc_root);
		remove_proc_entry("high_threshold", proc_root);

		remove_proc_entry("enabled", proc_root);

		//remove_proc_entry("light", proc_root);
		remove_proc_entry(TAG, NULL);
	}
}

module_init(proximity_init);
module_exit(proximity_exit);

MODULE_ALIAS("proximity");
MODULE_VERSION("1.0");
MODULE_DESCRIPTION("Customize proximity sensor registers");
MODULE_AUTHOR("Tanguy Pruvot, CyanogenDefy");
MODULE_LICENSE("GPL");
