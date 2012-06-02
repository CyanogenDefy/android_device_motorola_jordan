/*
 * Copyright (C) 2011-2012 CyanogenDefy
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

#include <linux/leds.h>
#include <linux/leds-ld-cpcap.h>
#include <linux/platform_device.h>
#include <linux/spi/cpcap.h>
#include <linux/spi/cpcap-regbits.h>
#include <linux/sysfs.h>

#include "../symsearch/symsearch.h"

#define SYS_LD_USBLED_DEV "usb"
#define LD_USBLED_DEV "ld-usb"

struct usb_led_data {
	struct cpcap_device *cpcap;
	struct led_classdev ld_cpcap_usbled_class_dev;
};

SYMSEARCH_DECLARE_FUNCTION_STATIC(int, _cpcap_device_register,struct platform_device *pdev);
SYMSEARCH_DECLARE_FUNCTION_STATIC(int, _cpcap_device_unregister,struct platform_device *pdev);
SYMSEARCH_DECLARE_FUNCTION_STATIC(int, _cpcap_regacc_write, struct cpcap_device *cpcap, enum cpcap_reg reg, unsigned short value, unsigned short mask);
SYMSEARCH_DECLARE_FUNCTION_STATIC(int, _cpcap_regacc_read, struct cpcap_device *cpcap, enum cpcap_reg reg, unsigned short *value_ptr);

static void ld_cpcap_usbled_release(struct device *dev) {}

static struct platform_device cpcap_usbled_device = {
	.name   = "cpcap_usbled",
	.id     = -1,
	.dev.platform_data  = NULL,
	.dev.release = ld_cpcap_usbled_release,
};

static void ld_cpcap_usbled_store(struct led_classdev *led_cdev,
				enum led_brightness value)
{
	int cpcap_status = 0;
	struct usb_led_data *cpusb_data = container_of(
		led_cdev,
		struct usb_led_data,
		ld_cpcap_usbled_class_dev
	);

	SYMSEARCH_BIND_FUNCTION_TO_NORET(usbled, cpcap_regacc_write, _cpcap_regacc_write);

	if (value != LED_OFF) {
		cpcap_status = _cpcap_regacc_write(cpusb_data->cpcap,
			CPCAP_REG_CRM, CPCAP_BIT_CHRG_LED_EN,
			CPCAP_BIT_CHRG_LED_EN);
	} else {
		cpcap_status = _cpcap_regacc_write(cpusb_data->cpcap,
			CPCAP_REG_CRM, 0,
			CPCAP_BIT_CHRG_LED_EN);
	}
}

static int ld_cpcap_usbled_probe(struct platform_device *pdev)
{
	int ret;
	struct usb_led_data *info;
	unsigned short value=0;

	SYMSEARCH_BIND_FUNCTION_TO(usbled, cpcap_regacc_read, _cpcap_regacc_read);

	if (pdev == NULL) {
		pr_err("%s: platform data required\n", __func__);
		return -ENODEV;
	}
	info = kzalloc(sizeof(struct usb_led_data), GFP_KERNEL);
	if (info == NULL) {
		ret = -ENOMEM;
		return ret;
	}

	info->cpcap = pdev->dev.platform_data;
	platform_set_drvdata(pdev, info);

	ret = _cpcap_regacc_read(info->cpcap, CPCAP_REG_CRM, &value);
	if (ret < 0) {
		pr_err("%s: unable to read CPCAP reg, error %d\n", __func__, ret);
		goto err_free;
	}
	value &= CPCAP_BIT_CHRG_LED_EN;

	info->ld_cpcap_usbled_class_dev.name = SYS_LD_USBLED_DEV;
	info->ld_cpcap_usbled_class_dev.brightness_set = ld_cpcap_usbled_store;
	info->ld_cpcap_usbled_class_dev.max_brightness = 1;
	info->ld_cpcap_usbled_class_dev.brightness = (value != 0);

	ret = led_classdev_register(&pdev->dev, &info->ld_cpcap_usbled_class_dev);
	if (ret < 0) {
		pr_err("%s: class register error %d\n", __func__, ret);
		goto err_free;
	} else {
		/* update sysfs attributes to allow changes by all */
		struct device *dev = info->ld_cpcap_usbled_class_dev.dev;
		if (dev) {
			struct attribute attr = { .name="brightness" };
			ret = sysfs_chmod_file(&dev->kobj, &attr, 0666);
		}
	}
	return ret;
err_free:
	kfree(info);
	return ret;
}

static int ld_cpcap_usbled_remove(struct platform_device *pdev)
{
	struct usb_led_data *info = platform_get_drvdata(pdev);
	if (info) {
		led_classdev_unregister(&info->ld_cpcap_usbled_class_dev);
		info->cpcap = NULL;
		kfree(info);
	}
	return 0;
}

static int cpcap_usbled_unregister(void)
{
	int ret=0;

	SYMSEARCH_BIND_FUNCTION_TO(usbled, cpcap_device_unregister, _cpcap_device_unregister);
	ret = _cpcap_device_unregister(&cpcap_usbled_device);

	return ret;
}

static struct platform_driver ld_cpcap_usbled_driver = {
	.probe = ld_cpcap_usbled_probe,
	.remove = ld_cpcap_usbled_remove,
	.driver = {
		.name = "cpcap_usbled",
		.owner = THIS_MODULE,
	},
};

static int __init ld_cpcap_usbled_init(void)
{
	int ret;

	SYMSEARCH_BIND_FUNCTION_TO(usbled, cpcap_device_register, _cpcap_device_register);

	ret = cpcap_driver_register(&ld_cpcap_usbled_driver);
	if (ret < 0) {
		pr_err("%s: driver register error %d\n", __func__, ret);
		return ret;
	}
	ret = _cpcap_device_register(&cpcap_usbled_device);
	if (ret < 0) {
		pr_err("%s: device register error %d\n", __func__, ret);
		return ret;
	}
	return ret;
}

static void __exit ld_cpcap_usbled_exit(void)
{
	cpcap_usbled_unregister();
	platform_driver_unregister(&ld_cpcap_usbled_driver);
}

module_init(ld_cpcap_usbled_init);
module_exit(ld_cpcap_usbled_exit);

MODULE_DESCRIPTION("USB Charge LED Driver");
MODULE_AUTHOR("Tanguy Pruvot, CyanogenDefy");
MODULE_VERSION("1.2");
MODULE_LICENSE("GPL");
