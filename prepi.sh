#!/usr/bin/bash

if [[ ! $1 ]] ; then
    echo "no arguments provided"
    exit
fi

if [[ ! -d $1 ]] ; then
    echo "directory does not exist (have you mounted it?)"
    exit
fi


echo "[Unit]
Description=FirstBoot
After=network.target
Before=rc-local.service
ConditionFileNotEmpty=/boot/firstboot.sh

[Service]
ExecStart=/boot/firstboot.sh
ExecStartPost=/bin/mv /boot/firstboot.sh /boot/firstboot.sh.done
Type=oneshot
RemainAfterExit=no

[Install]
WantedBy=multi-user.target" > "$(dirname $1)/rootfs/lib/systemd/system/firstboot.service"

cp $2 "${1}/firstboot.sh"

touch "${1}/ssh"

echo "dtoverlay=dwc2" >> "${1}/config.txt"

sed -i "s/rootwait/rootwait modules-load=dwc2,g_ether/" "${1}/cmdline.txt"

echo "country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid=\"SSID\"
    psk=\"PSK\"
}" > "${1}/wpa_supplicant.conf"

cd "$(dirname $1)/rootfs/etc/systemd/system/multi-user.target.wants"
ln -s "$(dirname $1)/rootfs/lib/systemd/system/firstboot.service" .
