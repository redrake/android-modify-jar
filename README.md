
**THIS COMES WITH NO WARRANTY, YOU TAKE FULL RESPONSIBILITY IF IT KILLS YOUR DEVICE**

Introduction
============

These scripts allow you to easily modify existing system jar files on
certain Android devices.

This currently has only been tested on the Samsung Epic 4G with EB13, 
but may work on other Froyo based devices.

Overview
--------

The modify\_jar.sh script uses a number of tools to:

 * Download an existing jar/odex file from /system/framework
 * Allow you either modify or apply an predefined patch to the specified jar/odex
 * Push the modified jar/odex file to the device and have it integrated back into the device

Why would you do this?

 * Because you want to modify how the device works 
 * There is at least one predefined patch included in this package

Links
-----
 * The tools in tools/ came from:
   - http://code.google.com/p/smali/
 * dextopt-wrapper
   - http://www.netmite.com/android/mydroid/build/tools/dexpreopt/dexopt-wrapper/DexOptWrapper.cpp 

Supplied Patches
----------------

Currently there is only one supplied patch:

 * One which lets you disabled the irritating "Battery full, please remove charger" dialog box that appears every few minutes when charging your Samsung Epic 4G. To apply this change to your Epic 4g, insure you meet the requirements below and then run: 'modify\_jar.sh services.jar patches/epic_4g_services_disable_battery_popup.diff'


How to use it
-------------

First before you get started you need to know that you risk
bricking your device. Here are our assumptions

 - Your running some type of unix (linux is what this was tested on)
  - Cygwin on windows may work, who knows ...
 - You have the java JDK installed and in your path
 - You have the android-sdk installed in your home directory
  - Modify the adb variable at the top of modify\_jar.sh to point to your android sdk
 - Your device is plugged into USB and in debugging mode
 - You have rooted your device 
 - You have ClockWorkMod installed and have performed a recent backup of your device
 - We have only tested this on the Samsung Epic 4G /w Froyo

### First
 
 * Boot into the recovery console and make a backup of your device

So there are two ways to use this script:

#### The easy way:

Apply a supplied patch:

 * Locate the patch you want to apply, i.e. foo.diff
 * Install the patch 'modify\_jar.sh services.jar foo.diff'
 * You may want to make sure your device is unlocked, as a pop-up will appear asking you to approve running a program as root - approve it.
 * Reboot the device 

This will download the specified jar file, and apply the specified diff, and
then push the modified jar file back to your device and fake the appropriate
signature so android will not reject it.

So for example:

'modify\_jar.sh services.jar patches\epic\_4g\_services\_jar\_disable\_battery\_popup.diff'

May modify your services.jar to disable an annoying modal dialog box that pops up every 15 minutes
on your Epic 4g - because apparently Samsung feels compelled to annoy you with pointless dialog boxes.

#### The developer way

This will allow you to create your own patches
 
 * Determine what jar file you want to modify, i.e. services.jar
 * Fetch the specified jar and decompile it into dex code 'modify\_jar.sh services.jar'
  * (This will dump the dex code for this jar file into services_dex)
 * Modify the dex code 
  * This is where the developer part comes in.
 * Push the dex code in services\_dex to the device 'modify\_jar.sh services.jar services\_dex'
 * You may want to make sure your device is unlocked, as a popup will appear asking you to approve running a program as root - approve it.
  * Approve this program to run, if your going to be doing a lot of this.
 * Reboot the device
 
Once you get something that works you may want to put it into a patch, you can do this
using the 'diff' command.
 
diff -ur services\_dex services\_dex\_modified > epic\_4g\_services\_jar\_disable\_battery\_popup.diff

We suggest that you name your patches with [DEVICE]\_[JAR]\_[WHAT IT DOES].diff

What if something goes wrong?
-----------------------------

Hopefully you backed up your device using ClockworkMod, if so then your in luck.

 * Reboot your device into recovery mode (hint: You can run 'adb reboot recovery')
 * Restore either the entire device or just the system directory ( You can restore just /system by going into 'Advanced Restore' in ClockworkMod)
 * Reboot

How can I tell what went wrong?
-------------------------------

### If a patch fails to be applied

So sometimes, a patch will not work, this is typically because the patch is incompatible with something on the
device, or because it has already been applied. The first thing to do is to delete the 'framework/' directory.
This will cause the script to get a new copy of the jars on your device. The next thing to do is to start looking
at what caused the patch to failed to be applied; You could have specified the wrong jar file or it could simply
be incompatible with your phone.

### If the phone fails to boot

Well so as far as we can tell there are a few different errors to look for. 
Start by running "adb logcat" and watching what happens when the device boots up.

If you see something along the lines of 'DexOpt: mismatch dep signature' in the log it likely means that 
Android rejected our attempt to convince it that the new odex file was indeed valid. You should start by 
restoring the device to a working state.

Notes and Hints
---------------

 * adb reboot recovery - reboot into the recovery console
 * adb logcat - look at the log, useful for figuring out what went wrong
 * /sdcard/dex - where we do our on device work
 * /sdcard/dex/backup - where we place the original odex file before we modify it


