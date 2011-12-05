#!/system/bin/sh

PATH=/system/bin:$PATH

DEVICE="jordan"
MAGNETIC_GAIN="5" # 0 .. 15
TEMPERATURE_ZERO="112" # 0 .. 255

exec /system/bin/akmd.free $DEVICE $MAGNETIC_GAIN $TEMPERATURE_ZERO

