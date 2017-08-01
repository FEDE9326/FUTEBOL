#!/bin/bash

# Apparmor setting and moving of the ens4 interface inside the container. The interface will be called eth1 and it will need to be activated. Also a static IP address should be set
echo '
###########################################################
# This script will install and run an lxc container	  #
# with the USRP Open-Source Toolchain (UHD and GNU Radio) #
###########################################################
'
echo 'Do you want to proceed?'
read answer;
if [[ $answer = "n" ]] || [[ $answer = "no" ]] ; then
  return;
fi

sudo sh -c 'echo "lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
lxc.aa_allow_incomplete = 1

lxc.network.type = phys
lxc.network.link = ens4
lxc.network.name = eth1" > /etc/lxc/default.conf';

# Creation of a basic ubuntu container
# TODO: Check of the name
echo "Container named usrp-container creation...";
sudo lxc-create ubuntu -n usrp-container;
echo "DONE";
echo "Starting the container";
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
echo "Insert the IP address your container will have:[deafault=192.168.5.50]";
read ip_address;
if [ $ip_address = ""]
then
    ip_address="192.168.5.50";
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

echo "Installing packages inside the container...";
sudo lxc-attach -n usrp-container -- apt-get update;
sudo lxc-attach -n usrp-container -- apt-get install wget -y;
sudo lxc-attach -n usrp-container -- wget http://www.sbrac.org/files/build-gnuradio; 
# In container you have root access let's delete this constraint into the script
sudo lxc-attach -n usrp-container -- sed -i '79,84d' ./build-gnuradio;

sudo lxc-attach -n usrp-container -- chmod a+x build-gnuradio; 
sudo lxc-attach -n usrp-container -- ./build-gnuradio;
echo "DONE";

echo "Configuration of the physical interface to the USRP...";

sudo lxc-attach -n usrp-container -- sudo sh -c 'echo "auto lo 
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
address 10.0.41.1
netmask 255.255.255.0
network 10.0.41.0
broadcast 10.0.41.255
gateway 10.0.41.1

" > /etc/network/interfaces';
sudo lxc-attach -n usrp-container -- ifconfig eth1 up;
sudo lxc-attach -n usrp-container -- reboot;

echo "DONE";
echo '
###########################################################
# 		End of the process!                       #
# 	In order to access the container type: 		  #
#							  #
# 	   sudo lxc-attach -n usrp-container 		  #
#							  #
#		Press any key to quit			  #
###########################################################
';
read end;



