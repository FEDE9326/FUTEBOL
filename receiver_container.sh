#!/bin/bash

# Creating the receiver container
echo "Container named receiver creation...";
sudo sh -c 'echo "lxc.aa_allow_incomplete = 1
lxc.console = none
lxc.tty = 0
lxc.cgroup.devices.deny = c 5:1 rwm" >> /etc/lxc/default.conf';
sudo lxc-create -t ubuntu -f /etc/lxc/default.conf -n receiver;
sudo lxc-start -n receiver -d;

# Creation of a virtual bridge and a chain for IP traffic
echo "Creation of the virtual network interface...";
echo "Insert the name of the network interface:[default=virtual1]";
read network_name;
if [ $network_name = ""]
then
    network_name="virtual1";
fi
sudo ip link add $network_name link lxcbr0 type macvlan mode bridge;
echo "Insert the IP address your container will have:[deafault=192.168.5.49]";
read ip_address;
if [ $ip_address = ""]
then
    ip_address="192.168.5.49";
fi
bridge_name="BRIDGE-"$(echo $network_name | tr [a-z] [A-Z]);
internal_ip=$(sudo lxc-info -n receiver | grep "IP:" | head -1 | sed "s/[IP: ]//g");

sudo ip address add $ip_address/24 broadcast 192.168.5.255 dev $network_name;
sudo ip link set $network_name up;
sudo iptables -t nat -N $bridge_name;
sudo iptables -t nat -A PREROUTING -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -A OUTPUT -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -A $bridge_name -p all -j DNAT --to-destination $internal_ip;
sudo iptables -t nat -I POSTROUTING -p all -s  $internal_ip -j SNAT --to-source $ip_address;
echo "DONE";

echo "Installing packages inside the container...";
sudo lxc-attach -n receiver -- apt-get update;
sudo lxc-attach -n receiver -- apt-get install wget;
sudo lxc-attach -n receiver -- apt-get install python;
echo "Getting the receiver script...";
sudo lxc-attach -n receiver -- wget https://raw.githubusercontent.com/FEDE9326/FUTEBOL/master/receiver_script.py;
sudo lxc-attach -n receiver -- chmod u+x receiver_script.py;
sudo lxc-attach -n receiver -- sed -i 's/ip_address/'$internal_ip'/g' receiver_script.py;
echo "Starting the UDP packet receiving...they will be stored into 'data_received' file"
sudo lxc-attach -n receiver -- python ./receiver_script.py &



