#!/bin/bash

network_name="virtual1";
ip_address="192.168.5.49";
bridge_name="BRIDGE-"$(echo $network_name | tr [a-z] [A-Z]);
internal_ip="172.17.0.2";

sudo ifconfig $network_name down;
sudo ip link delete $network_name;
sudo iptables -t nat -D PREROUTING -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -D OUTPUT -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -D POSTROUTING -p all -s  $internal_ip -j SNAT --to-source $ip_address;
sudo iptables -t nat --flush $bridge_name;
sudo iptables -t nat --delete-chain $bridge_name;

echo "DONE";
