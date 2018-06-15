#!/bin/bash

default(){

# clear
iptables -F -t filter
iptables -F -t nat
iptables -F -t mangle

## Delete chains not defaults
iptables -X
iptables -X -t nat
iptables -X -t mangle

iptables -P INPUT  DROP -t filter
iptables -P OUTPUT ACCEPT -t filter
iptables -P FORWARD DROP -t filter

# Drop Invalid Packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Allow Loopback Connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow Established and Related Incoming Connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow Established Outgoing Connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

}

local(){

# Allow All Incoming SSH
iptables -A INPUT  -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

}

internet(){

# internet
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD -s 172.16.0.0/24 -j ACCEPT
iptables -A FORWARD -d 172.16.0.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -o enp0s3 -s 172.16.0.0/24 -j MASQUERADE

}

forwarding(){

# Redireciona portas
iptables -A FORWARD -i enp0s8 -d 172.16.0.51/24 -j ACCEPT
iptables -A PREROUTING -t nat -p tcp -d 192.168.0.35 --dport 5001 -j DNAT --to 172.16.0.6:22
iptables -A PREROUTING -t nat -p tcp -d 192.168.0.35 --dport 80 -j DNAT --to 172.16.0.6:80
iptables -A PREROUTING -t nat -p tcp -d 192.168.0.35 --dport 5002 -j DNAT --to 172.16.0.3:22

}


iniciar(){

default
local
forwarding
internet

# ping

#Internal to External
#iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT

# Block an IP Address
#iptables -A INPUT -s 15.15.15.51 -j DROP

#Allow Incoming Rsync from Specific IP Address or Subnet
#iptables -A INPUT -p tcp -s 15.15.15.0/24 --dport 873 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -p tcp --sport 873 -m conntrack --ctstate ESTABLISHED -j ACCEPT

}

parar(){

iptables -F -t filter
iptables -F -t nat
iptables -F -t mangle

iptables -t filter -P INPUT ACCEPT
iptables -t filter -P OUTPUT ACCEPT
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -F
iptables -t nat -F

}


case $1 in
start|START|Start)iniciar;;
stop|STOP|Stop)parar;;
restart|RESTART|Restart)parar;iniciar;;
listar)iptables -t filter -nvL;;
*)echo "Execute o script com os parâmetros start ou stop ou restart";;
esac

