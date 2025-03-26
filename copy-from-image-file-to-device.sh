#!/bin/bash

if [[ $1 = "-?" || $1 = "--help" || $1 != "" ]]; then
	echo "This script is for copying from an image file to a raw device (found in /dev). It is run interactively (no parameters). i.e. it will prompt you for needed inputs when you run it. It is essentially a convenient wrapper with some extra checks around the 'dd' command (and hence must be run as root)."
	exit
fi

SOURCE=""
ls -l *.img
while [[ -z "$SOURCE" || $SOURCE = "/" || ! -f "$SOURCE" || ${SOURCE:0:7} = "/dev/sd" ]]; do
	read -p "Source ($SOURCE) not found or not suitable; please enter another file path: " SOURCE
done

DESTINATION=""

echo "Listing possible destination devices and creation times:"
ls -l /dev/sd*

while [[ -z "$DESTINATION" || ! -b "$DESTINATION" || ${DESTINATION:0:7} != "/dev/sd" ]]; do
	read -p "Destination device ($DESTINATION) does not exist, is not a device or not yet entered; please enter another: " DESTINATION
done

mount | cut -d' ' -f1 | grep -q ^$DESTINATION
if [[ $? -eq 0 ]]; then
	echo "$DESTINATION appears to be mounted; aborting"
	mount | grep ^$DESTINATION
	exit 4
fi

DEST_SIZE=`blockdev --getsize64 $DESTINATION`
if [[ -z $DEST_SIZE || $DEST_SIZE -lt $((3*1048576*1024)) || $DEST_SIZE -gt $((16*1048576*1024)) ]]; then
	echo "$DESTINATION has wrong size or could not be detected; aborting"
	echo $DEST_SIZE
	exit 5
else
	echo "$DESTINATION has good size ($((DEST_SIZE/1048576)) MB)"
fi

echo "Using source file: $SOURCE"
ls -l "$SOURCE"

echo "Using destination device: $DESTINATION"
ls -l "$DESTINATION"
sfdisk -l "$DESTINATION"

read -n 1 -p "Enter y/Y to proceed: " PROCEED

echo

if [[ $PROCEED != "y" && $PROCEED != "Y" ]]; then
	echo "Aborting at user request"
	exit
fi

dd if="$SOURCE" of="$DESTINATION" bs=32M status=progress

echo "Finished. You may wish to mount the SD card to test."
