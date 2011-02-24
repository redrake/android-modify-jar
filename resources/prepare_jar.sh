#!/system/xbin/bash

cd /sdcard/dex/

mount -t rfs -o remount,rw /dev/block/stl9 /system

if [ ! -f /system/xbin/dexopt-wrapper ] 
then
	cp dexopt-wrapper /system/xbin/dexopt-wrapper
	chmod 755 /system/xbin/dexopt-wrapper
fi

if [ ! -d backup ]
then
  mkdir backup
fi

if [ -f "$1.jar" ] 
then

  # Delete the prior odex file
  if [ -f new.odex ]
  then
    rm new.odex
  fi

  # Generate the new odex file
  dexopt-wrapper $1.jar new.odex $BOOTCLASSPATH
 
  # If we succedded 
  if [ -f new.odex ]
  then
    busybox dd if=/system/framework/$1.odex of=new.odex bs=1 count=20 skip=52 seek=52 conv=notrunc
    echo "Backing up old $1.odex to /sdcard/dex/backup/"
    cp /system/framework/$1.odex backup/$1.odex.orig
    cp new.odex /system/framework/$1.odex
    chmod 644 /system/framework/$1.odex
    rm new.odex
    echo "New jar successfully installed, reboot your device when ready"
  fi
fi
