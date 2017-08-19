#!/bin/bash

iteration=100
rate=2e5
nsamps=12000000

technology="lxc"
#technology="docker"

container_name="receiver"
other_container_name="usrp2"
user="root"
OTHER_REC_IP="192.168.5.75"
CONATINER_IP="192.168.5.49"
MY_IP="192.168.5.153"

sim_time=60
time_for_migration=10
wait_time=sim_time-time_for_migration

#PRELIMINARY OPERATIONS

#sudo ssh-keygen -t rsa
#key=$('cat /root/.ssh/id_rsa2')
#sudo lxc-attach -n receiver -- echo $key >> /root/.ssh/authorized_keys
#sudo ssh -i /root/.ssh/id_rsa2 root@192.168.5.49 
./network_config_rec.sh
internal_ip=$(sudo lxc-info -n receiver | grep "IP:" | head -1 | sed "s/[IP: ]//g")

for (( i=1; i<=iteration; i++))
do
	
  sudo ssh user@OTHER_REC_IP -- lxc-attach -n $other_container_name -- ./usp_send_loop_2.py $rate $nsamps $i
	#TODO check if can be checkpointed
	sudo ssh root@$CONATINER_IP -- nohup ./receiver_script.py $rate $nsamps &
	
	sleep $time_for_migration
	start_migration=$(date +"%T.%6N")
	sudo ./migrate.sh $technology $container_name $user@$OTHER_REC_IP
	end_migration=$(date +"%T.%6N")

	start=$(echo $start_migration | awk -F ":" '{print $3}')
	end=$(echo $end_migration | awk -F ":" '{print $3}')

	echo "$rate $nsamps $time_for_migration $start $end" >> results_$rate_$nsamps.dat 
	sleep wait_time

	end=false

	while [ "$end" = false ]; do
		PID=$(sudo ssh root@192.168.5.49 -- ps -el | grep receiver_script | awk {'print $4'})
		if [ -z "$PID" ]; do
			echo "program has terminated..."
			end=true
		else
			sleep 2
		done
	done

	sleep 5

	sudo ssh user@OTHER_REC_IP -- ./clear_interface.sh
	sudo ssh user@OTHER_REC_IP -- lxc-stop -n receiver

	./network_config_rec.sh

done


#HOW TO SSH WITHOUT PASSWORD

# CLIENT and SERVER same user CASE
# CLIENT ssh-keygen -t rsa and save the key into /home/user/.ssh
# CLIENT cat id_rsa.pub copy
# SERVER paste into /home/user/.ssh/authorized_keys
# SERVER sudo /etc/init.d/ssh restart
# CLIENT (sudo) ssh -i /home/user/.ssh/id_rsa user@SERVERIP

# EVERYTHING in ROOT IF YOU TYPE COOMANDS LIKE sudo .... then just sudo ssh root@ip

#ROOT MANUALLY SSH INSIDE FOR THE FIRST TIME TO ECDSA KEY FINGERPRINT

#CLEAR INTERFACE UP INTERFACE MUST BE INSIDE /ROOT/ OF THE DESTINATION
