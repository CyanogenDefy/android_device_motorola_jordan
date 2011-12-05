#ifndef _LINUX_I2C_AKM8973_H
#define _LINUX_I2C_AKM8973_H

#include <linux/ioctl.h>

#ifdef __KERNEL__

struct akm8973_platform_data {
	int	cal_min_threshold;
	int	cal_max_threshold;

	int	xy_swap;
	int	z_flip;
	int	orientation; /* 0, 90, 180, or 270 */

	int	poll_interval;
	int	min_interval;

	/* offset dac calibration bytes */
	u8	hxda;
	u8	hyda;
	u8	hzda;

	int (*init)(void);
	void (*exit)(void);
	int (*power_on)(void);
	int (*power_off)(void);
};

#define AKM8973_MODE_MEASURE		0x00
#define AKM8973_MODE_POWERDOWN		0x03
#define AKM8973_MODE_EEPROM_READ	0x02

#define AKM8973_REG_ST			0xC0
#define AKM8973_REG_TMPS		0xC1
#define AKM8973_REG_H1X			0xC2
#define AKM8973_REG_H1Y			0xC3
#define AKM8973_REG_H1Z			0xC4
#define AKM8973_REG_MS1			0xE0
#define AKM8973_REG_HXDA		0xE1
#define AKM8973_REG_HYDA		0xE2
#define AKM8973_REG_HZDA		0xE3
#define AKM8973_REG_HXGA		0xE4
#define AKM8973_REG_HYGA		0xE5
#define AKM8973_REG_HZGA		0xE6
#define AKM8973_REG_TS1			0x5D
#define AKM8973_REG_EHXGA		0x66
#define AKM8973_REG_EHYGA		0x67
#define AKM8973_REG_EHZGA		0x68

#endif /* __KERNEL__ */

/* bit values for state flag */
#define AKM8973_MAG			1
#define AKM8973_TEMP			2

#define AKM8973_IO                           0xA1

#define AKM8973_IOCTL_GET_DELAY		_IOR(AKM8973_IO, 0x00, int)
#define AKM8973_IOCTL_SET_DELAY		_IOW(AKM8973_IO, 0x01, int)
#define AKM8973_IOCTL_GET_CALI		_IOR(AKM8973_IO, 0x02, char[3])
#define AKM8973_IOCTL_SET_CALI		_IOW(AKM8973_IO, 0x03, char[3])
#define AKM8973_IOCTL_GET_FLAG		_IOR(AKM8973_IO, 0x04, int)
#define AKM8973_IOCTL_SET_FLAG		_IOW(AKM8973_IO, 0x05, int)

#endif /* _LINUX_I2C_AKM8973_H */
