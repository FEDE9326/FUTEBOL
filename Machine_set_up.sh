#!/bin/bash
sudo apt-get update;
sudo apt install qemu-kvm libvirt-bin;
sudo apt install virtinst;
sudo apt-get install lxc;
sudo apt-get install cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1;
sudo mkdir -p /sys/fs/cgroup/systemd;
sudo mount -t cgroup -o none,name=systemd systemd /sys/fs/cgroup/systemd;





