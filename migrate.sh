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

docker checkpoint create --checkpoint-dir=/tmp $name checkpoint

do_rsync $DOCKERPATH/$container_id*/
do_rsync $checkpoint_dir/

ssh -t $host "docker start --checkpoint-dir=/tmp --checkpoint=checkpoint $name"



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

lxc-checkpoint -n $name -D $checkpoint_dir -s -v

do_rsync $LXCPATH/$name/
do_rsync $checkpoint_dir/

ssh -t $host "sudo lxc-checkpoint -r -n $name -D $checkpoint_dir -v"
ssh -t $host "sudo lxc-wait -n u1 -s RUNNING"

fi