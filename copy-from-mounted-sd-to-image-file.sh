#!/bin/bash

if [[ $1 = "-?" || $1 = "--help" || $1 != "" ]]; then

	echo "This script is for copying from a mounted USB VFAT drive to an image file. It is run interactively (no parameters - it will prompt you for inputs as needed). It will unmount the USB drive during the procedure (and leave it unmounted). It is essentially a convenient wrapper around dd.".
	exit
fi

# This reflects where mounted drives are found by default on Fedora
SOURCE=`mount | grep run/media/$USER | grep "type vfat" | awk '{print $3}'`

while [[ -z "$SOURCE" || $SOURCE = "/" || ( ! -d "$SOURCE" && ${SOURCE:0:7} != "/dev/sd" ) ]]; do
	read -p "Source ($SOURCE) not found or not suitable; please enter another directory or device path: " SOURCE
done

DESTINATION=""
while [[ -z "$DESTINATION" || -e "$DESTINATION" ]]; do
	read -p "Destination file ($DESTINATION) already exists or not yet entered; please enter another: " DESTINATION
done

if [[ ${SOURCE:0:7} != "/dev/sd" ]]; then
	echo "Using source directory (truncated list follows): $SOURCE"
	ls -l "$SOURCE" | head
	DEV=`mount | grep "$SOURCE" | cut -d' ' -f1`
	umount "$DEV"
	if [[ $? -ne 0 ]]; then
		echo "Failed to unmount $DEV: please close programs using it (lsof follows)"
		lsof | grep "$SOURCE"
		exit 2
	fi
else 
	echo "Using source device: $SOURCE"
	DEV=$SOURCE
	ls -l "$DEV"
fi
echo "Using destination file: $DESTINATION"

read -n 1 -p "Enter y/Y to proceed: " PROCEED

echo

if [[ $PROCEED != "y" && $PROCEED != "Y" ]]; then
	echo "Aborting at user request"
	exit
fi

if [[ ${DEV:0:7} != "/dev/sd" || ! -b $DEV ]]; then

	echo "Abort: could not find block device ($DEV) for $SOURCE"
	exit 1

fi

echo "Using device: $DEV"

dd if="$DEV" of="$DESTINATION" bs=32M status=progress

echo "Finished. You may wish to re-mount the SD card."
