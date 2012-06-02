#!/system/bin/sh

######## BootMenu Script
######## Overclock.sh

export PATH=/sbin:/system/xbin:/system/bin
CONFIG_FILE="/system/bootmenu/config/overclock.conf"
MODULE_DIR="/system/lib/modules"
SCALING_GOVERNOR="/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
ASKED_MODE=$1

#############################################################
# Parameters Load
#############################################################

##### Default Param
# enable 0
# load_all 0
# scaling 2
# clk1 300
# clk2 600
# clk3 1000
# clk4 1000
# vsel1 30
# vsel2 46
# vsel3 58
# vsel4 58
# con_up_threshold 80
# con_down_threshold 20
# con_freq_step 5
# con_sampling_rate 160000
# int_min_sample_rate 50000
# ond_up_threshold 86
# ond_sampling_rate 50000
# smt_min_cpu_load 20
# smt_max_cpu_load 80
# smt_awake_min_freq 0
# smt_sleep_max_freq 250000
# smt_up_min_freq 1000000
# smt_wakeup_freq 1000000
# smt_ramp_up_step 250000
# bst_awake_ideal_freq 800000
# bst_down_rate_us 97000
# bst_max_cpu_load 70
# bst_min_cpu_load 40
# bst_ramp_down_step 160000
# bst_ramp_up_step 160000
# bst_sample_rate_jiffies 2
# bst_sleep_ideal_freq 300000
# bst_sleep_wakeup_freq 300000
# bst_up_rate_us 52000
# bst_debug_mask 0
# iosched_sio 0

param_load()
{
  for CONF in $(sed -e 's/^\([^ ]*\) \(.*\)/\1=\2/g' $CONFIG_FILE); do
    export $CONF
  done
}

param_safe()
{
  echo "cpufreq: ondemand safe"
  # for bootmenu operations
  # enable ondemand profile
  # which is in kernel
  export enable=1
  export load_all=0
  export clk1=300
  export clk2=600
  export clk3=800
  export clk4=1000
  export vsel1=30
  export vsel2=46
  export vsel3=52
  export vsel4=58
  export scaling=2
  export ond_up_threshold=86
  export ond_sampling_rate=50000
}

#############################################################
# Get Address
#############################################################

get_address()
{
  cpufreq_table=`grep -e omap2_clk_init_cpufreq_table /proc/kallsyms | sed -e "s/\([0-9A-Fa-f]\{8\}\).*/\1/"`
  stats_update=`grep -e cpufreq_stats_update$ /proc/kallsyms | sed -e "s/\([0-9A-Fa-f]\{8\}\).*/\1/"`
}

#############################################################
# Install Module
#############################################################

install_module()
{
  # load module
  insmod $MODULE_DIR/overclock_defy.ko omap2_clk_init_cpufreq_table_addr=0x$cpufreq_table
  #set cpufreq_stats_update_addr
  echo 0x$stats_update > /proc/overclock/cpufreq_stats_update_addr
  if [ $load_all -eq 1 ]; then
    insmod $MODULE_DIR/cpufreq_conservative.ko
    insmod $MODULE_DIR/cpufreq_powersave.ko
    insmod $MODULE_DIR/symsearch.ko
    insmod $MODULE_DIR/clockfix.ko
    insmod $MODULE_DIR/cpufreq_stats.ko
    insmod $MODULE_DIR/cpufreq_interactive.ko
    insmod $MODULE_DIR/cpufreq_smartass.ko
    insmod $MODULE_DIR/cpufreq_boosted.ko
  fi
  busybox chown -R system /sys/devices/system/cpu
  busybox chown -R system /sys/class/block/mmc*/queue
}

#############################################################
# Set Scaling
#############################################################

set_scaling()
{
  case "$scaling" in
    "0" )
      if [ $load_all -eq 0 ]; then
        insmod $MODULE_DIR/cpufreq_conservative.ko
      fi
      echo "conservative" > $SCALING_GOVERNOR
      echo $con_freq_step > /sys/devices/system/cpu/cpu0/cpufreq/conservative/freq_step
      echo $con_down_threshold > /sys/devices/system/cpu/cpu0/cpufreq/conservative/down_threshold
      echo $con_sampling_rate > /sys/devices/system/cpu/cpu0/cpufreq/conservative/sampling_rate
      echo $con_up_threshold > /sys/devices/system/cpu/cpu0/cpufreq/conservative/up_threshold
    ;;
    "1" )
      if [ $load_all -eq 0 ]; then
        insmod $MODULE_DIR/symsearch.ko
        insmod $MODULE_DIR/clockfix.ko
        insmod $MODULE_DIR/cpufreq_stats.ko
        insmod $MODULE_DIR/cpufreq_interactive.ko
      fi
      echo "interactive" > $SCALING_GOVERNOR
      echo $int_min_sample_rate > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
    ;;
    "2" )
      echo "ondemand" > $SCALING_GOVERNOR
      echo $ond_sampling_rate > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
      echo $ond_up_threshold > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
    ;;
    "3" )
      echo "performance" > $SCALING_GOVERNOR
    ;;
    "4" )
      if [ $load_all -eq 0 ]; then
        insmod $MODULE_DIR/cpufreq_powersave.ko
      fi
      echo "powersave" > $SCALING_GOVERNOR
    ;;
    "5" )
      if [ "$load_all" -eq "0" ]; then
        insmod $MODULE_DIR/symsearch.ko
        insmod $MODULE_DIR/clockfix.ko
        insmod $MODULE_DIR/cpufreq_boosted.ko
      fi

      echo boosted > $SCALING_GOVERNOR
      echo $bst_debug_mask     > /sys/devices/system/cpu/cpufreq/boosted/debug_mask
      echo $bst_awake_ideal_freq > /sys/devices/system/cpu/cpufreq/boosted/awake_ideal_freq
      echo $bst_down_rate_us   > /sys/devices/system/cpu/cpufreq/boosted/down_rate_us
      echo $bst_max_cpu_load   > /sys/devices/system/cpu/cpufreq/boosted/max_cpu_load
      echo $bst_min_cpu_load   > /sys/devices/system/cpu/cpufreq/boosted/min_cpu_load
      echo $bst_ramp_down_step > /sys/devices/system/cpu/cpufreq/boosted/ramp_down_step
      echo $bst_ramp_up_step   > /sys/devices/system/cpu/cpufreq/boosted/ramp_up_step
      echo $bst_sample_rate_jiffies > /sys/devices/system/cpu/cpufreq/boosted/sample_rate_jiffies
      echo $bst_sleep_ideal_freq    > /sys/devices/system/cpu/cpufreq/boosted/sleep_ideal_freq
      echo $bst_sleep_wakeup_freq   > /sys/devices/system/cpu/cpufreq/boosted/sleep_wakeup_freq
      echo $bst_up_rate_us     > /sys/devices/system/cpu/cpufreq/boosted/up_rate_us
    ;;
    "6" )
      if [ $load_all -eq 0 ]; then
        insmod $MODULE_DIR/symsearch.ko
        insmod $MODULE_DIR/clockfix.ko
        insmod $MODULE_DIR/cpufreq_smartass.ko
      fi
      echo "smartass" > $SCALING_GOVERNOR
      echo $smt_min_cpu_load > /sys/devices/system/cpu/cpu0/cpufreq/smartass/min_cpu_load
      echo $smt_max_cpu_load > /sys/devices/system/cpu/cpu0/cpufreq/smartass/max_cpu_load
      echo $smt_awake_min_freq > /sys/devices/system/cpu/cpu0/cpufreq/smartass/awake_min_freq
      echo $smt_sleep_max_freq > /sys/devices/system/cpu/cpu0/cpufreq/smartass/sleep_max_freq
      echo $smt_up_min_freq > /sys/devices/system/cpu/cpu0/cpufreq/smartass/up_min_freq
      echo $smt_wakeup_freq > /sys/devices/system/cpu/cpu0/cpufreq/smartass/sleep_wakeup_freq
      echo $smt_ramp_up_step > /sys/devices/system/cpu/cpu0/cpufreq/smartass/ramp_up_step
    ;;
    "7" )
      if [ $load_all -eq 0 ]; then
        insmod $MODULE_DIR/cpufreq_userspace.ko
      fi
      echo "userspace" > $SCALING_GOVERNOR
    ;;
     * )
    ;;
  esac
}

#############################################################
# Alternative I/O Schedulers
#
# Default linux I/O Schedulers are optimized for Hard disks
# The alternative ones are optimized for flash disks
#############################################################

set_ioscheduler()
{
  iosched="cfq"
  if [ "$iosched_sio" -eq "1" ]; then
      iosched="sio"
  fi

  # options: 'noop cfq sio'
  case "$iosched" in
    "cfq" )
    ;;
    "sio" )
      insmod $MODULE_DIR/sio_iosched.ko
      for i in /sys/block/mmc*/queue; do
        [ -f "$i/scheduler" ]                 && echo $iosched > $i/scheduler

        [ -f "$i/iosched/low_latency" ]       && echo 1 > $i/iosched/low_latency
        [ -f "$i/iosched/back_seek_penalty" ] && echo 1 > $i/iosched/back_seek_penalty
        [ -f "$i/iosched/back_seek_max" ]     && echo 1000000000 > $i/iosched/back_seek_max
        [ -f "$i/iosched/slice_idle" ]        && echo 0 > $i/iosched/slice_idle
        [ -f "$i/iosched/fifo_batch" ]        && echo 1 > $i/iosched/fifo_batch
        [ -f "$i/iosched/quantum" ]           && echo 16 > $i/iosched/quantum
        [ -f "$i/nr_requests" ]               && echo 512 > $i/nr_requests

        [ -f "$i/rotational" ]  && [ "`cat $i/rotational`" -ne "0" ] && echo 0 > $i/rotational
        [ -f "$i/iostats" ]     && [ "`cat $i/iostats`" -ne "0" ]    && echo 0 > $i/iostats
      done
    ;;
     * )
    ;;
  esac
}

#############################################################
# Set Clock Table
#############################################################

set_overclock_table()
{
# echo "$vsel4" > /proc/overclock/max_vsel
  echo "$vsel3" > /proc/overclock/max_vsel
# echo "${clk4}000" > /proc/overclock/max_rate
  echo "${clk3}000" > /proc/overclock/max_rate
# echo "4 ${clk4}000000 $vsel4" > /proc/overclock/mpu_opps
  echo "3 ${clk3}000000 $vsel3" > /proc/overclock/mpu_opps
  echo "2 ${clk2}000000 $vsel2" > /proc/overclock/mpu_opps
  echo "1 ${clk1}000000 $vsel1" > /proc/overclock/mpu_opps
# echo "0 ${clk4}000" > /proc/overclock/freq_table
  echo "0 ${clk3}000" > /proc/overclock/freq_table
  echo "1 ${clk2}000" > /proc/overclock/freq_table
  echo "2 ${clk1}000" > /proc/overclock/freq_table
}

#############################################################
# Main Scrpit
#############################################################

if [ "$ASKED_MODE" = "safe" ]; then
  param_safe
else
  if [ -e $CONFIG_FILE ]; then
    param_load
  else
    param_safe
  fi
fi

if [ $enable -eq 1 ]; then

  get_address
  install_module

  echo "set scaling..."
  set_scaling
  echo "set overclock table..."
  set_overclock_table
  echo "set ioscheduler..."
  set_ioscheduler

  busybox chown -R system /sys/devices/system/cpu

fi

