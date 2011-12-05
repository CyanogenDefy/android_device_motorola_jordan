/*
 * Copyright (c) 2010 NVIDIA Corporation.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */


#ifndef INCLUDED_NVODM_ACCELEROMETER_BMA150_H
#define INCLUDED_NVODM_ACCELEROMETER_BMA150_H

#if defined(_cplusplus)
extern "C"
{
#endif

#include "nvodm_services.h"
#include "nvodm_accelerometer.h"

/* BMA150 register address */
#define CHIP_ID_REG             0x00
#define VERSION_REG             0x01
#define X_AXIS_LSB_REG          0x02
#define X_AXIS_MSB_REG          0x03
#define Y_AXIS_LSB_REG          0x04
#define Y_AXIS_MSB_REG          0x05
#define Z_AXIS_LSB_REG          0x06
#define Z_AXIS_MSB_REG          0x07
#define TEMP_RD_REG             0x08
#define SMB150_STATUS_REG       0x09
#define SMB150_CTRL_REG         0x0a
#define SMB150_CONF1_REG        0x0b
#define LG_THRESHOLD_REG        0x0c
#define LG_DURATION_REG         0x0d
#define HG_THRESHOLD_REG        0x0e
#define HG_DURATION_REG         0x0f
#define MOTION_THRS_REG         0x10
#define HYSTERESIS_REG          0x11
#define CUSTOMER1_REG           0x12
#define CUSTOMER2_REG           0x13
#define RANGE_BWIDTH_REG        0x14
#define SMB150_CONF2_REG        0x15

#define OFFS_GAIN_X_REG         0x16
#define OFFS_GAIN_Y_REG         0x17
#define OFFS_GAIN_Z_REG         0x18
#define OFFS_GAIN_T_REG         0x19
#define OFFSET_X_REG            0x1a
#define OFFSET_Y_REG            0x1b
#define OFFSET_Z_REG            0x1c
#define OFFSET_T_REG            0x1d

/* range and bandwidth */
#define BMA_RANGE_2G            0
#define BMA_RANGE_4G            1
#define BMA_RANGE_8G            2

#define BMA_BW_25HZ             0
#define BMA_BW_50HZ             1
#define BMA_BW_100HZ            2
#define BMA_BW_190HZ            3
#define BMA_BW_375HZ            4
#define BMA_BW_750HZ            5
#define BMA_BW_1500HZ           6

/* mode settings */
#define BMA_MODE_NORMAL         0
#define BMA_MODE_SLEEP          1

#define BMA150_CHIP_ID      0x02        // RO - device identification
/*
 * Defines the threshold source for the accelerometer.
 */
typedef enum
{
    /// Indicates the accelerometer generated interrupt by exceeding the x threshold.
    NvOdmAccelerometerThresholdSource_X = 0,

    /// Indicates the accelerometer generated interrupt by exceeding the y threshold.
    NvOdmAccelerometerThresholdSource_Y,

    /// Indicates the accelerometer generated interrupt by exceeding the z threshold.
    NvOdmAccelerometerThresholdSource_Z,

    NvOdmAccelerometerThresholdSource_Force32 = 0x7FFFFFFF
} NvOdmAccelerometerThresholdSource;

// Timeout for I2C transaction.
enum { I2C_ACCELRATOR_TRANSACTION_TIMEOUT = 1000 };
// Maximum number of packetsize supported by the I2C controller.
enum { I2C_ACCELRATOR_PACKET_SIZE = 8};
static NvU8 s_ReadBuffer[I2C_ACCELRATOR_PACKET_SIZE];
static NvU8 s_WriteBuffer[I2C_ACCELRATOR_PACKET_SIZE];

#define INT_EVENT_TIMEOUT 100
#define NV_ACCELEROMETER_BUS_I2C 0
#define NV_ACCELEROMETER_BUS_SPI_3 1
#define NV_ACCELEROMETER_BUS_SPI_4 2

/*
 * Defines the way to read accelerometer registers.
 */
typedef NvBool
(*AccelerometerRegsRead)(
    NvOdmAccelHandle hDevice,
    NvU8 nRegOffset,
    NvU8* nData,
    NvU32 nLen);
/*
 * Defines the way to write accelerometer registers.
 */
typedef NvBool
(*AccelerometerRegsWrite)(
    NvOdmAccelHandle hDevice,
    NvU8 nRegOffset,
    NvU8* nData,
    NvU32 nLen);
/*
 * Holds register address and value pairs.
 */
typedef struct NvDevCtrlRegRec {
   /// Holds the register offset.
   NvU8 RegAddr;
   /// Holds the value programmed into the upper address.
   NvU8 RegValue;
} NvDevCtrlReg;
/*
 * Max accelerometer registers number.
 */
#define ACCELEROMETER_CONTROL_REGS_MAX_LENGHT 100
/*
 * Max accelerometer callback functions number.
 */
#define ACCELEROMETER_CALLBACK_ARRAY_LENGTH   5

typedef struct NvOdmAccelRec
{
    // Specifies use I2C or SPI to configure accelerometer registers.
    NvU8 nBusType;
    // Specifies accelerometer device address, for example, I2C write address.
    NvU8 nDevAddr;
    // Specifies the initial value that make accelerometer work,
    // ACCELEROMETER_CONTROL_REGS_MAX_LENGHT is always 100.
    NvDevCtrlReg CtrlRegsList[ACCELEROMETER_CONTROL_REGS_MAX_LENGHT];
    // Specifies the initial CtrlRegsList length.
    NvU8 nLength;
    // Specifies accelerometer chip ID.
    NvU8 nChipID;
    // Specifies the way to get accelerometer register information.
    AccelerometerRegsRead RegsRead;
    // Specifies the way to set accelerometer register information.
    AccelerometerRegsWrite RegsWrite;
    // Specifies I2C handle from the system.
    NvOdmServicesI2cHandle  hOdmI2C;
    // Interrupt pin to ap15.
    NvOdmServicesGpioHandle hGpioINT;
    NvOdmGpioPinHandle      hPinINT;
    NvU32 GPIOPortINT;
    NvU32 GPIOPinINT;
    NvOdmOsSemaphoreHandle SemaphoreForINT;
    NvOdmServicesGpioIntrHandle hGpioInterrupt;
    NvOdmAccelIntType Data;
    NvOdmServicesPmuHandle hPmu;
    NvU32 VddId;
    NvU32 I2CChannelId;
    NvOdmAccelerometerCaps Caption;
    NvOdmAccelPowerType PowerState;
    // In real case, when the board put in frontispiece, the value from z axis
    // should be g, but due to physical connect on different board, the axis
    // should be remapped to the correct one.
    NvOdmAccelAxisType AxisXMapping;
    // If the physical direct is the same with our expection, the value
    // should be set to 1, or else the value should be -1.
    NvS32              AxisXDirection;
    NvOdmAccelAxisType AxisYMapping;
    NvS32              AxisYDirection;
    NvOdmAccelAxisType AxisZMapping;
    NvS32              AxisZDirection;
} NvOdmAccel;

#if defined(__cplusplus)
}
#endif
#endif
