#!/bin/bash -x

SB_ID="${1:-0}" # Default to 0
TAP_DEV="fc-${SB_ID}-tap0"

# Setup TAP device that uses proxy ARP
MASK_LONG="255.255.255.252"
MASK_SHORT="/30"
FC_IP="$(printf '169.254.%s.%s' $(((4 * SB_ID + 1) / 256)) $(((4 * SB_ID + 1) % 256)))"
TAP_IP="$(printf '169.254.%s.%s' $(((4 * SB_ID + 2) / 256)) $(((4 * SB_ID + 2) % 256)))"
FC_MAC="$(printf '02:FC:00:00:%02X:%02X' $((SB_ID / 256)) $((SB_ID % 256)))"
sudo ip link del "$TAP_DEV" 2> /dev/null || true
sudo ip tuntap add dev "$TAP_DEV" mode tap
sudo sysctl -w net.ipv4.conf.${TAP_DEV}.proxy_arp=1 > /dev/null
sudo sysctl -w net.ipv6.conf.${TAP_DEV}.disable_ipv6=1 > /dev/null
sudo ip addr add "${TAP_IP}${MASK_SHORT}" dev "$TAP_DEV"
sudo ip link set dev "$TAP_DEV" up

#iperf3 -B $TAP_IP -s > /dev/null 2>&1 &

sudo iptables -A FORWARD -i $TAP_DEV -o $HOST_DEV -j ACCEPT

#external connections
#for ssh
sudo iptables -t nat -I PREROUTING -p tcp --dport $((BASE_PORT_SSH + SB_ID)) -j DNAT --to $FC_IP:22
#for iperf3
sudo iptables -t nat -I PREROUTING -p tcp --dport $((BASE_PORT_IPERF + SB_ID)) -j DNAT --to $FC_IP:5201
sudo iptables -t nat -I PREROUTING -p tcp --dport $((BASE_PORT_SERVER + SB_ID)) -j DNAT --to $FC_IP:11211
sudo iptables -I FORWARD -m state -d $FC_IP --state NEW,RELATED,ESTABLISHED -j ACCEPT


