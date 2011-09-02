/*
 * MMC-fix: fix SD card read/write errors (mmcblk0: error -110 - common and known
 * linux-omap issue) by replacement of set_data_timeout function in omap_hsmmc.c
 * to use the default DTO value of 0xE instead of dynamic calculation.
 *
 * hooking taken from "n - for testing kernel function hooking" by Nothize.
 *
 * Copyright (C) 2011 Nadlabak
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

#include <linux/device.h>
#include <linux/io.h>
#include <linux/module.h>
#include <linux/workqueue.h>
#include "hook.h"

#define DTO                     0xe
#define DTO_MASK                0x000F0000
#define DTO_SHIFT               16
#define OMAP_HSMMC_SYSCTL       0x012C

/*
 * MMC Host controller read/write API's
 */
#define OMAP_HSMMC_READ(base, reg)      \
    __raw_readl((base) + OMAP_HSMMC_##reg)

#define OMAP_HSMMC_WRITE(base, reg, val) \
    __raw_writel((val), (base) + OMAP_HSMMC_##reg)

struct omap_hsmmc_host {
    struct  device          *dev;
    struct  mmc_host        *mmc;
    struct  mmc_request     *mrq;
    struct  mmc_command     *cmd;
    struct  mmc_data        *data;
    struct  clk             *fclk;
    struct  clk             *iclk;
    struct  clk             *dbclk;
    struct  semaphore       sem;
    struct  work_struct     mmc_carddetect_work;
    void    __iomem         *base;
    resource_size_t         mapbase;
    spinlock_t              irq_lock; /* Prevent races with irq handler */
    unsigned long           flags;
    unsigned int            id;
    unsigned int            dma_len;
    unsigned int            dma_sg_idx;
    unsigned char           bus_mode;
    unsigned char           power_mode;
    u32                     *buffer;
    u32                     bytesleft;
    int                     suspended;
    int                     irq;
    int                     use_dma, dma_ch;
    int                     dma_line_tx, dma_line_rx;
    int                     slot_id;
    int                     got_dbclk;
    int                     response_busy;
    int                     context_loss;
    int                     dpm_state;
    int                     vdd;
    int                     protect_card;
    int                     reqs_blocked;

    struct  omap_mmc_platform_data  *pdata;
};

// hooked function
static void set_data_timeout(struct omap_hsmmc_host *host,
                             unsigned int timeout_ns,
                             unsigned int timeout_clks)
{
    uint32_t reg;

//  printk(KERN_INFO "MMC-fix: set_data_timeout called\n");
    reg = OMAP_HSMMC_READ(host->base, SYSCTL);

    reg &= ~DTO_MASK;
    reg |= DTO << DTO_SHIFT;
    OMAP_HSMMC_WRITE(host->base, SYSCTL, reg);
    if (0) HOOK_INVOKE(set_data_timeout, host, timeout_ns, timeout_clks);
}


struct hook_info g_hi[] = {
    HOOK_INIT(set_data_timeout),
    HOOK_INIT_END
};

static int __init mmcfix_init(void)
{
    printk(KERN_INFO "MMC-fix init\n");
    hook_init();
    return 0;
}

static void __exit mmcfix_exit(void)
{
    hook_exit();
}

module_init(mmcfix_init);
module_exit(mmcfix_exit);

MODULE_ALIAS("MMC-fix");
MODULE_AUTHOR("CyanogenDefy - Built by Tanguy Pruvot - Created by Nadlabak");
MODULE_DESCRIPTION("fix omap hsmmc driver timeouts via kernel function hook");
MODULE_LICENSE("GPL");

