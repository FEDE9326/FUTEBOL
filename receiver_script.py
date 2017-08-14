# Python receiver 

import socket
import os

f = os.popen('ifconfig eth0 | grep "inet\ addr" | cut -d: -f2 | cut -d" " -f1')
UDP_IP_REC = f.read()
UDP_IP_SEND = "192.168.5.86"
UDP_PORT_rec = 7124
UDP_PORT_send = 4567

sock_rec = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sock_rec.bind((UDP_IP_SEND, UDP_PORT_rec))

sock_send = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

#myfile = open("data_received", "a")
while True:
        data, addr = sock_rec.recvfrom(1024) # buffer size is 1024 by
        sock_send.sendto(data, (UDP_IP_SEND,UDP_PORT_send))
        print "received message:", data
	      #myfile.write(data)
	
#myfile.close()

#Sender
#cd /usr/local/lib/uhd/examples
#./rx_samples_to_udp --freq 915e6 --rate 5e6 --gain 10 --addr 192.168.5.207 --nsamps 100000000



