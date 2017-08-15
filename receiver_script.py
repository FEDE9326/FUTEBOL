# Python receiver 

#!/usr/bin/python

import socket
import os
import sys
import socket.timeout as TimeoutException

rate = sys.argv[1]
nsamps = sys.argv[2]

f = os.popen('ifconfig eth0 | grep "inet\ addr" | cut -d: -f2 | cut -d" " -f1')
UDP_IP_REC = f.read()
#UDP_IP_SEND = "192.168.5.86"
UDP_PORT_rec = 7124
#UDP_PORT_send = 4567
TCP_IP = "192.168.5.48"
TCP_PORT = 7890

wait_time=10

sock_rec = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sock_rec.bind((UDP_IP, UDP_PORT))
sock_rec.settimeout(wait_time)

#sock_send = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_tcp = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
sock_tcp.bind(REC_ADDRESS,TCP_PORT)

sock_tcp.listen()
connection, client_adress = sock_tcp.accept()

try:
	sock_tcp.sendall("start")
except socket.error:
	print "Network errors"

before = os.popen("netstat --udp -i | grep eth0 | awk '{print $4}'")
UDP_before= before.read()

while True:
		try:
       		data = sock_rec.recvfrom(1024) # buffer size is 1024 by
       	except TimeoutException:
       		print "Timeout exiting"
       		break
        	#sock_send.sendto(data, (UDP_IP_SEND,UDP_PORT_send))
        # print "received message:", data

after = os.popen("netstat --udp -i | grep eth0 | awk '{print $4}'")
UDP_after = after.read()

f=open("results_"+rate+"_"+nsamps+".dat","w")
f.write(rate+" "+nsamps+" "+UDP_after-UDP_before)
f.close()





