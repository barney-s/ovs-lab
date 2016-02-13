#!/bin/bash
#author: Bharanidharan Seetharaman
#

sudo ovs-vsctl add-br br0
sudo ovs-vsctl add-port br0 eth2
sudo ifconfig eth2 0
sudo ovs-vsctl add-port br0 vxlan0 -- set Interface vxlan0 type=vxlan options:remote_ip=192.168.101.20
sudo ovs-vsctl show 
