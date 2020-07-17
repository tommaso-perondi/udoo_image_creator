#!/bin/bash
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
# Author: Stefano Viola

H=`cat /sys/fsl_otp/HW_OCOTP_CFG0 |sed -e 's/0x//'`
L=`cat /sys/fsl_otp/HW_OCOTP_CFG1 |sed -e 's/0x//'`
SerialNumber=$H$L
SerialNumber=${SerialNumber^^}
Manufacturer="SECO-AIDILAB"
Product="UDOONEO"

#host_addr/dev_addr
#Should be "constant" for a particular unit, if not specified g_multi/g_ether will
#randomly generate these, this causes interesting problems in windows/systemd/etc..
#
#systemd: ifconfig -a: (mac = device name)
#enx4e719db78204 Link encap:Ethernet  HWaddr 4e:71:9d:b7:82:04 

host_vend="4e:71:9d"
dev_vend="4e:71:9e"

if [ -f /sys/class/net/eth0/address ]; then
        #concatenate a fantasy vendor with last 3 digit of onboard eth mac
        address=$(cut -d: -f 4- /sys/class/net/eth0/address)
elif [ -f /sys/class/net/wlan0/address ]; then
        address=$(cut -d: -f 4- /sys/class/net/wlan0/address)
else
        address="aa:bb:cc"
fi

host_addr=${host_vend}:${address}
dev_addr=${dev_vend}:${address}

unset root_drive
root_drive="$(cat /proc/cmdline | sed 's/ /\n/g' | grep root= | awk -F 'root=' '{print $2}' || true)"


g_network="iSerialNumber=${SerialNumber} iManufacturer=${Manufacturer}"
g_network+="iProduct=${Product} host_addr=${host_addr} dev_addr=${dev_addr}"

g_drive="cdrom=0 ro=0 stall=0 removable=1 nofua=1"

                #serial:
                #modprobe g_serial || true
boot_drive="${root_drive%?}1"
modprobe g_multi file=${boot_drive} ${g_drive} ${g_network}

exit 0

