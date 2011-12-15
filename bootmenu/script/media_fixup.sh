#!/system/bin/sh

PATH='/system/xbin:/system/bin'

restart_required() {
  req=`logcat -d | tail -n 50 | grep "AudioPolicyService not published"`
  [ -n "$req" ] && return 1
  req=`logcat -d | tail -n 50 | grep "Media player service not published"`
  [ -n "$req" ] && return 1
  req=`logcat -d | tail -n 50 | grep "Waiting for service media"`
  [ -n "$req" ] && return 1
  return 0
}

restart_service() {
  logwrapper echo "RESTARTING MEDIA SERVICE TO FIX BOOTLOCK"
  stop media
  sleep 3
  start media
  logwrapper echo "restart done..."
}

# well, i could make a loop, but will be temporary :p

sleep 30

restart_required
if [ $? -eq 1 ]; then
  restart_service
fi

sleep 15

restart_required
if [ $? -eq 1 ]; then
  restart_service
fi

sleep 15

restart_required
if [ $? -eq 1 ]; then
  restart_service
fi

sleep 15

restart_required
if [ $? -eq 1 ]; then
  restart_service
fi

exit 0
