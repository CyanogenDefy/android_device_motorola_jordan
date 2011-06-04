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

#include <fcntl.h>
#include <errno.h>
#include <math.h>
#include <poll.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/select.h>

#include <cutils/log.h>

#include "kernel/akm8973_akmd.h"

#include "SensorAK8973.h"

/*****************************************************************************/

SensorAK8973::SensorAK8973() : SensorBase(AK8973_DEVICE_NAME, "compass"),
    mEnabled(0),
    mHasPendingEvent(false),
    mPendingMask(0),
    mInputReader(32)
{
    memset(mPendingEvents, 0, sizeof(mPendingEvents));

    mPendingEvents[Accelerometer].version = sizeof(sensors_event_t);
    mPendingEvents[Accelerometer].sensor = SENSOR_TYPE_ACCELEROMETER;
    mPendingEvents[Accelerometer].type = SENSOR_TYPE_ACCELEROMETER;
    mPendingEvents[Accelerometer].acceleration.status = SENSOR_STATUS_ACCURACY_HIGH;

    mPendingEvents[MagneticField].version = sizeof(sensors_event_t);
    mPendingEvents[MagneticField].sensor = SENSOR_TYPE_MAGNETIC_FIELD;
    mPendingEvents[MagneticField].type = SENSOR_TYPE_MAGNETIC_FIELD;
    mPendingEvents[MagneticField].magnetic.status = SENSOR_STATUS_ACCURACY_HIGH;

    mPendingEvents[Orientation].version = sizeof(sensors_event_t);
    mPendingEvents[Orientation].sensor = SENSOR_TYPE_ORIENTATION;
    mPendingEvents[Orientation].type = SENSOR_TYPE_ORIENTATION;
    mPendingEvents[Orientation].orientation.status = SENSOR_STATUS_ACCURACY_HIGH;

    mPendingEvents[Temperature].version = sizeof(sensors_event_t);
    mPendingEvents[Temperature].sensor = SENSOR_TYPE_TEMPERATURE;
    mPendingEvents[Temperature].type = SENSOR_TYPE_TEMPERATURE;

    for (int i = 0 ; i < numSensors; i++)
        mDelays[i] = AK8973_DEFAULT_DELAY;
}

SensorAK8973::~SensorAK8973()
{
}

int SensorAK8973::enable(int32_t handle, int en)
{
    int what = -1;
    switch (handle)
    {
        case SENSOR_TYPE_ACCELEROMETER:  what = Accelerometer; break;
        case SENSOR_TYPE_MAGNETIC_FIELD: what = MagneticField; break;
        case SENSOR_TYPE_ORIENTATION:    what = Orientation;   break;
        case SENSOR_TYPE_TEMPERATURE:    what = Temperature;   break;
    }

    if (uint32_t(what) >= numSensors)
        return -EINVAL;

    int newState = en ? 1 : 0;
    int err = 0;

    if ((uint32_t(newState) << what) != (mEnabled & (1 << what)))
    {
        if (!mEnabled)
            open_device();

        int cmd;
        switch (what)
        {
            case Accelerometer: cmd = ECS_IOCTL_APP_SET_AFLAG;  break;
            case MagneticField: cmd = ECS_IOCTL_APP_SET_MVFLAG; break;
            case Orientation:   cmd = ECS_IOCTL_APP_SET_MFLAG;  break;
            case Temperature:   cmd = ECS_IOCTL_APP_SET_TFLAG;  break;
        }

        short flags = newState;

        err = ioctl(dev_fd, cmd, &flags);
        err = err < 0 ? -errno : 0;

        LOGE_IF(err, "ECS_IOCTL_APP_SET_XXX failed (%s)", strerror(-err));

        if (!err)
        {
            mEnabled &= ~(1 << what);
            mEnabled |= (uint32_t(flags) << what);
            err = update_delay();
        }

        if (!mEnabled)
            close_device();

        if (what == Temperature && newState)
            mHasPendingEvent = true;
    }

    return err;
}

int SensorAK8973::setDelay(int32_t handle, int64_t ns)
{
    int what = -1;
    switch (handle)
    {
        case SENSOR_TYPE_ACCELEROMETER:  what = Accelerometer; break;
        case SENSOR_TYPE_MAGNETIC_FIELD: what = MagneticField; break;
        case SENSOR_TYPE_ORIENTATION:    what = Orientation;   break;
        case SENSOR_TYPE_TEMPERATURE:    what = Temperature;   break;
    }

    if (uint32_t(what) >= numSensors)
        return -EINVAL;

    if (ns < 0)
        return -EINVAL;

    mDelays[what] = ns;
    return update_delay();
}

int SensorAK8973::update_delay()
{
    if (mEnabled)
    {
        uint64_t wanted = -1LLU;

        for (int i = 0 ; i < numSensors; i++)
        {
            if (mEnabled & (1 << i))
            {
                uint64_t ns = mDelays[i];
                wanted = wanted < ns ? wanted : ns;
            }
        }

        short delay = int64_t(wanted) / 1000000;

        if (ioctl(dev_fd, ECS_IOCTL_APP_SET_DELAY, &delay))
            return -errno;
    }

    return 0;
}

bool SensorAK8973::hasPendingEvents() const
{
    return mHasPendingEvent;
}

int SensorAK8973::readEvents(sensors_event_t* data, int count)
{
    if (count < 1)
        return -EINVAL;

    if (mHasPendingEvent)
    {
        mHasPendingEvent = false;
        mPendingEvents[Temperature].timestamp = getTimestamp();
        *data = mPendingEvents[Temperature];
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
        if (type == EV_ABS)
        {
            processEvent(event->code, event->value);
            mInputReader.next();
        }
        else if (type == EV_SYN)
        {
            int64_t time = timevalToNano(event->time);
            for (int j=0 ; count && mPendingMask && j<numSensors ; j++)
            {
                if (mPendingMask & (1<<j))
                {
                    mPendingMask &= ~(1<<j);
                    mPendingEvents[j].timestamp = time;
                    if (mEnabled & (1<<j))
                    {
                        *data++ = mPendingEvents[j];
                        count--;
                        numEventReceived++;
                    }
                }
            }
            if (!mPendingMask)
                mInputReader.next();
        }
        else
        {
            LOGE("SensorAK8973: unknown event (type=%d, code=%d, value=%d)", type, event->code, event->value);
            mInputReader.next();
        }
    }

    return numEventReceived;
}

void SensorAK8973::processEvent(int code, int value)
{
    switch (code)
    {
        case ABS_X:
            mPendingMask |= 1 << Accelerometer;
            mPendingEvents[Accelerometer].acceleration.x = value * AK8973_CONVERT_A_X;
            break;
        case ABS_Y:
            mPendingMask |= 1 << Accelerometer;
            mPendingEvents[Accelerometer].acceleration.y = value * AK8973_CONVERT_A_Y;
            break;
        case ABS_Z:
            mPendingMask |= 1 << Accelerometer;
            mPendingEvents[Accelerometer].acceleration.z = value * AK8973_CONVERT_A_Z;
            break;
        case ABS_WHEEL:
            mPendingMask |= 1 << Accelerometer;
            mPendingEvents[Accelerometer].acceleration.status = uint8_t(value & AK8973_SENSOR_STATE_MASK);
            break;

        case ABS_HAT0X:
            mPendingMask |= 1 << MagneticField;
            mPendingEvents[MagneticField].magnetic.x = value * AK8973_CONVERT_M_X;
            break;
        case ABS_HAT0Y:
            mPendingMask |= 1 << MagneticField;
            mPendingEvents[MagneticField].magnetic.y = value * AK8973_CONVERT_M_Y;
            break;
        case ABS_BRAKE:
            mPendingMask |= 1 << MagneticField;
            mPendingEvents[MagneticField].magnetic.z = value * AK8973_CONVERT_M_Z;
            break;

        case ABS_RX:
            mPendingMask |= 1 << Orientation;
            mPendingEvents[Orientation].orientation.azimuth = value * AK8973_CONVERT_O_Y;
            break;
        case ABS_RY:
            mPendingMask |= 1 << Orientation;
            mPendingEvents[Orientation].orientation.pitch = value * AK8973_CONVERT_O_P;
            break;
        case ABS_RZ:
            mPendingMask |= 1 << Orientation;
            mPendingEvents[Orientation].orientation.roll = value * AK8973_CONVERT_O_R;
            break;
        case ABS_RUDDER:
            mPendingMask |= 1 << Orientation;
            mPendingEvents[Orientation].orientation.status = uint8_t(value & AK8973_SENSOR_STATE_MASK);
            break;

        case ABS_THROTTLE:
            mPendingMask |= 1 << Temperature;
            mPendingEvents[Temperature].temperature = value;
    }
}
