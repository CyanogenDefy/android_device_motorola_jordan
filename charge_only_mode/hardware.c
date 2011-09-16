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

#include <hardware/hardware.h>
#include <hardware/lights.h>

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

/* Charging Low - solid red */
#define CHARGING_LOW_ARGB 0xFFFF0000
/* Charging - solid orange */
#define CHARGING_ARGB 0xFFFFFF00
/* Charging Full - solid green */
#define CHARGING_FULL_ARGB 0xFF00FF00

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

static struct light_device_t *battery_light = NULL;
static struct light_device_t *screen_light = NULL;

static void set_color(struct light_device_t *light, int color)
{
    if (light != NULL) {
        struct light_state_t state;

        memset(&state, 0, sizeof(state));
        state.color = color;
        state.flashMode = LIGHT_FLASH_NONE;
        state.brightnessMode = BRIGHTNESS_MODE_USER;

        light->set_light(light, &state);
    }
}

void set_battery_led(struct device_state *s)
{
    if (s->charge_level < LOW_BATTERY_THRESHOLD) {
        set_color(battery_light, CHARGING_LOW_ARGB);
    } else if (s->charge_level < 100) {
        set_color(battery_light, CHARGING_ARGB);
    } else {
        set_color(battery_light, CHARGING_FULL_ARGB);
    }
}

void set_brightness(float percent)
{
    int brightness = (int) 255 * percent;
    int color = 0xff000000 | (brightness << 16) | (brightness << 8) | brightness;

    set_color(screen_light, color);
}

void led_init(void)
{
    hw_module_t *module;

    if (hw_get_module(LIGHTS_HARDWARE_MODULE_ID, (const hw_module_t **) &module) == 0) {
        if (module->methods->open(module, LIGHT_ID_BACKLIGHT, (hw_device_t **) &screen_light) != 0) {
            screen_light = NULL;
        }
        if (module->methods->open(module, LIGHT_ID_BATTERY, (hw_device_t **) &battery_light) != 0) {
            battery_light = NULL;
        }
    }
}

void led_uninit(void)
{
    set_color(screen_light, 0xffffffff);
}
