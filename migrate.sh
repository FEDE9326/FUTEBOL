#!/bin/bash

rm -rf /tmp/checkpoint

usage() {
  echo $0 docker/lxc container_name user@host.to.migrate.to
  exit 1
}

if [ "$(id -u)" != "0" ]; then
  echo "ERROR: Must run as root."
  usage
fi

if [ "$#" != "3" ]; then
  echo "Bad number of args."
  usage
fi

# elif statements
if [ "$1" == "docker"  ]
then
name=$2
host=$3

checkpoint_dir=/tmp/checkpoint

do_rsync() {
  rsync -aAXHltzh --progress --numeric-ids --devices --rsync-path="sudo rsync" $1 $host:$1
}
container_id=`docker ps -aqf "name=$name"`
echo $container_id
# we assume the same lxcpath on both hosts, that is bad.
DOCKERPATH=/var/lib/docker/containers

network_name="virtual1";
ip_address="192.168.5.49";
bridge_name="BRIDGE-"$(echo $network_name | tr [a-z] [A-Z]);
internal_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' receiver);

echo "checkpointing..."
docker checkpoint create --checkpoint-dir=/tmp $name checkpoint

echo "turning off the network in me..."
sudo ifconfig $network_name down;
sudo ip link delete $network_name;
sudo iptables -t nat -D PREROUTING -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -D OUTPUT -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -D POSTROUTING -p all -s $internal_ip -j SNAT --to-source $ip_address;
sudo iptables -t nat --flush $bridge_name;
sudo iptables -t nat --delete-chain $bridge_name;

echo "rsyncs..."
do_rsync $DOCKERPATH/$container_id*/
do_rsync $checkpoint_dir/
sleep 0.2
echo "restore checkpoint..."
ssh -t $host "docker start --checkpoint-dir=/tmp --checkpoint=checkpoint $name"
echo "up interface..."
ssh -t $host "/root/up_interface_docker.sh"


elif [ "$1" == "lxc" ]
then

name=$2
host=$3

checkpoint_dir=/tmp/checkpoint

do_rsync() {
  rsync -aAXHltzh --progress --numeric-ids --devices --rsync-path="sudo rsync" $1 $host:$1
}

# we assume the same lxcpath on both hosts, that is bad.
LXCPATH=$(lxc-config lxc.lxcpath)

network_name="virtual1";
ip_address="192.168.5.49";
bridge_name="BRIDGE-"$(echo $network_name | tr [a-z] [A-Z]);
internal_ip=$(sudo lxc-info -n receiver | grep "IP:" | head -1 | sed "s/[IP: ]//g");

echo "checkpointing..."
lxc-checkpoint -n $name -D $checkpoint_dir -s -v;

echo "turning off the network in me..."
sudo ifconfig $network_name down;
sudo ip link delete $network_name;
sudo iptables -t nat -D PREROUTING -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -D OUTPUT -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -D POSTROUTING -p all -s $internal_ip -j SNAT --to-source $ip_address;
sudo iptables -t nat --flush $bridge_name;
sudo iptables -t nat --delete-chain $bridge_name;

echo "do rsync lxc comtainer..."
do_rsync $LXCPATH/$name/
echo "do rsync checkpoint..."
do_rsync $checkpoint_dir/
sleep 0.2
echo "restore checkpoint..."
ssh $host "sudo lxc-checkpoint -r -n $name -D $checkpoint_dir -v"
sleep 0.2
echo "wait the container runnung again..."
ssh $host "sudo lxc-wait -n u1 -s RUNNING"
echo "up interface..."
ssh -t $host "/root/up_interface.sh" # PAY attention if you ssh with another user

echo "migration done..."

fi
