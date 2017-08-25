FROM ubuntu:16.04
RUN apt-get update && apt-get install -y \
	wget \
	python \
RUN wget https://raw.githubusercontent.com/FEDE9326/FUTEBOL/master/receiver_script_2.py -P /root/receiver_script_2.py
RUN chmod ugo+x /root/receiver_script_2.py
