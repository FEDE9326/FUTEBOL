#!/bin/bash
sudo apt-get update;
sudo apt install qemu-kvm libvirt-bin;
sudo apt install virtinst;
sudo apt-get install lxc;
sudo apt-get install cgroup-bin cgroup-lite cgroup-tools cgroupfs-mount libcgroup1;

echo 'description "mount available cgroup filesystems"
author "Serge Hallyn <serge.hallyn@canonical.com>"

start on mounted MOUNTPOINT=/sys/fs/cgroup

pre-start script
test -x /bin/cgroups-mount || { stop; exit 0; }
test -d /sys/fs/cgroup || { stop; exit 0; }
/bin/cgroups-mount
cgconfigparser -l /etc/cgconfig.conf
end script

post-stop script
if [ -x /bin/cgroups-umount ]
then
    /bin/cgroups-umount
fi
end script' > sudo /etc/init/cgroup-lite.conf;

echo 'mount {
cpuacct = /cgroup/cpuacct;
memory = /cgroup/memory;
devices = /cgroup/devices;
freezer = /cgroup/freezer;
net_cls = /cgroup/net_cls;
blkio = /cgroup/blkio;
cpuset = /cgroup/cpuset;
cpu = /cgroup/cpu;
}

group limitcpu{
  cpu {
    cpu.shares = 400;
  }
}

group limitmem{
  memory {
    memory.limit_in_bytes = 512m;
  }
}

group limitio{
  blkio {
    blkio.throttle.read_bps_device = "252:0         2097152";
  }
}

group browsers {
    cpu {
#       Set the relative share of CPU resources equal to 25%
    cpu.shares = "256";
}
memory {
#       Allocate at most 768M of memory to tasks
        memory.limit_in_bytes = "512m";
#       Apply a soft limit of 512 MB to tasks
        memory.soft_limit_in_bytes = "384m";
    }
}

group media-players {
    cpu {
#       Set the relative share of CPU resources equal to 25%
        cpu.shares = "256";
    }
    memory {
#       Allocate at most 256M of memory to tasks
        memory.limit_in_bytes = "256m";
#       Apply a soft limit of 196 MB to tasks
        memory.soft_limit_in_bytes = "128m";
    }
}

cgconfigparser -l /etc/cgconfig.conf' > sudo /etc/cgconf.conf;

sed 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1"/g' /etc/default/grub;

sudo update-grub;

sudo cgcreate -a federicobarusso -g memory,cpu:groupname;

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

sudo virsh -c lxc:// "$name".xml;
sudo virsh -c lxc:// start "$name";
sudo virsh -c lxc:// console "$name";



