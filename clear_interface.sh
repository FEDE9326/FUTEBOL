#!/bin/bash

echo "Insert the name of the network interface:[default=virtual0]";
read network_name;
if [ $network_name = ""]
then
    network_name="virtual1";
fi

echo "Insert the IP address your container will have:[deafault=192.168.5.49]";
read ip_address;
if [ $ip_address = ""]
then
    ip_address="192.168.5.49";
fi

bridge_name="BRIDGE-"$(echo $network_name | tr [a-z] [A-Z]);
internal_ip=$(sudo lxc-info -n usrp-container | grep "IP:" | head -1 | sed "s/[IP: ]//g");

sudo ifconfig $network_name down;
sudo ip link delete $network_name;
sudo iptables -t nat -D PREROUTING -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -D OUTPUT -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat --flush $bridge_name;
sudo iptables -t nat --delete-chain $bridge_name;

echo "DONE";
