FROM ubuntu:latest
RUN apt update && apt upgrade && apt install -y \
    iproute2 \
    iperf3 \
    netbase \
    vim \
    inetutils-ping \
    ssh
WORKDIR /root
COPY run.sh .
RUN chmod 777 run.sh
ENTRYPOINT [ "/root/run.sh" ]
