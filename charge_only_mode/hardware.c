/**************************************************************************************************
Copyright (c) 2008-2011, Motorola, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice, this list of conditions
  and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions
  and the following disclaimer in the documentation and/or other materials provided with the
  distribution.
- Neither the name of the Motorola, Inc. nor the names of its contributors may be used to endorse or
  promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**************************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

#include "events.h"
#include "hardware.h"
#define LOG_TAG "CHARGE_ONLY_MODE"
#include <cutils/log.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

/* Constants from frameworks/base/core/java/android/os/Power.java */

#define BRIGHTNESS_OFF 0
#define BRIGHTNESS_DIM 20
#define BRIGHTNESS_ON 255
#define BRIGHTNESS_LOW_BATTERY 10
#define LOW_BATTERY_THRESHOLD 10

/* Charging Low - red solid on */
#define CHARGING_LOW_ARGB 0xFFFF0000
#define CHARGING_LOW_ON 0
#define CHARGING_LOW_OFF 0

/* Charging - orange solid on */
#define CHARGING_ARGB 0xFFFFFF00
#define CHARGING_ON 1
#define CHARGING_OFF 1

/* Charging Full - green solid on */
#define CHARGING_FULL_ARGB 0xFF00FF00
#define CHARGING_FULL_ON 0
#define CHARGING_FULL_OFF 0

static int sys_get_int_parameter(const char *path, int missing_value)
{
    char s[1024];
    int r;
    int fd = open(path, O_RDONLY);
    if (fd < 0)
        return missing_value;
    r = read(fd, s, sizeof(s) - 1);
    close(fd);
    if (r < 0)
        return missing_value;
    s[r] = 0;
    return atoi(s);
}

static int sys_get_string_parameter(const char *path, char *s, int size)
{
    int r;
    int fd = open(path, O_RDONLY);
    s[0] = 0;
    if (fd < 0)
        return 0;
    r = read(fd, s, size - 1);
    close(fd);
    if (r >= 0)
        s[r] = 0;
    return r;
}

int is_plugged_into_ac()
{
    return sys_get_int_parameter("/sys/class/power_supply/ac/online", 0);
}

int is_plugged_into_usb()
{
    return sys_get_int_parameter("/sys/class/power_supply/usb/online", 0);
}

int is_battery_present()
{
    return sys_get_int_parameter("/sys/class/power_supply/battery/present", 0);
}

int is_charging()
{
    char status[128];
    if (sys_get_string_parameter("/sys/class/power_supply/battery/status", status, sizeof(status)) < 0)
        return 0;
    return (strncmp(status, "Charging", 8) == 0)? 1 : 0;

}

int is_unknown()
{
    char status[128];
    if (sys_get_string_parameter("/sys/class/power_supply/battery/status", status, sizeof(status)) < 0)
        return 0;
    return (strncmp(status, "Unknown", 7) == 0) ? 1 : 0;
}

int charge_level()
{
    int value;
    value = sys_get_int_parameter("/sys/class/power_supply/battery/charge_counter", 0);
    if (!value)
        value = sys_get_int_parameter("/sys/class/power_supply/battery/capacity", 0);
    if (value < 0) {
        value = 0;
    } else if (value > 100) {
        value = 100;
    }
    return value;
}

int voltage_level()
{
    return sys_get_int_parameter("/sys/class/power_supply/battery/voltage_now", 0);
}

void get_device_state(struct device_state *s)
{
    s->is_plugged_into_ac = is_plugged_into_ac();
    s->is_plugged_into_usb = is_plugged_into_usb();
    s->is_battery_present = is_battery_present();
    s->is_charging = is_charging();
    s->is_unknown = is_unknown();
    s->charge_level = charge_level();
    s->voltage_level = voltage_level();
}

const char* const RED_BRIGHTNESS_FILE = "/sys/class/leds/red/brightness";
const char* const GREEN_BRIGHTNESS_FILE = "/sys/class/leds/green/brightness";
const char* const BLINK_ENABLE_FILE = "/sys/class/leds/red/blink";

static int write_string(const char* file, const char* string, int len)
{
    int fd;
    ssize_t amt;

    fd = open(file, O_RDWR);
    if (fd < 0) {
    LOGD("%s open failed: %d\n", file, errno);
        return errno;
    }

    amt = write(fd, string, len);
    if (amt < 0) {
        LOGD("%s write failed: %d\n", file, errno);
    }

    close(fd);
    return amt >= 0 ? 0 : errno;
}

static int __set_led_state(unsigned color, int on, int off)
{
    int len;
    char buf[30];
    int alpha, red, green;
    int blink;

    LOGD("set_led_state color=%08X, on=%d, off=%d\n", color, on, off);

    /* alpha of 0 or color of 0 means off*/
    if ((color & 0xff000000) == 0 || (color & 0x00ffffff) == 0) {
        on = 0;
        off = 0;
    }

    if (on > 0 && off > 0)
    {
        blink = 1;
        /* set lights and then set blink - on */
        red = (color >> 16) & 0xFF;
        green = (color >> 8) & 0xFF;

        len = sprintf(buf, "%d", red);
        write_string(RED_BRIGHTNESS_FILE, buf, len);
        len = sprintf(buf, "%d", green);
        write_string(GREEN_BRIGHTNESS_FILE, buf, len);

        len = sprintf(buf, "%d", blink);
        write_string(BLINK_ENABLE_FILE, buf, len);
    }
    else
    {
        blink = 0;
        /* set blink and then set light - off */
        len = sprintf(buf, "%d", blink);
        write_string(BLINK_ENABLE_FILE, buf, len);

        red = (color >> 16) & 0xFF;
        green = (color >> 8) & 0xFF;

        len = sprintf(buf, "%d", red);
        write_string(RED_BRIGHTNESS_FILE, buf, len);
        len = sprintf(buf, "%d", green);
        write_string(GREEN_BRIGHTNESS_FILE, buf, len);
    }

    return 0;
}

void set_battery_led(struct device_state *s)
{
    if (s->charge_level < LOW_BATTERY_THRESHOLD)
        __set_led_state(CHARGING_LOW_ARGB,CHARGING_LOW_ON,CHARGING_LOW_OFF);
    else if (s->charge_level < 100)
        __set_led_state(CHARGING_ARGB,CHARGING_ON,CHARGING_OFF);
    else
        __set_led_state(CHARGING_FULL_ARGB,CHARGING_FULL_ON,CHARGING_FULL_OFF);

}

void set_brightness(float percent)
{
    int fd, n;
    char b[20];

    LOGD("set_brightness: %f\n", percent);
    fd = open("/sys/class/leds/lcd-backlight/brightness", O_RDWR);
    if (fd < 0)
        return;
    n = sprintf(b, "%d\n", (int)(255*percent));
    write(fd, b, n);
    close(fd);
}

