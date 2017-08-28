FROM ubuntu:16.04
RUN apt-get update && apt-get install -y \
        wget \
        python \
        net-tools \
        && wget https://raw.githubusercontent.com/FEDE9326/FUTEBOL/master/receiver_script.py \ 
        && cp ./receiver_script.py /root/ \
        && chmod ugo+x /root/receiver_script.py 
EXPOSE 1:65535
CMD ["/root/receiver_script.py","2e5","12000000","1"]
