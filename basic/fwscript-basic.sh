#!/bin/bash

WAN_IF=enp3s0
LAN_IF=enp1s0f0

LAN_IP=192.168.210.0/24


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
iptables -A INPUT -i ${LAN_IF} -s ${LAN_IP} -j ACCEPT

# only ssh is allowed
iptables -A INPUT -i ${WAN_IF} -p tcp --dport 22 -j ACCEPT

# accept forward request from LAN ip range
iptables -A FORWARD -i ${LAN_IF} -s ${LAN_IP} -j ACCEPT

# masquerade LAN ip to WAN IF ip address
iptables -t nat -A POSTROUTING -s ${LAN_IP} -o ${WAN_IF} -j MASQUERADE
