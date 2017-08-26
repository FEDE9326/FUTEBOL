#!/bin/bash

#BEfore change default IP address here sudo nano /etc/default/docker with DOCKER_OPTS="--dns 134.226.56.13" then sudo /etc/init.d/docker restart

# Creation of the image
sudo docker build -t docker_receiver ./receiver_docker/

# Starting the container
sudo docker run -dit --name receiver docker_receiver
# for access the bash sudo 
#sudo docker run -dit --name receiver docker_receiver
#Creation of the virtual interface
network_name="virtual1";
sudo ip link add $network_name link docker0 type macvlan mode bridge;
ip_address="192.168.5.49";
bridge_name="BRIDGE-"$(echo $network_name | tr [a-z] [A-Z]);
internal_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' receiver);
sudo ip address add $ip_address/24 broadcast 192.168.5.255 dev $network_name;
sudo ip link set $network_name up;
sudo iptables -t nat -N $bridge_name;
sudo iptables -t nat -A PREROUTING -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -A OUTPUT -p all -d $ip_address -j $bridge_name;
sudo iptables -t nat -A $bridge_name -p all -j DNAT --to-destination $internal_ip;
sudo iptables -t nat -I POSTROUTING -p all -s  $internal_ip -j SNAT --to-source $ip_address;
