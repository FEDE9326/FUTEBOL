#!/bin/bash

network_name="virtual1";
sudo ip link add $network_name link lxcbr0 type macvlan mode bridge;
ip_address="192.168.5.49";
bridge_name="BRIDGE-"$(echo $network_name | tr [a-z] [A-Z]);
internal_ip=$(sudo lxc-info -n receiver | grep "IP:" | head -1 | sed "s/[IP: ]//g");

sudo ip address add $ip_address/24 broadcast 192.168.5.255 dev $network_name;
sudo ip link set $network_name up;
sudo iptables -t nat -N $bridge_name;
sudo iptables -t nat -A PREROUTING -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -A OUTPUT -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -A $bridge_name -p all -j DNAT --to-destination $internal_ip;
sudo iptables -t nat -I POSTROUTING -p all -s  $internal_ip -j SNAT --to-source $ip_address;
