#!/usr/bin/python

# Python receiver

import socket
import os
import sys
import threading
import time
import json

stop = 0
rate = sys.argv[1]
nsamps = sys.argv[2]
iteration = 0
sleep_time = 4

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
        return


f = os.popen('ifconfig eth0 | grep "inet\ addr" | cut -d: -f2 | cut -d" " -f1')
IP_REC = f.read()
#UDP_IP_SEND = "192.168.5.86"
UDP_PORT_rec = 7124
#UDP_PORT_send = 4567
TCP_IP = "192.168.5.48"
TCP_PORT = 7890
wait_time = 2

sock_rec = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
sock_rec.bind((IP_REC, UDP_PORT_rec))
sock_rec.settimeout(wait_time)

#sock_send = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_tcp = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
sock_tcp.connect((TCP_IP,TCP_PORT))

try:
        sock_tcp.sendall("start")
except socket.error:
        print "Network errors"
sock_tcp.close()

t = threading.Thread(target=receive_stop)
t.start()

before = os.popen("netstat -suno | grep 'packets received' | awk '{print $1}'")
UDP_before = int(before.read())
n_packets = 0
diz={}
while stop == 0:
        try:
                data = sock_rec.recvfrom(1472) # buffer size is 1024 by
                n_packets = n_packets + 1
                diz[time.time()] = n_packets
        except socket.error:
                print "I'm not receiving data..."

#sock_send.sendto(data, (UDP_IP_SEND,UDP_PORT_send))
        #print "received message:", stop

after = os.popen("netstat -suno | grep 'packets received' | awk '{print $1}'")
UDP_after = int(after.read())

f = open("results_"+rate+"_"+nsamps+".dat","a")
f.write(iteration + " " + rate + " " + nsamps + " " + str(n_packets) + "\n")
f.close()

f2 = open("trend_"+rate+"_"+nsamps+".dat","a")
f2.write(json.dumps(diz))
f2.close()
