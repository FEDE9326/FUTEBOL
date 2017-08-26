#!/usr/bin/python


import socket
import os
import sys
import time
import subprocess

rate = sys.argv[1]
nsamps = sys.argv[2]
sim_time = 60

f = os.popen('ifconfig eth0 | grep "inet\ addr" | cut -d: -f2 | cut -d" " -f1')
MY_ADDRESS = f.read()
REC_ADDRESS = "192.168.5.49"
TCP_PORT = 7890
ERROR_MESSAGE = "Connection refused"
cmd = '/usr/local/lib/uhd/examples/rx_samples_to_udp --freq 915e6 --rate ' + rate + ' --gain 10 --addr ' +  REC_ADDRESS + ' --nsamps ' + nsamps + ' | grep "Error: send: Connection refused"' 
lista = cmd.split(" ")
iteration = 0

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((MY_ADDRESS,TCP_PORT))

s.listen(1)
connection, client_adress = s.accept()

while True:
	data=connection.recv(16)
	if data=="start":
		break
	else:
		print "waiting for starting..."
		time.sleep(1)

connection.close()
s.close()
before = os.popen("netstat --udp -i | grep eth0 | awk '{print $8}'")
UDP_before = int(before.read())
# RUNNING the command

start = time.time()
p = subprocess.Popen(lista,stdout=subprocess.PIPE, stderr=subprocess.PIPE)
print "running the script..."
p.wait()

print "sending the stop command"
s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect((REC_ADDRESS,TCP_PORT))
s.sendall("stop")
s.close()

after = os.popen("netstat --udp -i | grep eth0 | awk '{print $8}'")
UDP_after = int(after.read())

f=open("results_"+rate+"_"+nsamps+".dat","a")
f.write(str(iteration) + " " + rate+" " + nsamps + " " + str(UDP_after-UDP_before) + "\n")
f.close()

s.close()
				

