/*
 * Copyright (C) 2008 The Android Open Source Project
 * Copyright (C) 2011 Sorin P. <sorin@hypermagik.com>
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
 
#ifndef ANDROID_ISL29030_SENSOR_H
#define ANDROID_ISL29030_SENSOR_H

#include <stdint.h>
#include <errno.h>
#include <sys/cdefs.h>
#include <sys/types.h>


#include "nusensors.h"
#include "SensorBase.h"
#include "InputEventReader.h"

/*****************************************************************************/

struct input_event;

/*****************************************************************************/

class SensorISL29030P : public SensorBase
{
public:
	SensorISL29030P();
    virtual ~SensorISL29030P();

    virtual int enable(int32_t handle, int enabled);
    virtual int readEvents(sensors_event_t* data, int count);
    void processEvent(int code, int value);

protected:
	int mEnabled;
    InputEventCircularReader mInputReader;
    sensors_event_t mPendingEvent;

    int isEnabled();
};

/*****************************************************************************/

class SensorISL29030L : public SensorBase
{
public:
	SensorISL29030L();
    virtual ~SensorISL29030L();

    virtual int enable(int32_t handle, int enabled);
    virtual int readEvents(sensors_event_t* data, int count);
    void processEvent(int code, int value);

protected:
	int mEnabled;
    InputEventCircularReader mInputReader;
    sensors_event_t mPendingEvent;
};

/*****************************************************************************/

#endif  // ANDROID_ISL29030_SENSOR_H
