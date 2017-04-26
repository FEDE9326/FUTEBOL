#!/bin/bash

sudo add-apt-repository ppa:ubuntu-lxc/lxd-stable;
sudo apt-get update;
sudo apt-get install lxd;
sudo apt-get install cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1;
newgrp lxd;
sudo usermod -a -G lxd federicobarusso;
sudo apt-get install bridge-utils;
sudo apt install criu;
