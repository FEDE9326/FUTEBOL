#!/bin/bash
# TO set the LXC environemnt in the VM 
# sudo apt-get install lxc lxctl lxc-templates
# sudo apt-get install build-essential
# sudo apt-get install cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1;
# if lxc old kernels
# lxc.network.type = veth
# lxc.network.link = lxcbr0
# lxc.network.flags = up
# lxc.network.hwaddr = 00:16:3e:xx:xx:xx

# lxc.network.type = phys
# lxc.network.link = ens4
# lxc.network.name = eth1

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

# TODO Ceate a new profile not the default one to attach to the usrp-container. The other container (receiver) should not have access to the usrp!
sudo sh -c 'echo "lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
lxc.aa_allow_incomplete = 1

lxc.network.type = phys
lxc.network.link = ens4
lxc.network.name = eth1" > /etc/lxc/usrp.conf';

# Creation of a basic ubuntu container
# TODO: Check of the name
echo "Container named usrp-container creation...";
sudo lxc-create -t ubuntu -f /etc/lxc/usrp.conf -n usrp-container;
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

echo "Installing packages inside the container...";
sudo lxc-attach -n usrp-container -- apt-get update;
sudo lxc-attach -n usrp-container -- apt-get install wget -y;
sudo lxc-attach -n usrp-container -- apt-get install software-properties-common python-software-properties;
sudo lxc-attach -n usrp-container -- add-apt-repository ppa:ettusresearch/uhd;
sudo lxc-attach -n usrp-container -- apt-get update;
sudo lxc-attach -n usrp-container -- apt-get install libuhd-dev libuhd003 uhd-host;
sudo lxc-attach -n usrp-container -- apt-get install fftw3 fftw3-dev pkg-config;

echo "DONE";

echo "Configuration of the physical interface to the USRP...";

sudo lxc-attach -n usrp-container -- sudo sh -c 'echo "auto lo 
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
address 10.0.54.1
netmask 255.255.255.0
network 10.0.54.0
broadcast 10.0.54.255
gateway 10.0.54.1

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



