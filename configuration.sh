#!/bin/bash

sudo add-apt-repository ppa:ubuntu-lxc/lxd-stable -y;
sudo apt-get update;
sudo apt-get install lxd;
sudo apt-get install cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1;
sudo apt-get install bridge-utils;
sudo apt-get update && sudo apt-get install -y protobuf-c-compiler libprotobuf-c0-dev protobuf-compiler libprotobuf-dev:amd64 gcc build-essential bsdmainutils python git-core asciidoc make htop git curl supervisor cgroup-lite libapparmor-dev libseccomp-dev libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev libaio-dev apparmor;
sudo apt-get install libnet1-dev;

git clone  https://github.com/xemul/criu.git criu;
cd criu;
make clean;
make;
sudo make install;
sudo apt-get install zfsutils-linux;

ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"

sudo sh -c 'echo "auto lo
iface lo inet loopback

auto ens3
iface ens3 inet manual

auto br0
iface br0 inet static
    address "'"${ip}"'"
    netmask 255.255.255.0
    gateway 192.168.5.1
    dns-nameservers 134.226.56.13
    bridge_ports ens3
    bridge_stp off
    bridge_fd 0
    bridge_maxwait 0
" > /etc/network/interfaces';

sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf;
sudo sysctl -p;

sudo lxd init;

newgrp lxd;
sudo usermod -a -G lxd ${USER};

lxc profile create bridged;
echo "name: bridged
config: 
  raw.lxc: lxc.console = none lxc.cgroup.devices.deny = c 5:1 rwm lxc.start.auto = lxc.start.auto = proc:mixed sys:mixed
  security.privileged: "true"
devices:
  ens3:
    nictype: bridged
    parent: br0
    type: nic" | lxc profile edit bridged;


