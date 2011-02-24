#!/bin/bash

# This has only been tested on the Samsung Epic 4G
# !!!Make sure that you have installed ClockworkMod and backed up your device!!!
#
# Notes:
# - May brick your device, if it does restore your most recent backup using ClockworkMod
# - Only tested with Samsung Epic 4G / EB13 / Froyo
# - You must have a recent version of the java JDK installed (see www.oracle.com)
# 
#

#Modify this to point to where your android sdk is
adb=~/android-sdk-linux_x86/platform-tools/adb

if [ ! -x $adb ]
then
  echo "Could not find adb, please set the adb variable in modify_jar.sh"
  exit -3
fi


# Jar/ODEX to modify
JAR=$1

# Patch/dir to apply
TARGET=$2

if [ "$JAR" != "" ]
then

  JAR_BN=`basename $JAR .jar`



  if [ ! -d framework ]
  then
    echo "Copying /system directory from device"
    $adb pull /system/framework framework
  fi

  if [ ! -f framework/$JAR_BN.jar ]
  then
    echo "Please make sure you specified the entire name of the file, i.e. services.jar" 
    echo "and that the specified jar exists in system/framework"
    exit -1
  fi

  # Don't over write any existing dumps
  if [ "$TARGET" == "" ]
  then
    if [ ! -d "${JAR_BN}_dex" ]
    then
      echo "Dumping the the dex code to the directory ${JAR_BN}_dex"
      if [ -f ${JAR_BN}.jar ]
      then
        rm ${JAR_BN}.jar
      fi
      java -jar tools/baksmali-1.2.6.jar -x -d framework/ -o ${JAR_BN}_dex framework/$JAR_BN.odex 
    fi
  fi

  if [ "$TARGET" != "" ] 
  then 

    if [ -d $TARGET ] 
    then
      echo "Using directory $TARGET"
      echo "Building dex file: classes.dex"
      java -jar tools/smali-1.2.6.jar $TARGET -o classes.dex
    elif [ -f $TARGET ]
    then
      if [ ! -d "${JAR_BN}_dex" ]
      then
        echo "Dumping the the dex code to the directory ${JAR_BN}_dex"
        java -jar tools/baksmali-1.2.6.jar -x -d framework -o ${JAR_BN}_dex framework/$JAR_BN.odex 
      else
        echo "Please move the ${JAR_BN}_dex directory out of the way"
        exit -2
      fi      
      echo "Patching ${JAR_BN}_dex"
      (cd ${JAR_BN}_dex  && patch -p1 < ../$TARGET) 
      if [ $? -eq 0 ]
      then
        echo "Building dex file: classes.dex"
        java -jar tools/smali-1.2.6.jar ${JAR_BN}_dex  -o classes.dex
        rm -rf ${JAR_BN}_dex 
      else
        echo "Error applying patch"
      fi
    fi
    
    echo "Adding to classes.dex to $JAR_BN.jar"
    cp framework/${JAR_BN}.jar . 
    jar -uf ${JAR_BN}.jar classes.dex 

    echo "Pushing new jar to device"
    $adb shell busybox mkdir -p /sdcard/dex/
    $adb push ${JAR_BN}.jar /sdcard/dex/
    
    echo "Pushing shell script to device"
    $adb push resources/dexopt-wrapper /sdcard/dex/    
    $adb push resources/prepare_jar.sh /sdcard/dex/

    echo "Modifying device"
    $adb shell su -c "bash /sdcard/dex/prepare_jar.sh $JAR_BN"

  fi 
  
else
cat<<EOF

** Use at your own risk, no warranty, this may kill your device **

Usage: JAR [PATCH / DIR]
  JAR - The jar in /system/framework you with to modify
  PATCH - The patchfile you with to apply
  DIR - The directory containing the dex source you with to push to the device

Examples:
  modify_jar.sh services.jar  - Will simply grab the jar and dump the contents into a directory called services_dex
  modify_jar.sh services.jar services_dex/ - Will push the changes in the specified directory to the device 
  modify_jar.sh services.jar patch.diff - Will push the changes in the specified patch to the device

Please see the included README for more details
EOF
  exit 0;
fi
