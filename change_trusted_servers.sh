#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#
# This program modifies the prefs.js file on the given device so that
# trusted marketplaces for installing signed privileged apps can be
# added/removed *FOR TESTING PURPOSES ONLY*.

set -e

device="$1"
servers="$2"

if [ -z "$device" -o -z "$servers" ]; then
  echo "usage: ./pull_cert.sh <device> <servers>"
  echo
  echo "<device> will usually be \"full_unagi\""
  echo "<servers> will usually be \"https://marketplace-dev.allizom.org,https://marketplace.allizom.org,https://marketplace.firefox.com\""
  exit 1
fi

# Be nice and wait for the user to connect the device
adb -s $device wait-for-device

# get prefs from phone
adb pull /system/b2g/defaults/pref/user.js user-old.js 

# remove old pref value
grep -v "dom\.mozApps\.signed_apps_installable_from" user-old.js > user.js
# add new pref value
echo "pref(\"dom.mozApps.signed_apps_installable_from\",\"$servers\");" >> user.js

#update prefs - remount file system as readwrite, push file, remount file system as readonly, reboot
adb shell mount -o rw,remount /system 
adb push ~/Downloads/user.js /system/b2g/defaults/pref/user.js 
adb shell mount -o ro,remount /system 
adb reboot

