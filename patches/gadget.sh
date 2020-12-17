#!/bin/sh

HOST="48:6f:73:74:50:43"
SELF="48:6f:73:59:39:C4"
IP='192.168.7.2'


cd /sys/kernel/config/usb_gadget/
mkdir neo
cd neo

echo 0x04b3 > idVendor
echo 0x4010 > idProduct

echo 0x0100 > bcdDevice #Device version
mkdir -p strings/0x409

echo "0000000000000000" > strings/0x409/serialnumber
echo "SECO" > strings/0x409/manufacturer
echo "UDOONEO" > strings/0x409/product


# Set config for RNDIS

mkdir -p configs/c.1/strings/0x409
echo "0x80" > configs/c.1/bmAttributes
echo 250 > configs/c.1/MaxPower
echo "Config 1: RNDIS" > configs/c.1/strings/0x409/configuration

echo "1" > os_desc/use
echo "0xcd" > os_desc/b_vendor_code
echo "MSFT100" > os_desc/qw_sign

mkdir -p functions/rndis.usb0
echo $SELF > functions/rndis.usb0/dev_addr
echo $HOST > functions/rndis.usb0/host_addr
echo "RNDIS" > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
echo "5162001" > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id


# Config 2: CDC ECM
mkdir -p configs/c.2/strings/0x409
echo "Config 2: ECM" > configs/c.2/strings/0x409/configuration
echo 250 > configs/c.2/MaxPower

mkdir -p functions/ecm.usb0
# first byte of address must be even
echo $HOST > functions/ecm.usb0/host_addr
echo $SELF0 > functions/ecm.usb0/dev_addr

# Create the CDC ACM function
mkdir -p functions/acm.gs0

# Link everything
ln -f -s configs/c.1 os_desc
ln -f -s functions/rndis.usb0 configs/c.1
ln -f -s functions/ecm.usb0 configs/c.2
ln -f -s functions/acm.gs0 configs/c.2

#Bind UDC
ls /sys/class/udc > UDC

#Bring network interface up
ifconfig usb0 up $IP

#Bring up serial console
exec /sbin/getty -L /dev/ttyGS0 115200 vt100
