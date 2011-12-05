#pragma once

#include <sys/time.h>

#include "device/ChipReader.hpp"
#include "Calibrator.hpp"
#include "math/Vector.hpp"

#define  KXTF9_NAME "/dev/kxtf9"

namespace akmd {

class KXTF9 : public ChipReader {
    private:
    /* Open file descriptors */
    int fd;
    int index;

    Calibrator accelerometer;
    Vector accelerometer_g;

    struct timeval next_update;
    Vector abuf[2];
    Vector a;

    private:
    void calibrate();

    public:
    KXTF9();
    ~KXTF9();

    void measure();
    Vector read();
    int get_delay();

    void start();
    void stop();
};

}
