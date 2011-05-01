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

#include <fcntl.h>
#include <errno.h>
#include <math.h>
#include <poll.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/select.h>

#include <cutils/log.h>

#include "kernel/isl29030.h"

#include "SensorISL29030.h"

/*****************************************************************************/

int SensorISL29030::msEnabledSensors = 0;

SensorISL29030::SensorISL29030(const char* data_name, int sensor_type)
  : SensorBase(ISL29030_DEVICE_NAME, data_name),
    mSensorType(sensor_type),
    mEnabled(0),
    mHasPendingEvent(false),
    mInputReader(32)
{
    memset(&mPendingEvent, 0, sizeof(mPendingEvent));

    mPendingEvent.version = sizeof(sensors_event_t);
    mPendingEvent.sensor = mSensorType;
    mPendingEvent.type = mSensorType;

    mEnabled = isEnabled();
    setSensorEnabled(mSensorType, mEnabled);
}

SensorISL29030::~SensorISL29030()
{
}

int SensorISL29030::enable(int32_t handle, int en)
{
    int err = 0;

    int newState = en ? 1 : 0;
    if (newState == mEnabled)
        return err;
    
    unsigned oldEnabled = getEnabledSensors();

    mEnabled = newState;
    setSensorEnabled(mSensorType, mEnabled);

    unsigned newEnabled = getEnabledSensors();

    // Enable the device if at least one sensor was enabled
    // and disable it if all sensors were disabled.
    if ((!oldEnabled && newEnabled) || (oldEnabled && !newEnabled))
    {
        char enabled = newEnabled ? 1 : 0;

        open_device();

        err = ioctl(dev_fd, ISL29030_IOCTL_SET_ENABLE, &enabled);
        err = err < 0 ? -errno : 0;

        LOGE_IF(err, "SensorISL29030: ISL29030_IOCTL_SET_ENABLE failed (%s)", strerror(-err));

        close_device();
    }

    onEnableChanged();

    return err;
}

int SensorISL29030::setDelay(int32_t handle, int64_t ns)
{
    return 0;
}

bool SensorISL29030::hasPendingEvents() const
{
    return mHasPendingEvent;
}

int SensorISL29030::readEvents(sensors_event_t* data, int count)
{
    if (count < 1)
        return -EINVAL;

    if (mHasPendingEvent)
    {
        mHasPendingEvent = false;
        mPendingEvent.timestamp = getTimestamp();
        *data = mPendingEvent;
        return 1;
    }

    ssize_t n = mInputReader.fill(data_fd);
    if (n < 0)
        return n;

    int numEventReceived = 0;
    input_event const* event;

    while (count && mInputReader.readEvent(&event))
    {
        int type = event->type;
        if (type == EV_ABS || type == EV_LED)
        {
            processEvent(event->code, event->value);
        }
        else if (type == EV_SYN)
        {
            mPendingEvent.timestamp = timevalToNano(event->time);

            if (mEnabled)
            {
                *data++ = mPendingEvent;
                count--;
                numEventReceived++;
            }
        }
        else
        {
            LOGE("SensorISL29030: unknown event (type=%d, code=%d, value=%d)", type, event->code, event->value);
        }
        mInputReader.next();
    }

    return numEventReceived;
}

void SensorISL29030::processEvent(int code, int value)
{
    switch (code)
    {
        case ABS_DISTANCE:
            mPendingEvent.distance = (value == PROXIMITY_NEAR ? 0 : value);
            break;

        case LED_MISC:
            mPendingEvent.light = value;
            break;
    }
}

int SensorISL29030::isEnabled()
{
    int err = 0;
    char enabled = 0;

    open_device();

    err = ioctl(dev_fd, ISL29030_IOCTL_GET_ENABLE, &enabled);
    err = err < 0 ? -errno : 0;

    LOGE_IF(err, "SensorISL29030: ISL29030_IOCTL_GET_ENABLE failed (%s)", strerror(-err));

    close_device();

    return enabled;
}

/*****************************************************************************/

SensorISL29030P::SensorISL29030P() : SensorISL29030("proximity", SENSOR_TYPE_PROXIMITY)
{
}

SensorISL29030P::~SensorISL29030P()
{
}

void SensorISL29030P::onEnableChanged()
{
    // When enabled, force a read that will return the last valid result.
    if (mEnabled && mPendingEvent.timestamp != 0)
        mHasPendingEvent = true;
}

/*****************************************************************************/

SensorISL29030L::SensorISL29030L() : SensorISL29030("als", SENSOR_TYPE_LIGHT)
{
}

SensorISL29030L::~SensorISL29030L()
{
}

/*****************************************************************************/
