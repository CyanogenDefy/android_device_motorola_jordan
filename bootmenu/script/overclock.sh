#!/system/bin/sh

######## BootMenu Script
######## Overclock.sh

export PATH=/sbin:/system/xbin:/system/bin
CONFIG_FILE="/system/bootmenu/config/overclock.conf"
MODULE_DIR="/system/bootmenu/ext/modules"
SCALING_GOVERNOR="/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"

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
# vsel1 30
# vsel2 46
# vsel3 58
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

param_load()
{
  for CONF in $(sed -e 's/^\([^ ]*\) \(.*\)/\1=\2/g' $CONFIG_FILE); do
    export $CONF
  done
}

#############################################################
# Get Address
#############################################################

get_address()
{
  cpufreq_table=`grep -e omap2_clk_init_cpufreq_table /proc/kallsyms | sed -e "s/\([0-9A-Fa-f]\{8\}\).*/\1/"`
  stats_update=`grep -e cpufreq_stats_update /proc/kallsyms | sed -e "s/\([0-9A-Fa-f]\{8\}\).*/\1/"`
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
    insmod $MODULE_DIR/symsearch.ko
    insmod $MODULE_DIR/cpufreq_stats.ko
    insmod $MODULE_DIR/cpufreq_interactive.ko
    insmod $MODULE_DIR/cpufreq_smartass.ko
    insmod $MODULE_DIR/cpufreq_powersave.ko
  fi
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
      echo $con_sampling_rate > /sys/devices/system/cpu/cpu0/cpufreq/conservative/sampling_rate
      echo $con_freq_step > /sys/devices/system/cpu/cpu0/cpufreq/conservative/freq_step
      echo $con_up_threshold > /sys/devices/system/cpu/cpu0/cpufreq/conservative/up_threshold
      echo $con_down_threshold > /sys/devices/system/cpu/cpu0/cpufreq/conservative/down_threshold
    ;;
    "1" )
      if [ $load_all -eq 0 ]; then
        insmod $MODULE_DIR/symsearch.ko
        insmod $MODULE_DIR/cpufreq_stats.ko
        insmod $MODULE_DIR/cpufreq_interactive.ko
      fi
      echo "interactive" > $SCALING_GOVERNOR
      echo $int_min_sample_rate > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
    ;;
    "2" )
      echo "ondemand" > $SCALING_GOVERNOR
      echo $ond_sampling_rate > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/sampling_rate
      echo $ond_up_threshold > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
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
      if [ $load_all -eq 0 ]; then
        insmod $MODULE_DIR/symsearch.ko
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
    "6" )
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
# Set Clock Table
#############################################################

set_overclock_table()
{
  echo "$vsel3" > /proc/overclock/max_vsel
  echo "${clk3}000" > /proc/overclock/max_rate
  echo "3 ${clk3}000000 $vsel3" > /proc/overclock/mpu_opps
  echo "2 ${clk2}000000 $vsel2" > /proc/overclock/mpu_opps
  echo "1 ${clk1}000000 $vsel1" > /proc/overclock/mpu_opps
  echo "0 ${clk3}000" > /proc/overclock/freq_table
  echo "1 ${clk2}000" > /proc/overclock/freq_table
  echo "2 ${clk1}000" > /proc/overclock/freq_table
}

#############################################################
# Main Scrpit
#############################################################

if [ -e $CONFIG_FILE ]; then
  param_load
  if [ $enable -eq 1 ]; then
    get_address
    install_module
    set_scaling
    set_overclock_table
  fi
fi
