/*
 * multitouch - Dynamic module for Motorola Defy
 * needs symsearch module by Skrilaz
 * hooking taken from "n - for testing kernel function hooking" by Nothize
 *
 * number of contacts : can be set by write to /proc/multitouch/num (2-10)
 *
 * Copyright (C) 2011 CyanogenDefy, based on the concept Nadlabak
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

#include <linux/earlysuspend.h>
#include <linux/i2c.h>
#include <linux/input.h>
#include <linux/qtouch_obp_ts.h>
#include <asm/uaccess.h>

#include "hook.h"
#include "../symsearch/symsearch.h"

#define DEBUG 0
#define TAG "multitouch"

struct qtm_object {
	struct qtm_obj_entry        entry;
	uint8_t             report_id_min;
	uint8_t             report_id_max;
};

struct coordinate_map {
	int x_data;
	int y_data;
	int z_data;
	int w_data;
	int down;
};

#define _BITMAP_LEN         BITS_TO_LONGS(QTM_OBP_MAX_OBJECT_NUM)
#define _NUM_FINGERS        10 // DON'T CHANGE HERE: it's a kernel constant

//note: in kernel memory, uint8_t of this structure use 4 bytes
struct qtouch_ts_data {
	struct i2c_client               *client;     //filled
	struct input_dev                *input_dev;  //filled
	struct work_struct              init_work;   //null
	struct work_struct              work;        //null
	struct work_struct              boot_work;   //null
	struct qtouch_ts_platform_data  *pdata;      //null
	struct coordinate_map           finger_data[_NUM_FINGERS]; // 4 ptr, 0, 5ptr, 0
	struct early_suspend            early_suspend;

	struct qtm_object   obj_tbl[QTM_OBP_MAX_OBJECT_NUM];
	unsigned long       obj_map[_BITMAP_LEN];

	uint32_t            last_keystate;
	uint16_t            eeprom_checksum;
	uint8_t             checksum_cnt;
	int                 x_delta;
	int                 y_delta;
	uint8_t             family_id;
	uint8_t             variant_id;
	uint8_t             fw_version;
	uint8_t             build_version;
	uint8_t             fw_error_count;
	uint32_t            touch_fw_size;
	uint8_t             *touch_fw_image;
	uint8_t             base_fw_version;

	atomic_t            irq_enabled;
	int                 status;
	uint8_t             mode;
	int                 boot_pkt_size;
	int                 current_pkt_sz;
	uint8_t             org_i2c_addr;
	uint8_t             *msg_buf;
	int                 msg_size;
};

static struct qtouch_ts_data *ts_=NULL;
static struct proc_dir_entry *proc_root;
static char buf[32];

static bool hooked = false;
static bool checksumNeedsCorrection = false;
static uint16_t eeprom_checksum;

static int wanted_touch;
static int touch_num = 2;
module_param(touch_num, int, 0);
MODULE_PARM_DESC(touch_num,  "Number of contacts 2-10");

#define DBG(format, ...) if (DEBUG) printk(KERN_DEBUG TAG ": " format, ## __VA_ARGS__)

//static void qtouch_force_reset(struct qtouch_ts_data *ts, uint8_t sw_reset)
SYMSEARCH_DECLARE_FUNCTION_STATIC(void, ss_qtouch_force_reset, struct qtouch_ts_data *ts, uint8_t sw_reset);
SYMSEARCH_DECLARE_FUNCTION_STATIC(int, ss_mapphone_touch_reset, void);

static int set_numtouch(void) {

	if (ts_ == NULL) return -1;

	printk(KERN_INFO TAG": set num_touch to %d\n", wanted_touch);
	ts_->pdata->multi_touch_cfg.num_touch = wanted_touch;
	DBG("forcing checksum error to run qtouch_hw_init()\n");
	ts_->pdata->flags |= QTOUCH_EEPROM_CHECKSUM;
	eeprom_checksum = ts_->eeprom_checksum;
	ts_->eeprom_checksum = 0;
	ts_->checksum_cnt = 0;
	checksumNeedsCorrection = true;

	SYMSEARCH_BIND_FUNCTION_TO(multitouch, qtouch_force_reset, ss_qtouch_force_reset);
	ss_qtouch_force_reset(ts_, 0);

	return 0;
}

/* Hooked function used to find out ts address */
static int qtouch_set_addr(struct qtouch_ts_data *ts, uint16_t addr) {
	int ret=0;
	ret = HOOK_INVOKE(qtouch_set_addr, ts, addr);
	if (ts != NULL && ts->pdata != NULL) {
		touch_num = ts->pdata->multi_touch_cfg.num_touch;
		if (touch_num != wanted_touch) {
			ts_ = ts;
			DBG("wanted/current multitouch points: %d/%d\n", wanted_touch, touch_num);
			set_numtouch();
		}
	}
	DBG("qtouch_set_addr 0x%x=%d\n", addr, ret);
	return ret;
}

static int qtouch_hw_init(struct qtouch_ts_data *ts) {
	DBG("qtouch_hw_init\n");
	if (checksumNeedsCorrection) {
		DBG("checksum need correction...\n");
		checksumNeedsCorrection = false;
		ts->eeprom_checksum = eeprom_checksum;
	}
	return HOOK_INVOKE(qtouch_hw_init, ts);
}


static int proc_numtouch_read(char *buffer, char **buffer_location, off_t offset, int count, int *eof, void *data) {
	int ret;
	if (offset > 0) return 0;
	ret = scnprintf(buffer, count, "%u\n", touch_num);
	return ret;
}

static int proc_numtouch_write(struct file *filp, const char __user *buffer, unsigned long len, void *data)
{
	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;

	buf[len] = 0;
	if (sscanf(buf, "%d", &wanted_touch) >= 1) {
		if (!hooked) {
			hook_init();
		}
		if (wanted_touch > 10) wanted_touch = 10;
		else if (wanted_touch < 2) wanted_touch = 2;
		if (touch_num != wanted_touch && !checksumNeedsCorrection) {
			DBG("wanted touch_num : %d...\n", wanted_touch);
			if (ts_) {
				set_numtouch();
			} else {
				DBG("ts address not set!\n");
				DBG("was the screen off at the time of insmod?\n");

				SYMSEARCH_BIND_FUNCTION_TO(multitouch, mapphone_touch_reset, ss_mapphone_touch_reset);
				ss_mapphone_touch_reset();
			}
		}
	}
	return len;
}

struct hook_info g_hi[] = {
	HOOK_INIT(qtouch_set_addr),
	HOOK_INIT(qtouch_hw_init),
	HOOK_INIT_END
};

static int __init multitouch_init(void) {
	struct proc_dir_entry *proc_entry;

	memset(&buf, 0, sizeof(buf));

	proc_root = proc_mkdir(TAG, NULL);
	proc_entry = create_proc_read_entry("num", 0666, proc_root, proc_numtouch_read, NULL);
	proc_entry->write_proc = proc_numtouch_write;

	hook_init();
	hooked = true;

	wanted_touch = touch_num;

	/* reset will provoke qtouch_set_addr call, so we can get the ts struct address immediately */
	SYMSEARCH_BIND_FUNCTION_TO(multitouch, mapphone_touch_reset, ss_mapphone_touch_reset);
	ss_mapphone_touch_reset();

	printk(KERN_INFO TAG": wrong parameter for wanted_touch\n");
	return 0;
}

static void __exit multitouch_exit(void) {
	if (hooked) hook_exit();
	if (proc_root) {
		remove_proc_entry("num", proc_root);
		remove_proc_entry(TAG, NULL);
	}
}

module_init(multitouch_init);
module_exit(multitouch_exit);

MODULE_ALIAS("multitouch");
MODULE_VERSION("2.0");
MODULE_DESCRIPTION("Customize on-the-fly qtouch touchscreen number of finger contacts");
MODULE_AUTHOR("Tanguy Pruvot, Pavel Kucera");
MODULE_LICENSE("GPL");
