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

#include "alarm.h"
#include "events.h"
#include "hardware.h"
#include "screen.h"

#include <sys/reboot.h>
#include <sys/time.h>
#define LOG_TAG "CHARGE_ONLY_MODE"
#include <utils/Log.h>

static int quit = 0;
static int shutdown = 0;
static int powerup = 0;

void power_event(int update_leds);

#define ANIMATION_TIMEOUT (1000 / 2)
#define POWERUP_VOLTAGE 3470000

/* This drives the bubbling animation */
void animation_alarm(void *_)
{
    alarm_set_relative(animation_alarm, NULL, ANIMATION_TIMEOUT);
    power_event(0);
}

void screen_brightness_animation_alarm2(void *_)
{
    set_brightness(0.0);

    alarm_cancel(animation_alarm);

    if (shutdown)
    {
        LOGD("power off after 5-10 display cycle!\n");
        reboot(RB_POWER_OFF);
    }
    display_blank();
}

void screen_brightness_animation_alarm1(void *_)
{
    set_brightness(0.4);
    /* Bright for 10s */
    alarm_set_relative(screen_brightness_animation_alarm2, NULL, 10000);
}

void screen_brightness_animation_start(void)
{
    display_unblank();

    set_brightness(0.8);
    alarm_set_relative(screen_brightness_animation_alarm1, NULL, 5000);
    alarm_set_relative(animation_alarm, NULL, ANIMATION_TIMEOUT);
}

void power_key_alarm(void *_)
{
    /* Delete the timers before reboot the phone. */
    alarm_cancel(screen_brightness_animation_alarm2);
    alarm_cancel(screen_brightness_animation_alarm1);
    alarm_cancel(animation_alarm);

    /* Set powerup reason outof-charge-only to MBM. */
    int ret = __reboot(LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2, LINUX_REBOOT_CMD_RESTART2, "outofcharge");
    LOGD("reboot to outofcharge!\n");
    if(ret < 0) {
        LOGD("reboot fail!\n");
    }
    else {
        quit = 1;
    }
}

void power_event(int update_leds)
{
    struct device_state state;

    get_device_state(&state);

    if (state.voltage_level >= POWERUP_VOLTAGE) {
        powerup = 1;
        LOGD("voltage ok for PU %d\n", state.voltage_level);
    }
    screen_update(state.charge_level,
            state.is_unknown || !state.is_battery_present);
    if (update_leds)
        set_battery_led(&state);

    /* When the charger is unplugged the device shall shutdown at once. */
    if (!shutdown && !state.is_plugged_into_ac && !state.is_plugged_into_usb) {
        shutdown = 1;
        alarm_cancel(screen_brightness_animation_alarm2);
        alarm_cancel(screen_brightness_animation_alarm1);
        screen_brightness_animation_alarm2(NULL);
    }
}

void update_screen_on_wakeup_key(void)
{
    alarm_cancel(screen_brightness_animation_alarm2);
    alarm_cancel(animation_alarm);
    if (alarm_cancel(screen_brightness_animation_alarm1))
        /* This handles shutdown properly */
        screen_brightness_animation_alarm2(NULL);
    else
        screen_brightness_animation_start();
}

void update_screen_on_wakeup_key2(void)
{
    alarm_cancel(screen_brightness_animation_alarm2);
    alarm_cancel(screen_brightness_animation_alarm1);
    alarm_cancel(animation_alarm);
    screen_brightness_animation_start();
}

int main()
{
    struct device_state old_state;
    get_device_state(&old_state);

    if (screen_init() < 0)
        goto err1;
    ev_init();

    sleep(3);

    /* Set battery LED, initialize image, screen brightness */
    power_event(1);
    screen_brightness_animation_start();

    while (!quit) {
        int r, delay = alarm_get_time_until_next();
        if (delay < 1) {
            alarm_process();
            continue;
        }

        r = ev_get(delay);

        /* Press below keys will wake the display and repeat the
           display cycle:
           Power key, Volume up/down key, Camera key.
           Long press Power key will reboot the device. */
        switch (r) {
        /* Power key */
        case EVENT_POWER_KEY_DOWN:
            if (powerup)
            alarm_set_relative(power_key_alarm, NULL, 1000);
            break;
        case EVENT_POWER_KEY_UP:
            alarm_cancel(power_key_alarm);
            update_screen_on_wakeup_key();
            break;
        /* Other keys */
        case EVENT_VOLUMEDOWN_KEY_DOWN:
            update_screen_on_wakeup_key2();
            break;
        case EVENT_VOLUMEUP_KEY_DOWN:
            update_screen_on_wakeup_key2();
            break;
        case EVENT_CAMERA_KEY_DOWN:
            update_screen_on_wakeup_key2();
            break;
        /* Battery events */
        case EVENT_BATTERY:
            power_event(1);
            break;
        /* Others */
        case EVENT_QUIT:
            quit = 1;
            break;
        default:
            break;
        }
    }

    ev_exit();
    screen_uninit();

    set_brightness(1.0);

    return 0;

err1:
    return -1;

}
