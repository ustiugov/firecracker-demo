#!/bin/bash

COUNT=`ls /sys/class/net/ | wc -l`

killall iperf3
killall firecracker

for ((i=0; i<COUNT; i++))
do
  ip link del fc-$i-tap0 2> /dev/null &
done

rm -rf output/*
rm -rf /tmp/firecracker-sb*

# DMITRII
# Restore ephemeral port range, iptables and prohibit IP forwarding
sudo sysctl -w net.ipv4.ip_local_port_range="32768 60999"
sudo iptables -t nat -F
sudo sh -c "echo 0 > /proc/sys/net/ipv4/ip_forward" # usually the default

