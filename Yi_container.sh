#/bin/bash
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
lxc.apparmor.profile=unconfined
lxc.cgroup.devices.allow = c 189:* rwm
lxc.mount.entry = /dev/bus/usb/ /dev/bus/usb/ none bind,optional,create=dir" > /etc/lxc/usrp.conf';

# Creation of a basic ubuntu container
# TODO: Check of the name
echo "Container named usrp-container creation...";
sudo lxc-create -t ubuntu -f /etc/lxc/usrp.conf -n usrp-container;
echo "DONE";
echo "Starting the container";
sudo lxc-start -n usrp-container -d;
echo "DONE";

echo "Installing packages inside the container...";
sudo lxc-attach -n usrp-container -- apt-get update;
sudo lxc-attach -n usrp-container -- apt-get install wget -y;
sudo lxc-attach -n usrp-container -- apt-get install software-properties-common python-software-properties;
sudo lxc-attach -n usrp-container -- add-apt-repository ppa:ettusresearch/uhd;
sudo lxc-attach -n usrp-container -- apt-get update;
sudo lxc-attach -n usrp-container -- apt-get install libuhd-dev libuhd003 uhd-host;
sudo lxc-attach -n usrp-container -- apt-get install fftw3 fftw3-dev pkg-config;
sudo lxc-attach -n usrp-container -- apt-get -y install build-essential git-core libboost-all-dev libfftw3-dev cmake libprotobuf-dev protobuf-compiler
sudo lxc-attach -n usrp-container -- git clone https://gitlab.com/zhangyith/srslte_phy.git;

echo "DONE build srslte_phy manually";
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



