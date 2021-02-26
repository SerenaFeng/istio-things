#!/bin/bash
 
op=${1:-I}
 
sudo iptables -${op} FORWARD -s 192.168.3.0/24 -d 192.168.4.0/24 -j ACCEPT
sudo iptables -${op} FORWARD -s 192.168.4.0/24 -d 192.168.3.0/24 -j ACCEPT
sudo iptables -${op} FORWARD -s 192.168.3.0/24 -d 192.168.7.0/24 -j ACCEPT
sudo iptables -${op} FORWARD -s 192.168.7.0/24 -d 192.168.3.0/24 -j ACCEPT
sudo iptables -${op} FORWARD -s 192.168.7.0/24 -d 192.168.4.0/24 -j ACCEPT
sudo iptables -${op} FORWARD -s 192.168.4.0/24 -d 192.168.7.0/24 -j ACCEPT
