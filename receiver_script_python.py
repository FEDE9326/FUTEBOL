# Python receiver 

import socket


UDP_IP = "ip_address"
UDP_PORT = 7124
sock = socket.socket(socket.AF_INET, # Internet
socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))
while True:
        data, addr = sock.recvfrom(1024) # buffer size is 1024 by
        print "received message:", data

#Sender
#cd /usr/local/lib/uhd/examples
#./rx_samples_to_udp --freq 915e6 --rate 5e6 --gain 10 --addr 192.168.5.207 --nsamps 100000000




