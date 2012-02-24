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

#ifndef ANDROID_SENSORS_H
#define ANDROID_SENSORS_H

#include <stdint.h>
#include <errno.h>
#include <sys/cdefs.h>
#include <sys/types.h>

#include <linux/input.h>

#include <hardware/hardware.h>
#include <hardware/sensors.h>

// gingerbread/ics compat
#ifndef SENSOR_TYPE_AMBIENT_TEMPERATURE
#define SENSOR_TYPE_AMBIENT_TEMPERATURE SENSOR_TYPE_TEMPERATURE
#endif

__BEGIN_DECLS

/*****************************************************************************/

int init_nusensors(hw_module_t const* module, hw_device_t** device);

/*****************************************************************************/

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))

/*****************************************************************************/

#define KXTF9_DEVICE_NAME                  "/dev/kxtf9"
#define KXTF9_DEFAULT_DELAY                (200 * 1000000)

#define KXTF9_LSG                          (1000.0f)
#define KXTF9_CONVERT_A                    (GRAVITY_EARTH / KXTF9_LSG)
#define KXTF9_CONVERT_A_X                  (-KXTF9_CONVERT_A)
#define KXTF9_CONVERT_A_Y                  (KXTF9_CONVERT_A)
#define KXTF9_CONVERT_A_Z                  (-KXTF9_CONVERT_A)

/*
  Orientation events:

  0x01 screen down                0°
  0x02 screen up                  0°

  0x04 portrait, normal use       0°
  0x08 portrait, reversed       180°
  0x10 landscape, usb port up   270° (-90°)
  0x20 landscape, usb port down  90°

  so, we need to divide per 8 (3bits right)
*/
#define KXTF9_SENSOR_ROTATION_MASK         (0x3F)

#define KXTF9_CONVERT_O                    (90.0f/8.0f)
#define KXTF9_CONVERT_O_Y                  (KXTF9_CONVERT_O)
#define KXTF9_CONVERT_O_P                  (KXTF9_CONVERT_O)
#define KXTF9_CONVERT_O_R                  (KXTF9_CONVERT_O)


#define AK8973_DEVICE_NAME                 "/dev/akm8973_aot"
#define AK8973_DEFAULT_DELAY               (200 * 1000000)

#define AK8973_LSG                         (1000.0f)
#define AK8973_CONVERT_A                   (GRAVITY_EARTH / AK8973_LSG)
#define AK8973_CONVERT_A_X                 (-AK8973_CONVERT_A)
#define AK8973_CONVERT_A_Y                 (AK8973_CONVERT_A)
#define AK8973_CONVERT_A_Z                 (-AK8973_CONVERT_A)

#define AK8973_CONVERT_M                   (1.0f/16.0f)
#define AK8973_CONVERT_M_X                 (AK8973_CONVERT_M)
#define AK8973_CONVERT_M_Y                 (-AK8973_CONVERT_M)
#define AK8973_CONVERT_M_Z                 (-AK8973_CONVERT_M)

#define AK8973_CONVERT_O                   (1.0f/64.0f)
#define AK8973_CONVERT_O_A                 (AK8973_CONVERT_O)
#define AK8973_CONVERT_O_P                 (AK8973_CONVERT_O)
#define AK8973_CONVERT_O_R                 (-AK8973_CONVERT_O)

#define AK8973_SENSOR_STATE_MASK           (0x3)


#define ISL29030_DEVICE_NAME               "/dev/isl29030"

/*****************************************************************************/

__END_DECLS

#endif  // ANDROID_SENSORS_H
