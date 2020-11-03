#!/bin/bash

first=${1}
second=${2}
op=${3:-I}
set -x
sudo iptables -${op} FORWARD -i ${first} -o ${second} -j ACCEPT
sudo iptables -${op} FORWARD -i ${second} -o ${first} -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -${op} POSTROUTING -o ${second} -j MASQUERADE

sudo iptables -${op} FORWARD -i ${second} -o ${first} -j ACCEPT
sudo iptables -${op} FORWARD -i ${first} -o ${second} -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -${op} POSTROUTING -o ${first} -j MASQUERADE
