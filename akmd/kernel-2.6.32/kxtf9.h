/*
 * Copyright (C) 2009 Kionix, Inc.
 * Written by Chris Hudson <chudson@kionix.com>
 *
 * Copyright (C) 2010 Motorola, Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 * 02111-1307, USA
 */

#ifndef __KXTF9_H__
#define __KXTF9_H__

#include <linux/ioctl.h>  /* For IOCTL macros */

/** This define controls compilation of the master device interface */
/*#define KXTF9_MASTER_DEVICE*/

#define KXTF9_IOCTL_BASE 77
/** The following define the IOCTL command values via the ioctl macros */
#define KXTF9_IOCTL_SET_DELAY		_IOW(KXTF9_IOCTL_BASE, 0, int)
#define KXTF9_IOCTL_GET_DELAY		_IOR(KXTF9_IOCTL_BASE, 1, int)
#define KXTF9_IOCTL_SET_ENABLE		_IOW(KXTF9_IOCTL_BASE, 2, int)
#define KXTF9_IOCTL_GET_ENABLE		_IOR(KXTF9_IOCTL_BASE, 3, int)
#define KXTF9_IOCTL_SET_G_RANGE		_IOW(KXTF9_IOCTL_BASE, 4, int)
#define KXTF9_IOCTL_SET_TILT_ENABLE	_IOW(KXTF9_IOCTL_BASE, 5, int)
#define KXTF9_IOCTL_SET_TAP_ENABLE	_IOW(KXTF9_IOCTL_BASE, 6, int)
#define KXTF9_IOCTL_SET_WAKE_ENABLE	_IOW(KXTF9_IOCTL_BASE, 7, int)
#define KXTF9_IOCTL_SET_SENSITIVITY	_IOW(KXTF9_IOCTL_BASE, 8, int)

/* CONTROL REGISTER 1 BITS */
#define RES_12BIT		0x40
#define KXTF9_G_2G		0x00
#define KXTF9_G_4G		0x08
#define KXTF9_G_8G		0x10
#define TPE			0x01	/* tilt position function enable bit */
#define WUFE			0x02	/* wake-up function enable bit */
#define TDTE			0x04	/* tap/double-tap function enable bit */
/* CONTROL REGISTER 3 BITS */
#define OTP1_6			0x00	/* tilt ODR masks */
#define OTP6_3			0x20
#define OTP12_5			0x40
#define OTP50			0x60
#define OWUF25			0x00	/* wuf ODR masks */
#define OWUF50			0x01
#define OWUF100			0x02
#define OWUF200			0x03
#define OTDT50			0x00	/* tdt ODR masks */
#define OTDT100			0x04
#define OTDT200			0x08
#define OTDT400			0x0C
/* INTERRUPT CONTROL REGISTER 1 BITS */
#define IEN			0x20	/* interrupt enable */
#define IEA			0x10	/* interrupt polarity */
#define IEL			0x08	/* interrupt response */
#define IEU			0x04	/* alternate unlatched response */
/* DATA CONTROL REGISTER BITS */
#define ODR800			0x06	/* lpf output ODR masks */
#define ODR400			0x05
#define ODR200			0x04
#define ODR100			0x03
#define ODR50			0x02
#define ODR25			0x01
#define ODR12_5			0x00	/* Do not use per Kionix */
/* Interrupt status */
#define KXTF9_INT_TAP2		0x08000000
#define KXTF9_INT_TAP1		0x04000000
#define KXTF9_INT_TILT		0x01000000

#define SENSITIVITY_REGS	7

#ifdef __KERNEL__
struct kxtf9_platform_data {
	int poll_interval;
	int min_interval;

	u8 g_range;

	u8 axis_map_x;
	u8 axis_map_y;
	u8 axis_map_z;

	u8 negate_x;
	u8 negate_y;
	u8 negate_z;

	u8 data_odr_init;
	u8 ctrl_reg1_init;
	u8 int_ctrl_init;
	u8 tilt_timer_init;
	u8 engine_odr_init;
	u8 wuf_timer_init;
	u8 wuf_thresh_init;
	u8 tdt_timer_init;
	u8 tdt_h_thresh_init;
	u8 tdt_l_thresh_init;
	u8 tdt_tap_timer_init;
	u8 tdt_total_timer_init;
	u8 tdt_latency_timer_init;
	u8 tdt_window_timer_init;

	int (*init)(void);
	void (*exit)(void);
	int (*power_on)(void);
	int (*power_off)(void);

	int gpio;

	u8 gesture;
	u8 sensitivity_low[SENSITIVITY_REGS];
	u8 sensitivity_medium[SENSITIVITY_REGS];
	u8 sensitivity_high[SENSITIVITY_REGS];
};

#endif /* __KERNEL__ */

#endif  /* __KXTF9_H__ */
