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

#include <hardware/sensors.h>
#include <fcntl.h>
#include <errno.h>
#include <dirent.h>
#include <math.h>

#include <poll.h>
#include <pthread.h>

#include <linux/input.h>

#include <cutils/atomic.h>
#include <cutils/log.h>

#include "nusensors.h"

#include "SensorKXTF9.h"
#include "SensorAK8973.h"
#include "SensorISL29030.h"

/*****************************************************************************/

struct sensors_poll_context_t
{
    struct sensors_poll_device_t device; // must be first

    sensors_poll_context_t();
    ~sensors_poll_context_t();

    int activate(int handle, int enabled);
    int setDelay(int handle, int64_t ns);
    int pollEvents(sensors_event_t* data, int count);

private:
    enum {
        KXTF9     = 0,
        AK8973    = 1,
        ISL29030P = 2,
        ISL29030L = 3,
        numSensorDrivers,
        numFds,
    };

    static const size_t wake = numFds - 1;
    static const char WAKE_MESSAGE = 'W';
    struct pollfd mPollFds[numFds];
    int mWritePipeFd;
    SensorBase* mSensors[numSensorDrivers];

    int handleToDriver(int handle) const
    {
        switch (handle) {
            case SENSOR_TYPE_ACCELEROMETER:
#ifdef USE_KXTF9_ACCELEROMETER
                return KXTF9;
#else
                return AK8973;
#endif
            case SENSOR_TYPE_ORIENTATION:
            case SENSOR_TYPE_MAGNETIC_FIELD:
            case SENSOR_TYPE_AMBIENT_TEMPERATURE:
                return AK8973;
            case SENSOR_TYPE_PROXIMITY:
                return ISL29030P;
            case SENSOR_TYPE_LIGHT:
                return ISL29030L;
        }
        return -EINVAL;
    }
};

/*****************************************************************************/

sensors_poll_context_t::sensors_poll_context_t()
{
    mSensors[KXTF9] = new SensorKXTF9();
    mPollFds[KXTF9].fd = mSensors[KXTF9]->getFd();
    mPollFds[KXTF9].events = POLLIN;
    mPollFds[KXTF9].revents = 0;

    mSensors[AK8973] = new SensorAK8973();
    mPollFds[AK8973].fd = mSensors[AK8973]->getFd();
    mPollFds[AK8973].events = POLLIN;
    mPollFds[AK8973].revents = 0;

    mSensors[ISL29030P] = new SensorISL29030P();
    mPollFds[ISL29030P].fd = mSensors[ISL29030P]->getFd();
    mPollFds[ISL29030P].events = POLLIN;
    mPollFds[ISL29030P].revents = 0;

    mSensors[ISL29030L] = new SensorISL29030L();
    mPollFds[ISL29030L].fd = mSensors[ISL29030L]->getFd();
    mPollFds[ISL29030L].events = POLLIN;
    mPollFds[ISL29030L].revents = 0;

    int wakeFds[2];
    int result = pipe(wakeFds);

    LOGE_IF(result < 0, "error creating wake pipe (%s)", strerror(errno));

    fcntl(wakeFds[0], F_SETFL, O_NONBLOCK);
    fcntl(wakeFds[1], F_SETFL, O_NONBLOCK);

    mWritePipeFd = wakeFds[1];

    mPollFds[wake].fd = wakeFds[0];
    mPollFds[wake].events = POLLIN;
    mPollFds[wake].revents = 0;
}

sensors_poll_context_t::~sensors_poll_context_t()
{
    for (int i = 0; i < numSensorDrivers; i++) {
        delete mSensors[i];
    }

    close(mPollFds[wake].fd);
    close(mWritePipeFd);
}

int sensors_poll_context_t::activate(int handle, int enabled)
{
    int index = handleToDriver(handle);
    if (index < 0) {
        return index;
    }

    int err = mSensors[index]->enable(handle, enabled);

    if (enabled && !err) {
        const char wakeMessage(WAKE_MESSAGE);
        int result = write(mWritePipeFd, &wakeMessage, 1);
        LOGE_IF(result<0, "error sending wake message (%s)", strerror(errno));
    }

    return err;
}

int sensors_poll_context_t::setDelay(int handle, int64_t ns)
{
    int index = handleToDriver(handle);
    if (index < 0) {
        return index;
    }

    return mSensors[index]->setDelay(handle, ns);
}

int sensors_poll_context_t::pollEvents(sensors_event_t* data, int count)
{
    int nbEvents = 0;
    int n = 0;

    do {
        // see if we have some leftover from the last poll()
        for (int i = 0 ; count && i < numSensorDrivers; i++) {
            SensorBase* const sensor(mSensors[i]);
            if ((mPollFds[i].revents & POLLIN) || (sensor->hasPendingEvents())) {
                int nb = sensor->readEvents(data, count);
                if (nb < count) {
                    // no more data for this sensor
                    mPollFds[i].revents = 0;
                }
                count -= nb;
                nbEvents += nb;
                data += nb;
            }
        }

        if (count) {
            // we still have some room, so try to see if we can get
            // some events immediately or just wait if we don't have
            // anything to return
            n = poll(mPollFds, numFds, nbEvents ? 0 : -1);
            if (n < 0) {
                LOGE("poll() failed (%s)", strerror(errno));
                return -errno;
            }

            if (mPollFds[wake].revents & POLLIN) {
                char msg;
                int result = read(mPollFds[wake].fd, &msg, 1);
                LOGE_IF(result<0, "error reading from wake pipe (%s)", strerror(errno));
                LOGE_IF(msg != WAKE_MESSAGE, "unknown message on wake queue (0x%02x)", int(msg));
                mPollFds[wake].revents = 0;
            }
        }
        // if we have events and space, go read them
    } while (n && count);

    return nbEvents;
}

/*****************************************************************************/

static int poll__close(struct hw_device_t *dev)
{
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    if (ctx) {
        delete ctx;
    }

    return 0;
}

static int poll__activate(struct sensors_poll_device_t *dev, int handle, int enabled)
{
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->activate(handle, enabled);
}

static int poll__setDelay(struct sensors_poll_device_t *dev, int handle, int64_t ns)
{
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->setDelay(handle, ns);
}

static int poll__poll(struct sensors_poll_device_t *dev, sensors_event_t* data, int count)
{
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->pollEvents(data, count);
}

/*****************************************************************************/

int init_nusensors(hw_module_t const* module, hw_device_t** device)
{
    int status = -EINVAL;

    sensors_poll_context_t *dev = new sensors_poll_context_t();
    memset(&dev->device, 0, sizeof(sensors_poll_device_t));

    dev->device.common.tag = HARDWARE_DEVICE_TAG;
    dev->device.common.version  = 0;
    dev->device.common.module   = const_cast<hw_module_t*>(module);
    dev->device.common.close    = poll__close;
    dev->device.activate        = poll__activate;
    dev->device.setDelay        = poll__setDelay;
    dev->device.poll            = poll__poll;

    *device = &dev->device.common;
    status = 0;

    return status;
}

/*****************************************************************************/
