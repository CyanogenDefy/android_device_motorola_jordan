/*
 * gpiofix - GPIO name fixup module for Motorola Defy
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
#include <linux/device.h>
#include <linux/earlysuspend.h>
#include <linux/proc_fs.h>
#include <linux/vmalloc.h>
#include <asm/uaccess.h>

#include "hook.h"

#define MODULE_TAG "gpiofix"
#define PROC_ENTRY

#define BUF_SIZE 16
static char *buf;

static int gpio_count = 0;

static bool hooked = false;

/* Hooked Function */
static int get_gpio_by_name(char *name) {
    printk(KERN_DEBUG MODULE_TAG": get_gpio_by_name(%s)\n", name);
    gpio_count ++;
    if (0 == strcmp(name, "touch_pwr_en")) {

        name = "touch_panel_reset";
        printk(KERN_INFO MODULE_TAG": using new gpio name : %s\n", name);

    }
    return HOOK_INVOKE(get_gpio_by_name, name);
}

static int proc_gpio_count_read(char *buffer, char **buffer_location,
                                off_t offset, int count, int *eof, void *data) {
    int ret;
    if (offset > 0)
        ret = 0;
    else
        ret = scnprintf(buffer, count, "%u\n", gpio_count);
    return ret;
}

struct hook_info g_hi[] = {
    HOOK_INIT(get_gpio_by_name),
    HOOK_INIT_END
};

static int __init gpiofix_init(void) {
    struct proc_dir_entry *proc_entry;

    buf = (char *)vmalloc(BUF_SIZE);
    proc_mkdir(MODULE_TAG, NULL);
    proc_entry = create_proc_read_entry(MODULE_TAG"/gpio_count", 0444, NULL, proc_gpio_count_read, NULL);

    hook_init();
    hooked = true;

    return 0;
}

static void __exit gpiofix_exit(void) {
    if (hooked) hook_exit();
    remove_proc_entry(MODULE_TAG"/gpio_count", NULL);
    remove_proc_entry(MODULE_TAG, NULL);
    vfree(buf);
}

module_init(gpiofix_init);
module_exit(gpiofix_exit);

MODULE_ALIAS(MODULE_TAG);
MODULE_VERSION("1.0");
MODULE_DESCRIPTION("Hook gpio names requests, to fix touch_pwr_en");
MODULE_AUTHOR("Tanguy Pruvot, CyanogenDefy");
MODULE_LICENSE("GPL");

