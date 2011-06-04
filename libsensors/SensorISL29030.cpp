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

SensorISL29030P::SensorISL29030P()
  : SensorBase(ISL29030_DEVICE_NAME, "proximity"),
    mEnabled(0),
    mInputReader(32)
{
    memset(&mPendingEvent, 0, sizeof(mPendingEvent));

    mPendingEvent.version = sizeof(sensors_event_t);
    mPendingEvent.sensor = SENSOR_TYPE_PROXIMITY;
    mPendingEvent.type = SENSOR_TYPE_PROXIMITY;

    open_device();

    mEnabled = isEnabled();

    if (!mEnabled)
        close_device();
}

SensorISL29030P::~SensorISL29030P()
{
}

int SensorISL29030P::enable(int32_t handle, int en)
{
    int err = 0;

    char newState = en ? 1 : 0;
    if (newState == mEnabled)
        return err;

    if (!mEnabled)
        open_device();

    err = ioctl(dev_fd, ISL29030_IOCTL_SET_ENABLE, &newState);
    err = err < 0 ? -errno : 0;

    LOGE_IF(err, "SensorISL29030P: ISL29030_IOCTL_SET_ENABLE failed (%s)", strerror(-err));

    if (!err || !newState)
        mEnabled = newState;

    if (!mEnabled)
        close_device();

    return err;
}

int SensorISL29030P::readEvents(sensors_event_t* data, int count)
{
    if (count < 1)
        return -EINVAL;

    ssize_t n = mInputReader.fill(data_fd);
    if (n < 0)
        return n;

    int numEventReceived = 0;
    input_event const* event;

    while (count && mInputReader.readEvent(&event))
    {
        int type = event->type;
        if (type == EV_ABS)
        {
            processEvent(event->code, event->value);
        }
        else if (type == EV_SYN)
        {
            mPendingEvent.timestamp = timevalToNano(event->time);
            *data++ = mPendingEvent;
            count--;
            numEventReceived++;
        }
        else
        {
            LOGE("SensorISL29030P: unknown event (type=%d, code=%d, value=%d)", type, event->code, event->value);
        }
        mInputReader.next();
    }

    return numEventReceived;
}

void SensorISL29030P::processEvent(int code, int value)
{
    switch (code)
    {
        case ABS_DISTANCE:
            mPendingEvent.distance = (value == PROXIMITY_NEAR ? 0 : 100);
            break;
    }
}

int SensorISL29030P::isEnabled()
{
    int err = 0;
    char enabled = 0;

    err = ioctl(dev_fd, ISL29030_IOCTL_GET_ENABLE, &enabled);
    err = err < 0 ? -errno : 0;

    LOGE_IF(err, "SensorISL29030P: ISL29030_IOCTL_GET_ENABLE failed (%s)", strerror(-err));

    return enabled;
}

/*****************************************************************************/

SensorISL29030L::SensorISL29030L()
  : SensorBase(ISL29030_DEVICE_NAME, "als"),
    mEnabled(0),
    mInputReader(32)
{
    memset(&mPendingEvent, 0, sizeof(mPendingEvent));

    mPendingEvent.version = sizeof(sensors_event_t);
    mPendingEvent.sensor = SENSOR_TYPE_LIGHT;
    mPendingEvent.type = SENSOR_TYPE_LIGHT;
}

SensorISL29030L::~SensorISL29030L()
{
}

int SensorISL29030L::enable(int32_t handle, int en)
{
    mEnabled = en ? 1 : 0;

    return 0;
}

int SensorISL29030L::readEvents(sensors_event_t* data, int count)
{
    if (count < 1)
        return -EINVAL;

    ssize_t n = mInputReader.fill(data_fd);
    if (n < 0)
        return n;

    int numEventReceived = 0;
    input_event const* event;

    while (count && mInputReader.readEvent(&event))
    {
        int type = event->type;
        if (type == EV_LED)
        {
            processEvent(event->code, event->value);
        }
        else if (type == EV_SYN)
        {
            mPendingEvent.timestamp = timevalToNano(event->time);
            *data++ = mPendingEvent;
            count--;
            numEventReceived++;
        }
        else
        {
            LOGE("SensorISL29030L: unknown event (type=%d, code=%d, value=%d)", type, event->code, event->value);
        }
        mInputReader.next();
    }

    return numEventReceived;
}

void SensorISL29030L::processEvent(int code, int value)
{
    switch (code)
    {
        case LED_MISC:
            mPendingEvent.light = value;
            break;
    }
}

/*****************************************************************************/
