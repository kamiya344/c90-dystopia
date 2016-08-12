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

# allow relatd connection 
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# allow input from LAN
iptables -A INPUT -i ${LAN_IF} -s ${LAN_IP} -j ACCEPT

# only ssh and http(s) are allowed 
iptables -A INPUT -i ${WAN_IF} -p tcp -m multiport --dports 22,80,443 -j ACCEPT

# accept forward request from LAN ip range
iptables -A FORWARD -i ${LAN_IF} -s ${LAN_IP} -o ${WAN_IF} -d ${WAN_IP} -j ACCEPT

# masquerade LAN ip to WAN IF ip address
iptables -t nat -A POSTROUTING -s ${LAN_IP} -o ${WAN_IF} -j MASQUERADE


# iptables -t nat -A PREROUTING -i ${LAN_IF} -p tcp -m multiport --dports 80,443 -j DNAT --to-destination ${LAN_IF_IP}:3128
# iptables -t nat -A PREROUTING -i ${LAN_IF} -p tcp -m multiport --dports 80,443 -j REDIRECT --to-port 3128

