#!/bin/sh
## Intro/overview and Start hold
echo "This script will disable all Ezlo services on this hub and export your interfaces over IP."
echo "ZWave will be exported on port 3333"
echo "Zigbee will be exported on port 3300"
read -rsp $'Press any key to start conversion...\n' -n1 key

## Disable services rather then delete for backwards compatability
echo "Disabling services"
/etc/init.d/connection-checker-runner disable
/etc/init.d/ha-camerasd disable
/etc/init.d/ha-luad disable
/etc/init.d/ha-zigbeed disable
/etc/init.d/ha-zwaved disable
/etc/init.d/firmware disable

## Install packages locally
## Wget is here to have a functioning version capable of SSL
## Pacakges need to be local due to wget not being capable of SSL links (Maybe curl?)
echo "Installing packages"
opkg install Packages/ser2net_3.5-3_arm_cortex-a7_neon-vfpv4.ipk
opkg install Packages/wget_1.19.5-6_arm_cortex-a7_neon-vfpv4.ipk

## Write Ser2Net config
echo "Writing ser2net config"
echo '3333:raw:0:/dev/ttyS0:115200 8DATABITS NONE 1STOPBIT' >> /etc/ser2net.conf
echo '3300:raw:0:/dev/ttyS2:57600 8DATABITS NONE 1STOPBIT' >> /etc/ser2net.conf

## Start configuration validation
echo "Starting ser2net and testing ports"

## ZWave check
if lsof -Pi :3333 -sTCP:LISTEN -t >/dev/null ; then
    echo "ZWave port online"
else
    echo "!ZWave port NOT online!"
fi

## Zigbee check
if lsof -Pi :3300 -sTCP:LISTEN -t >/dev/null ; then
    echo "Zigbee port online"
else
    echo "!Zigbee port NOT online!"
fi

## Device reboot confirmation
echo "It is recommended to reboot the device now to unload old service files."
read -rsp $'Press any key to reboot device, or CTRL+C to stop here...\n' -n1 key

## Reboot if any key was pressed
sleep 2
reboot