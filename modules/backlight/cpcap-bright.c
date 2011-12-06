/*
 * backlight - Button backlight cpcap fix for Motorola Defy
 *
 * hooking taken from "n - for testing kernel function hooking" by Nothize
 * require symsearch module by Skrilaz
 *
 * Copyright (C) 2011 CyanogenDefy - GPL
 */

#include <linux/module.h>
#include <linux/moduleparam.h>

#include <linux/delay.h>
#include <linux/device.h>
#include <linux/proc_fs.h>

#include <linux/leds.h>
#include <linux/spi/cpcap.h>

#include "hook.h"
#include "../symsearch/symsearch.h"

#define TAG "backlight"

#define CPCAP_BUTTON_DEV       "button-backlight"
#define CPCAP_BUTTON_BACKLIGHT CPCAP_REG_ADLC

#define DEFYPLUS

//Only in Defy froyo kernel, not in Defy+
#ifndef DEFYPLUS
# include <linux/leds-ld-cpcap.h> //for LD_BUTTON_CPCAP_MASK (0x3FF)
# define CPCAP_BUTTON_WR_MASK   LD_BUTTON_CPCAP_MASK
#else
# define CPCAP_BUTTON_WR_MASK   0x7FF
#endif

// module parameters (see end of file for descriptions)
static short brightness = -1;
static short animate = 0;
static short defy_plus = 0;
static short log_enable = 0;
static short hook_enable = 0;

// internals
static short hooked = 0;
static struct proc_dir_entry *proc_root;
static struct led_classdev *button_dev = NULL;

// storage for last register state
unsigned short g_reg;
unsigned short g_mask_wr;
unsigned short g_last_value;

// small buffer for procfs i/o
static char buf[32];

#define DBG(format, ...) if (log_enable) printk(KERN_DEBUG TAG ": " format, ## __VA_ARGS__)

/*
 * Conversion 0-255 to CPCAP REG
 */
unsigned short brightness_to_cpcap(unsigned short level) {
	unsigned short val, newval;

	level &= 0xFF; //255 is max

	if (defy_plus) {

		//some (bits) seems reversed, to tune or fix..
		// 32 is problematic :/

		//0b0111 1111 100X
		newval = level * 8 | ((level & 0xC0) / 0x20);

		if (level < 8) newval = level * 8;

		if (level) newval |= 0x1; //(X for on/off)

	} else {
		//allowed: 0 1f 2f 3f 4f 5f 6f 7f  .. 3ff (64 levels)
		newval = (level * 4) | 0xF;

		if (level <= 5) newval = 0x1F;
	}

	if (level == 0) newval=0;

	val = newval & g_mask_wr;

	DBG("convert %d -> 0x%x\n", level, val);

	return val;
}

SYMSEARCH_DECLARE_FUNCTION_STATIC(
	int, _cpcap_direct_misc_write, unsigned short reg, unsigned short value, unsigned short mask);
/*
 * Animation
 */
int brightness_fading(short level) {
	unsigned short n, val;

	SYMSEARCH_BIND_FUNCTION_TO(backlight, cpcap_direct_misc_write, _cpcap_direct_misc_write);
	for (n=2; n < 32; n++) {
		val = brightness_to_cpcap(n*8 - 1);
		_cpcap_direct_misc_write(g_reg, val, g_mask_wr);
		msleep_interruptible(3);
	}
	for (n=31; n > 0; n--) {
		val = brightness_to_cpcap(n*8 - 1);
		_cpcap_direct_misc_write(g_reg, val, g_mask_wr);
		//if ((n*8) < level) break;
		msleep_interruptible(1);
	}
	return 0;
}

/*
 * hooked function (io reg write)
 */
int cpcap_regacc_write(struct cpcap_device *cpcap, enum cpcap_reg reg, unsigned short value, unsigned short mask) {

	if (reg != CPCAP_BUTTON_BACKLIGHT) {
		goto invoke;
	}

	DBG("got value 0x%x(%d) mask %x\n", value, value, mask);

	// read original value
	if (button_dev) {
		if (button_dev->brightness > 1) {
			brightness = button_dev->brightness;
		}
		DBG("got button->brightness=%d\n", brightness);
	}
	value = brightness_to_cpcap(brightness);
	DBG("write REG 0x%02x(%d) set/mask %x/%x\n", (unsigned int) reg, reg, value, mask);

        g_mask_wr |= mask;
        g_last_value = value;

	if (defy_plus && mask == 0xf) {
		mask = CPCAP_BUTTON_WR_MASK;
	}

	//The hooked func should be invoked at one single place
invoke:
	return HOOK_INVOKE(cpcap_regacc_write, cpcap, reg, value, mask);
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
	unsigned short val=0;
	int ret;

	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;
	buf[len] = 0;

	if (sscanf(buf, "%u", &newval) > 0) {

		brightness = newval & 0xff;
		val = brightness_to_cpcap(newval);
		DBG("brightness set to %d 0x%x\n", brightness, val);

		if (button_dev) {
			button_dev->brightness = brightness;
			DBG("button_dev->brightness set to %d\n", brightness);
		}

		SYMSEARCH_BIND_FUNCTION_TO(backlight, cpcap_direct_misc_write, _cpcap_direct_misc_write);
		ret = _cpcap_direct_misc_write(g_reg, val, g_mask_wr);
		if (ret < 0) {
			printk(KERN_ERR TAG": cpcap_direct_misc_write error %d !\n", ret);
		}

	} else
		printk(KERN_ERR TAG": wrong parameter !\n");

	return len;
}

static int proc_hook_read(char *buffer, char **start, off_t offset, int count, int *eof, void *data) {
	int ret = 0;
	if (!offset) ret = scnprintf(buffer, count, "%u\n", hooked);
	return ret;
}

static int proc_hook_write(struct file *filp, const char __user *buffer, unsigned long len, void *data) {
	uint32_t newval=0;

	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;
	buf[len] = 0;
	if (sscanf(buf, "%d", (uint32_t *) &newval) > 0) {

		if  (!newval && hooked) {
			hook_exit();
			hooked = 0;
		} else if (newval && !hooked) {
			hook_init();
			hooked = 1;
		}
	}
	return len;
}

static int proc_log_enable_read(char *buffer, char **start, off_t offset, int count, int *eof, void *data) {
	int ret=0;
	if (!offset) ret = scnprintf(buffer, count, "%u\n", log_enable);
	return ret;
}

//set log type (1: simple dmesg, 2: /proc entries)
static int proc_log_enable_write(struct file *filp, const char __user *buffer, unsigned long len, void *data) {

	uint32_t enable=0;
	if (!len || len >= sizeof(buf)) return -ENOSPC;
	if (copy_from_user(buf, buffer, len)) return -EFAULT;
	buf[len] = 0;

	if (sscanf(buf, "%u", (uint32_t *) &enable) == 1) {

		printk(KERN_INFO TAG": log enable=%d\n", enable);
		log_enable = (int) enable;

	} else
		printk(KERN_ERR TAG": wrong parameter !\n");
	return len;
}

/*
 * Original Led Interface
 */
extern struct rw_semaphore leds_list_lock;
extern struct list_head leds_list;

// Find and read current brightness set in led system
static int find_led_brightness(void) {
	struct led_classdev *led_cdev = NULL;
	int ret=-1;

	down_read(&leds_list_lock);
	list_for_each_entry(led_cdev, &leds_list, node) {
		if (strcmp(led_cdev->name, CPCAP_BUTTON_DEV) == 0) {
			button_dev = led_cdev;
			ret=0;
			break;
		}
	}

	// more logs
	if (log_enable > 1) {
		printk(KERN_INFO TAG": leds");
		list_for_each_entry(led_cdev, &leds_list, node) {
			printk(" %s", led_cdev->name);
		}
		printk("\n");
	}

	up_read(&leds_list_lock);

	return ret;
}

/*
 * Module init & exit
 */
struct hook_info g_hi[] = {
	HOOK_INIT(cpcap_regacc_write),
	HOOK_INIT_END
};

static int __init backlight_init(void) {
	struct proc_dir_entry *proc_entry;

	printk(KERN_INFO TAG": loading button backlight brightness fix.\n");
	DBG("CPCAP_REG_ADLC=0x%x mode=%s\n", CPCAP_REG_ADLC, defy_plus ? "defy+":"defy");

	memset(buf, 0, sizeof(buf));

	g_reg     = CPCAP_BUTTON_BACKLIGHT;
	g_mask_wr = CPCAP_BUTTON_WR_MASK;
	if (defy_plus) g_mask_wr = 0x7ff; //0b1111.111.111.1

	proc_root = proc_mkdir(TAG, NULL);

	proc_entry = create_proc_read_entry("log_enable", 0666, proc_root, proc_log_enable_read, NULL);
	proc_entry->write_proc = proc_log_enable_write;
	proc_entry = create_proc_read_entry("hook_enable", 0666, proc_root, proc_hook_read, NULL);
	proc_entry->write_proc = proc_hook_write;
	proc_entry = create_proc_read_entry("brightness", 0666, proc_root, proc_brightness_read, NULL);
	proc_entry->write_proc = proc_brightness_write;

	if (find_led_brightness() == 0) {
		if (brightness == -1) {
			brightness = button_dev->brightness;
		}
		DBG("button_dev->brightness = %d\n", button_dev->brightness);
	}
	if (brightness == -1 || brightness == 1 || brightness == 255) {
		brightness = 4;
	}
	brightness &= 0xFF;

	if (animate) brightness_fading(brightness);
	if (hook_enable) {
		hook_init();
		hooked = 1;
	}

	return 0;
}

static void __exit backlight_exit(void) {

	if (hooked) {
		hook_exit();
		hooked = 0;
	}

	remove_proc_entry("brightness", proc_root);
	remove_proc_entry("log_enable", proc_root);
	remove_proc_entry("hook_enable", proc_root);
	remove_proc_entry(TAG, NULL);
}

module_param(defy_plus, short, 0);
MODULE_PARM_DESC(defy_plus,   "Defy (Froyo) or Defy+ (Gingerbread) kernel (0-1)");
module_param(animate , short, 0);
MODULE_PARM_DESC(animate,     "Animation on module load (default 0)");
module_param(log_enable , short, 0);
MODULE_PARM_DESC(log_enable,  "Enable dmesg logs (0/1)");
module_param(hook_enable , short, 0);
MODULE_PARM_DESC(hook_enable, "Enable hook on cpcap, required if liblight is not present (default 0)");
module_param(brightness, short, 0);
MODULE_PARM_DESC(brightness,  "Default brightness level (0-255)");

module_init(backlight_init);
module_exit(backlight_exit);

MODULE_ALIAS(TAG);
MODULE_VERSION("2.0");
MODULE_DESCRIPTION("Fix button backlight brightness level");
MODULE_AUTHOR("Tanguy Pruvot, CyanogenDefy");
MODULE_LICENSE("GPL");
