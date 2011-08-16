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

#define LOG_NDEBUG 0
#define LOG_TAG "UsbController"
#include <cutils/log.h>
#include <cutils/properties.h>

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
    const char *state = enable ? "1" : "0";
    char buffer[128];

    property_set("sys.usb.tethered", state);
    snprintf(buffer, sizeof(buffer),
             "/system/bin/am broadcast -a com.motorola.intent.action.USB_TETHERING_TOGGLED --ei state %s",
             state);
    system(buffer);
    return 0;
}

bool UsbController::isRNDISStarted() {
    char value[PROPERTY_VALUE_MAX];
    if (property_get("sys.usb.tethered", value, "0") <= 0) {
        return false;
    }
    LOGD("Tethering state: %s", value);
    return atoi(value) != 0;
}
