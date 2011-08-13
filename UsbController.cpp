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
#include <errno.h>
#include <fcntl.h>


#include <netinet/in.h>
#include <arpa/inet.h>

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
    char value[100];
    snprintf(value, sizeof(value), "/system/bin/setprop sys.usb.tethered %s", (enable ? "1" : "0"));
    system(value);
    return 0;
}

bool UsbController::isRNDISStarted() {
    FILE* pipe = popen("/system/bin/getprop sys.usb.tethered 0", "r");
    if (!pipe) {
        LOGD("ERROR reading state");
        return 0;
    }
    char buffer[2];
    while(fread(buffer, sizeof buffer, 2, pipe) == 0){};
    pclose(pipe);
    LOGD("Tethering state: %d",atoi(buffer));
    return atoi(buffer);
}
