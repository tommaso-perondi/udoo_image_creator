#!/bin/bash
#
# SECO MMC Flasher for SECO-C23
#
# Author: Ettore Chimenti <ettore.chimenti@seco.com>
#
# Copyright Seco SPA @ 2020
# SPDX-License-Identifier: GPL-2.0+
#

set -e

DEBUG=1
GPIO=86
IMAGE=/root/seco-image-minimal-ostree-runtime-seco-c23.wic

log(){
	if (( $DEBUG ))
	then
		echo $1
	fi
}
clean(){
	if mountpoint -q /mnt
	then
		umount /mnt
	fi
	sync
	if [ -d /sys/class/gpio/gpio$GPIO ]
	then
		echo 0 > /sys/class/gpio/gpio$GPIO/value
		echo $GPIO >/sys/class/gpio/unexport
	fi
}

trap clean INT TERM

#disable watchdog
echo -n 'V' > /dev/watchdog

#enable blinking led
blinkled(){
	set -e
	doner(){ export DONE=1 ; }
	trap doner TERM
	echo $GPIO > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio$GPIO/direction
	until (( $DONE ))
	do
		echo 1 > /sys/class/gpio/gpio$GPIO/value
		sleep 0.5
		echo 0 > /sys/class/gpio/gpio$GPIO/value
		sleep 0.5
	done
	echo 0 > /sys/class/gpio/gpio$GPIO/value
}
blinkled &
GPIOPID=$!

savecerts(){
if [ -d /tmp/seco-iot ]
then
	rm -r /tmp/seco-iot/
fi

if [ -b /dev/mmcblk0p3 ]
then
	log "Copying certificates..."

	if ! mount /dev/mmcblk0p3 /mnt
	then
		log "Mount failed, maybe it is a fresh install?"
		return
	fi

	# check old path
	if [ -d /mnt/seco-iot ] && [ ! -L /mnt/seco-iot ]
	then
		CERTDIR=seco-iot
	else
		CERTDIR=lib/seco-iot
	fi

	if ! cp -a /mnt/$CERTDIR /tmp/
	then
		log "Copy failed"
	fi

	umount /mnt
	log "Copied!"
fi
}

savecerts

#flash
log "Flashing..."
dd if=${IMAGE} of=/dev/mmcblk0 bs=1M
sync
partprobe
log "Done Flashing!"

recopycerts(){
if [ -b /dev/mmcblk0p3 ]
then
	log "Copying back..."

	if ! mount /dev/mmcblk0p3 /mnt
	then
		log "Remount failed"
		return
	fi

	# remove old dir and copy
	rm -rf /mnt/var/seco-iot
	if ! cp -a /tmp/seco-iot /mnt/lib/
	then
		log "Copy failed"
	fi

	umount /mnt
	log "Copied Back!"
fi
}
recopycerts

kill $GPIOPID
