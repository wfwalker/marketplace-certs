#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#
# This program replaces the certificate database on a device with the contents
# of a local certificate database. Usually it is used in conjunction with the
# other scripts in this directory as described in ./README.txt.

set -e

device="$1"
certdbdir="$2"

if [ -z "$device" -o -z "$certdbdir" ]; then
  echo "usage: ./pull_cert.sh <device> <input-directory>"
  echo
  echo "<device> will usually be \"full_unagi\""
  exit 1
fi

if [ ! -d "$certdbdir" ]; then
  echo input certdb directory "$certdbdir" does not exist
  exit 1
fi

echo hello

# Be nice and wait for the user to connect the device
adb -s $device wait-for-device

profile=`adb -s $device shell ls data/b2g/mozilla | tr -d '\\r' | grep "\.default$"`

if [ -z "profile" ]; then
  echo "No user profile found on device"
  exit 1
fi

echo "hello"

adb -s $device push "$certdbdir/cert9.db"   data/b2g/mozilla/$profile/cert9.db   
adb -s $device push "$certdbdir/key4.db"    data/b2g/mozilla/$profile/key4.db    
adb -s $device push "$certdbdir/pkcs11.txt" data/b2g/mozilla/$profile/pkcs11.txt 

