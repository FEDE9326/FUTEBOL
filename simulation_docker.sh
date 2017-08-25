#!/bin/bash

iteration=50
rate=2e5
nsamps=12000000

technology="docker"

container_name="receiver"
other_container_name="usrp2"
user="root"
OTHER_REC_IP="192.168.5.75"
CONATINER_IP="192.168.5.49"
MY_IP="192.168.5.153"
USRP_VM_IP="192.168.5.134"
sleep_time = 8
sim_time = 60
time_for_migration = 10
wait_time=$((sim_time-time_for_migration))

#PRELIMINARY OPERATIONS

#sudo ssh-keygen -t rsa
#key=$('cat /root/.ssh/id_rsa2')
#sudo lxc-attach -n receiver -- echo $key >> /root/.ssh/authorized_keys
#sudo ssh -i /root/.ssh/id_rsa2 root@192.168.5.49 

./network_config_rec_docker.sh
internal_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' receiver);

for (( i=1; i<=iteration; i++))
do
	sleep $sleep_time

  	sudo ssh $user@$USRP_VM_IP -- lxc-attach -n $other_container_name -- nohup ./usp_send_loop_2.py $rate $nsamps $i & #must be inside root in the container
	#TODO check if can be checkpointed
	sudo ssh root@$CONATINER_IP -- nohup /root/receiver_script_2.py $rate $nsamps $i &

	sleep $time_for_migration
	start_migration=$(date +"%T.%6N")
	sudo ./migrate.sh $technology $container_name $user@$OTHER_REC_IP
	end_migration=$(date +"%T.%6N")

	start=$(echo $start_migration | awk -F ":" '{print $3}')
	end=$(echo $end_migration | awk -F ":" '{print $3}')

	echo "$i $rate $nsamps $time_for_migration $start $end" >> results_$rate\_$nsamps.dat 
	sleep $wait_time

	end=false

	while [ "$end" = false ]; do
		PID=$(sudo ssh root@192.168.5.49 -- ps -el | grep receiver_script_2 | awk {'print $4'})
		if [ -z "$PID" ]; then
			echo "program has terminated..."
			end=true
		else
			echo "waiting the end of receiverscript..."
			echo $PID
			sleep 2
		fi
	done

	sleep 3

	sudo ssh $user@$OTHER_REC_IP -- ./clear_interface.sh
	sudo ssh $user@$OTHER_REC_IP -- docker stop receiver
	./network_config_rec_docker.sh

done

