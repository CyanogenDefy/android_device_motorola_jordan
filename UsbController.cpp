/*
 * Copyright (C) 2008 The Android Open Source Project
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

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

#define LOG_NDEBUG 0
#define LOG_TAG "UsbController"
#include <cutils/log.h>

#include "UsbController.h"


UsbController::UsbController() {
}

UsbController::~UsbController() {
}

int UsbController::startRNDIS() {
    LOGD("Usb RNDIS start");
    return enableRNDIS(true);
}

int UsbController::stopRNDIS() {
    LOGD("Usb RNDIS stop");
    return enableRNDIS(false);
}

int UsbController::enableRNDIS(bool enable) {
    char buffer[128];

    snprintf(buffer, sizeof(buffer),
             "/system/bin/am broadcast -a com.motorola.intent.action.USB_TETHERING_TOGGLED --ei state %d",
             enable ? 1 : 0);
    system(buffer);
    return 0;
}

bool UsbController::isRNDISStarted() {
    bool rndisActive = false;
    FILE *stateFile = fopen("/tmp/usbd_current_state", "r");

    if (stateFile != NULL) {
        char buffer[128];

        memset(buffer, 0, sizeof(buffer));
        if (fread(buffer, 1, sizeof(buffer), stateFile) > 0) {
            LOGD("Got USBD state %s", buffer);
            rndisActive = strstr(buffer, "rndis") != NULL;
        } else {
            LOGD("Could not read USBD state file (errno %d)", errno);
        }

        fclose(stateFile);
    }

    return rndisActive;
}
