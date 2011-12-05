#include <fcntl.h>

#include "device/KXTF9.hpp"
#include "kernel-2.6.32/kxtf9.h"
#include "util.hpp"

namespace akmd {

KXTF9::KXTF9()
: index(0), accelerometer(3600)
{
    int enabled=0;

    abuf[0] = abuf[1] = Vector();

    fd = open(KXTF9_NAME, O_RDONLY);
    SUCCEED(fd != -1);
    SUCCEED(ioctl(fd, KXTF9_IOCTL_GET_ENABLE, &enabled) == 0);

    LOGI("KXTF9 enabled=%d", enabled);

/* BMA150
    char rwbuf[8] = { 1, RANGE_BWIDTH_REG };
    SUCCEED(ioctl(fd, BMA_IOCTL_READ, &rwbuf) == 0);
    rwbuf[2] = (rwbuf[1] & 0xf8) | 1; // 47 Hz sampling
    rwbuf[0] = 2;
    rwbuf[1] = RANGE_BWIDTH_REG;
    SUCCEED(ioctl(fd, BMA_IOCTL_WRITE, &rwbuf) == 0);
*/
}

KXTF9::~KXTF9()
{
    SUCCEED(close(fd) == 0);
}

int KXTF9::get_delay()
{
    int delay=-1;

    SUCCEED(fd != -1);
    SUCCEED(ioctl(fd, KXTF9_IOCTL_GET_DELAY, &delay) == 0);

    return delay;
}

void KXTF9::calibrate()
{
    const int REFRESH = 10;
    /* Demand length to match with the long-term average before the vector
     * is trusted to represent gravity. */
    const float ERROR = 0.05f;
    /* Exponential average applied on acceleration to estimate gravity. */
    const float GRAVITY_SMOOTH = 0.8f;

    accelerometer_g = accelerometer_g.multiply(GRAVITY_SMOOTH).add(a.multiply(1.0f - GRAVITY_SMOOTH));

    /* a and g must have about the same length and point to about same
     * direction before I trust the value accumulated to g */
    float al = a.length();
    float gl = accelerometer_g.length();

    if (al == 0 || gl == 0) {
        return;
    }

    Vector an = a.divide(al);
    Vector gn = accelerometer_g.divide(gl);

    if (fabsf(al - gl) < ERROR
        && an.dot(gn) > 1.0f - ERROR) {

        /* Going to trust this point. */
        accelerometer.update(next_update.tv_sec, accelerometer_g);
        if (accelerometer.fit_time <= next_update.tv_sec - REFRESH) {
            accelerometer.try_fit(next_update.tv_sec);
        }
    }

    a = a.add(accelerometer.center.multiply(-1));
    a = a.multiply(accelerometer.scale);
}

void KXTF9::measure()
{
    SUCCEED(gettimeofday(&next_update, NULL) == 0);

    /* BMA150 is constantly measuring and filtering, so it never sleeps.
     * The ioctl in truth returns only 3 values, but buffer in kernel is
     * defined as 8 shorts long.
    short bma150_data[8];
    SUCCEED(ioctl(fd, BMA_IOCTL_READ_ACCELERATION, &bma150_data) == 0);
    abuf[index] = Vector(bma150_data[0], -bma150_data[1], bma150_data[2]);
    index = (index + 1) & 1;

    a = abuf[0].add(abuf[1]).multiply(0.5f * (720.0f / 256.0f));
    */

//TODO: For KXTF9

    calibrate();
}

Vector KXTF9::read()
{
    return a;
}

void KXTF9::start()
{
    int enabled = 1;
    SUCCEED(ioctl(fd, KXTF9_IOCTL_SET_ENABLE, &enabled) == 0);
}

void KXTF9::stop()
{
    int enabled = 0;
    SUCCEED(ioctl(fd, KXTF9_IOCTL_SET_ENABLE, &enabled) == 0);
}

}
