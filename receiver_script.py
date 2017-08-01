# Python receiver 

import socket


UDP_IP = "ip_address"
UDP_PORT = 7124
sock = socket.socket(socket.AF_INET, # Internet
socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))
<<<<<<< HEAD:receiver_script.py
with open("data_received", "a") as myfile:
=======
myfile = open("data_received", "a")
>>>>>>> ef0ba35e226ecbabddcaefa634a6fc1de1494a4a:receiver_script.py
while True:
        data, addr = sock.recvfrom(1024) # buffer size is 1024 by
        myfile.write(data)
        print "received message:", data
<<<<<<< HEAD:receiver_script.py
	myfile.write(data)
	

=======
myfile.close()
>>>>>>> ef0ba35e226ecbabddcaefa634a6fc1de1494a4a:receiver_script.py
#Sender
#cd /usr/local/lib/uhd/examples
#./rx_samples_to_udp --freq 915e6 --rate 5e6 --gain 10 --addr 192.168.5.207 --nsamps 100000000




