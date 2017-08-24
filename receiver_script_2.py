#!/usr/bin/python

# Python receiver

import socket
import os
import sys
import threading
import time

stop = 0
stat=[]
frequency=0.01
rate = sys.argv[1]
nsamps = sys.argv[2]
iteration = sys.argv[3]
sleep_time = 4
PACKET_SIZE = 1472
#UDP_IP_SEND = "192.168.5.86"
UDP_PORT_rec = 7124
#UDP_PORT_send = 4567
TCP_IP = "192.168.5.48"
TCP_PORT = 7890
wait_time = 2
lock = threading.Lock()

def receive_stop():
        print "running the thread..."
        sock_tcp = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        sock_tcp.bind((IP_REC,TCP_PORT))
        sock_tcp.listen(1)
        connection, client_address = sock_tcp.accept()

        global stop

        while True:
                data=connection.recv(16)
                if data == "stop":
                        print "collecting the last packets..."
                        time.sleep(sleep_time)
                        stop = 1
                        break
        sock_tcp.close()
	return

def packet_trend():
        
        global stop,n_packets,stat
        while stop == 0:
		with lock:
                	stat.append(n_packets)
                time.sleep(frequency)
        
                

if __name__ == '__main__':
	f = os.popen('ifconfig eth0 | grep "inet\ addr" | cut -d: -f2 | cut -d" " -f1')
	IP_REC = f.read()
	

	sock_rec = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
	sock_rec.bind((IP_REC, UDP_PORT_rec))
	sock_rec.settimeout(wait_time)

	t = threading.Thread(target=receive_stop)
	t.start()
	t2 = threading.Thread(target=packet_trend)
	t2.start()

	n_packets=0

	while stop == 0:

		try:
			data = sock_rec.recvfrom(PACKET_SIZE)
			with lock:
				n_packets=n_packets+1
		except socket.error:
			print "I'm not receiving data..."

	sock_rec.close()


	f = open("results_"+rate+"_"+nsamps+".dat","a")
	f.write(iteration + " " + rate + " " + nsamps + " " + str(n_packets) + "\n")
	f.close()
	f2 = open("packet_trend.dat","a")
	f2.write(stat)
	f2.close()
