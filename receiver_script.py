# Python receiver 

import socket

UDP_IP = "ip_address"
UDP_PORT = 7124
sock = socket.socket(socket.AF_INET, # Internet
socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))
myfile = open("data_received", "a")
while True:
        data, addr = sock.recvfrom(1024) # buffer size is 1024 by
        myfile.write(data)
        print "received message:", data
	myfile.write(data)
	
myfile.close()

#Sender
#cd /usr/local/lib/uhd/examples
#./rx_samples_to_udp --freq 915e6 --rate 5e6 --gain 10 --addr 192.168.5.207 --nsamps 100000000




