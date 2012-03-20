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
 
#ifndef ANDROID_AKM_SENSOR_H
#define ANDROID_AKM_SENSOR_H

#include <stdint.h>
#include <errno.h>
#include <sys/cdefs.h>
#include <sys/types.h>


#include "nusensors.h"
#include "SensorBase.h"
#include "InputEventReader.h"

/*****************************************************************************/

struct input_event;

class SensorAK8973 : public SensorBase
{
public:
    SensorAK8973();
    virtual ~SensorAK8973();

    enum
    {
        Accelerometer   = 0,
        MagneticField   = 1,
        Orientation     = 2,
        Temperature     = 3,
        numSensors
    };

    virtual int setDelay(int32_t handle, int64_t ns);
    virtual int enable(int32_t handle, int enabled);
    virtual bool hasPendingEvents() const;
    virtual int readEvents(sensors_event_t* data, int count);
    void processEvent(int code, int value);

private:
    int updateDelay();

    uint32_t mEnabled;
    bool mHasPendingEvent;
    uint32_t mPendingMask;
    InputEventCircularReader mInputReader;
    sensors_event_t mPendingEvents[numSensors];
    uint64_t mDelays[numSensors];
};

/*****************************************************************************/

#endif  // ANDROID_AKM_SENSOR_H
