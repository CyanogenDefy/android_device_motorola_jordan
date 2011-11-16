/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <linux/input.h>

#include "recovery_ui.h"
#include "common.h"
#include "extendedcommands.h"

char* MENU_HEADERS[] = { NULL };

char* MENU_ITEMS[] = { "Reboot system now",
                       "Apply update.zip from sdcard",
                       "Wipe data/factory reset",
                       "Wipe cache partition",
                       "Install zip from sdcard",
                       "Backup and restore",
                       "Mounts and storage",
                       "Advanced",
                       "Power off",
                       NULL };

int device_recovery_start() {
    return 0;
}

int device_toggle_display(volatile char* key_pressed, int key_code) {

    int alt = key_pressed[KEY_VOLUMEUP];
    if (alt && (key_code == KEY_END))
        return 1;
    return get_allow_toggle_display() && (key_pressed[KEY_VOLUMEUP] && (key_code == KEY_END));

}

int device_reboot_now(volatile char* key_pressed, int key_code) {
    return key_pressed[KEY_VOLUMEDOWN] && (key_code == KEY_END); 
}

int device_handle_key(int key_code, int visible) {
    if (visible) {
        switch (key_code) {
            case KEY_CAPSLOCK:
            case 53:
            case KEY_VOLUMEDOWN:
                return HIGHLIGHT_DOWN;

            case KEY_LEFTSHIFT:
            case 51:
            case KEY_VOLUMEUP:
                return HIGHLIGHT_UP;

            case 139:
            case KEY_END:
                return SELECT_ITEM;

            case KEY_LEFTBRACE:
            case 31:
            case BTN_MOUSE:
            case KEY_CAMERA:
            case KEY_F21:
            case KEY_SEND:
                return SELECT_ITEM;
            
            case KEY_BACKSPACE:
            case KEY_BACK:
                if (!get_allow_toggle_display())
                    return GO_BACK;
        }
    }

    return NO_ACTION;
}

int device_perform_action(int which) {
    return which;
}

int device_wipe_data() {
    return 0;
}
