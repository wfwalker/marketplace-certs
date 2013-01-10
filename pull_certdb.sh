#!/bin/sh
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#
# This program copies the certificate database from the device to a local
# directory. Usually it is used in conjunction with the other scripts in this
# directory as described in ./README.txt.

set -e

device="$1"
certdbdir="$2"

if [ -z "$device" -o -z "$certdbdir" ]; then
  echo "usage: ./pull_cert.sh <device> <output-directory>"
  echo
  echo "<device> will usually be \"full_unagi\""
  exit 1
fi

if [ -e "$certdbdir" ]; then
  echo output directory "$certdbdir" exists
  exit 1
fi

mkdir -p "$certdbdir"

# Be nice and wait for the user to connect the device
adb -s $device wait-for-device

profile=`adb -s $device shell ls data/b2g/mozilla | tr -d '\\r' | grep "\.default$"`

if [ -z "$profile" ]; then
  echo "foo"
  echo "No user profile found on device"
  exit 1
fi

adb -s $device pull data/b2g/mozilla/$profile/cert9.db   "$certdbdir/cert9.db"
adb -s $device pull data/b2g/mozilla/$profile/key4.db    "$certdbdir/key4.db"
adb -s $device pull data/b2g/mozilla/$profile/pkcs11.txt "$certdbdir/pkcs11.txt"
adb -s $device pull data/b2g/mozilla/$profile/prefs.js   "$certdbdir/prefs.js"

