#!/bin/bash
#author: Bharanidharan Seetharaman
#

vteppeer="192.30.30.3"
sudo ovs-vsctl add-br br0
sudo ovs-vsctl add-port br0 eth1
sudo ifconfig br0 up
sudo ifconfig br0 192.10.10.4
sudo ifconfig eth1 0
sudo route add $vteppeer/32 gw 192.10.10.2 dev br0
sudo ovs-vsctl add-port br0 vxlan0 -- set Interface vxlan0 type=vxlan options:remote_ip=$vteppeer
sudo ovs-vsctl show 
