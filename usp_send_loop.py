#!/usr/bin/python


import socket
import os
import sys
import time
import subprocess

rate = sys.argv[1]
nsamps = sys.argv[2]

REC_ADDRESS = "192.168.5.49"
TCP_PORT = "7890"
cmd = "/usr/local/lib/uhd/examples/rx_samples_to_udp --freq 915e6 --rate " + rate + "--gain 10 --addr " +  REC_ADDRESS + "--nsamps " + nsamps

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(REC_ADDRESS,TCP_PORT)

s.listen()
connection, client_adress = s.accept()


try: 
	while True:
		data=connection.recv(16)
		if data=="start":
			break
		else:
			print "waiting for starting..."
			time.sleep(1)
	
before = os.popen("netstat --udp -i | grep eth0 | awk '{print $8}'")
UDP_before= before.read()

# RUNNING the command
p = subprocess.Popen(cmd)
print "running the script..."
p.wait()

after = os.popen("netstat --udp -i | grep eth0 | awk '{print $8}'")
UDP_after = after.read()

f=open("results_"+rate+"_"+nsamps+".dat","w")
f.write(rate+" "+nsamps+" "+UDP_after-UDP_before)
f.close()

s.close()
