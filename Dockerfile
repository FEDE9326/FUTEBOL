FROM ubuntu:16.04
RUN apt-get update && apt-get install -y \
        wget \
        python \
        && wget https://raw.githubusercontent.com/FEDE9326/FUTEBOL/master/receiver_script_2.py \ 
        && cp ./receiver_script_2.py /root/ \
        && chmod ugo+x /root/receiver_script_2.py
