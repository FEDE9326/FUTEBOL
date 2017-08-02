#!/bin/bash

sudo lxc-start -n usrp-container -d;
echo "DONE";
# Creation of a virtual bridge and a chain for IP traffic
echo "Creation of the virtual network interface...";
echo "Insert the name of the network interface:[default=virtual0]";
read network_name;
if [ $network_name = ""]
then
    network_name="virtual0";
fi
sudo ip link add $network_name link lxcbr0 type macvlan mode bridge;
echo "Insert the IP address your container will have:[deafault=192.168.5.48]";
read ip_address;
if [ $ip_address = ""]
then
    ip_address="192.168.5.48";
fi
bridge_name="BRIDGE-"$(echo $network_name | tr [a-z] [A-Z]);
internal_ip=$(sudo lxc-info -n usrp-container | grep "IP:" | head -1 | sed "s/[IP: ]//g");

sudo ip address add $ip_address/24 broadcast 192.168.5.255 dev $network_name;
sudo ip link set $network_name up;
sudo iptables -t nat -N $bridge_name;
sudo iptables -t nat -A PREROUTING -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -A OUTPUT -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -A $bridge_name -p all -j DNAT --to-destination $internal_ip;
sudo iptables -t nat -I POSTROUTING -p all -s  $internal_ip -j SNAT --to-source $ip_address;
echo "DONE";
