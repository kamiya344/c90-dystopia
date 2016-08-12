#!/bin/bash

WAN_IF=enp3s0
LAN_IF=enp1s0f0

WAN_IF_IP=192.168.200.40
LAN_IF_IP=192.168.210.254

LAN_IP=192.168.210.0/24
WAN_IP=192.168.200.0/24

# Flush all rules
iptables -F
iptables -t nat -F
iptables -X

# default policy
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# allow localhost connection and icmp
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

# allow related connection
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow input from LAN
iptables -A INPUT -i ${LAN_IF} -p udp --sport 67:68 --dport 67:68 -j ACCEPT
iptables -A INPUT -i ${LAN_IF} -s ${LAN_IP} -p tcp -m multiport --dports 22,53,80,3128 -j ACCEPT
iptables -A INPUT -i ${LAN_IF} -s ${LAN_IP} -p udp -m multiport --dports 22,53,80,3128 -j ACCEPT

# only ssh and http(s) are allowed
iptables -A INPUT -i ${WAN_IF} -p tcp --dport 22 -j ACCEPT

# accept forward request from LAN ip range
iptables -A FORWARD -i ${LAN_IF} -s ${LAN_IP} -o ${WAN_IF} -d ${WAN_IP} -j ACCEPT

# masquerade LAN ip to WAN IF ip address
iptables -t nat -A POSTROUTING -s ${LAN_IP} -o ${WAN_IF} -j MASQUERADE

# never forgive you
iptables -I INPUT -m mac --mac-source 50:7b:9d:90:1c:c1 -j DROP
iptables -I FORWARD -m mac --mac-source 50:7b:9d:90:1c:c1 -j DROP
