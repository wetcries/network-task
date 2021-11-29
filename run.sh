#!/bin/bash

TC=/sbin/tc

echo "--- add ingres and root qdiscs ---"
$TC qdisc add dev eth0 ingress
$TC qdisc add dev eth0 root handle 1: htb default 10

echo "--- add class with rate limit $LIMIT ---"
$TC class add dev eth0 parent 1: classid 1:1 htb rate $LIMIT

echo "--- add filter matching other zones (mask: 192.160.0.0/16) ---"
$TC filter add dev eth0 protocol ip parent 1: prio 10 u32 \
    match ip dst 192.160.0.0/16 \
    flowid 1:1

echo "--- add filter to drop ingress ICMP traffic from other zones ---"
# filter to drop ICMP traffic from src ip 192.160.0.0/16 subnet (from other clients)
$TC filter add dev eth0 protocol ip parent ffff: prio 10 u32 \
    match ip protocol 1 0xff \
    match ip src 192.160.0.0/16 \
    police rate 8bit burst 1 mtu 1k drop flowid :1

if [ $ZONE -ne 4 ]
then
echo "--- add filter to drop ingress SSH from zone 4 client ---"
# filter ssh client requests from zone 4
$TC filter add dev eth0 protocol ip parent ffff: prio 10 u32 \
    match ip dport 22 0xffff \
    match ip src 192.160.4.0/24 \
    police rate 8bit burst 1 mtu 1k drop flowid :1
fi

if [ $ZONE -eq 2 ]
then
echo "--- add class with rate limit 100% for zone 2 UDP traffic ---"
# UDP priority for zone 2 clients
$TC class add dev eth0 parent 1: classid 1:2 htb rate 100%
echo "--- add filter to prioritize UDP traffic ---"
$TC filter add dev eth0 protocol ip parent 1: prio 1 u32 \
    match ip protocol 17 0xff flowid 1:2
fi

# starting iperf server for tests
iperf3 -s -p 8080
