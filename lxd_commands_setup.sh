#!/bin/bash

sudo add-apt-repository ppa:ubuntu-lxc/lxd-stable;
sudo apt-get update;
sudo apt-get install lxd;
sudo apt-get install cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1;
newgrp lxd;
sudo usermod -a -G lxd federicobarusso;
sudo apt-get update && sudo apt-get install -y protobuf-c-compiler libprotobuf-c0-dev protobuf-compiler libprotobuf-dev:amd64 gcc build-essential bsdmainutils python git-core asciidoc make htop git curl supervisor cgroup-lite libapparmor-dev libseccomp-dev libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf libnl-3-dev libcap-dev libaio-dev apparmor;
sudo apt-get install libnet1-dev;
git clone  https://github.com/xemul/criu.git criu;
cd criu;
make clean;
make;
sudo make install;
sudo apt-get install bridge-utils;
sudo nano /etc/network/interfaces;
sudo nano /etc/sysctl.conf;  #uncomment #net.ipv4.ip_forward=1
sudo sysctl -p;
