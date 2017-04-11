#!/bin/bash
sudo apt-get update;
sudo apt install qemu-kvm libvirt-bin;
sudo apt install virtinst;
sudo apt-get install lxc;
sudo apt-get install cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1;
echo "Type your container's name (OS ubuntu): ";
read name;
sudo lxc-create -t ubuntu -n "$name";

echo "<domain type='lxc'>
  <name>"$name"</name>
  <memory>327680</memory>
  <os>
    <type>exe</type>
    <init>/sbin/init</init>
  </os>
  <vcpu>1</vcpu>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/lib/libvirt/libvirt_lxc</emulator>
    <filesystem type='mount'>
      <source dir='/var/lib/lxc/"$name"/rootfs'/>
      <target dir='/'/>
    </filesystem>
    <interface type='network'>
      <source network='default'/>
    </interface>
    <console type='pty'/>
  </devices>
</domain>" > "$name".xml;

sudo virsh -c lxc:// define "$name".xml;
sudo virsh -c lxc:// start "$name";
echo >> "Type sudo virsh -c lxc:// list --all to list all containers";
sudo virsh -c lxc:// console "$name";
