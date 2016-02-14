Open vSwitch Samples
====================
Inspired from https://github.com/relaxdiego/ovs-lab

Requirements
------------
1. Ubuntu 14.04

Installation
------------
1. wget -O - https://raw.githubusercontent.com/barney-s/ovs-lab/master/setup_demo.sh | bash

Running
-------
cd ~/.installer_cache/ovs-lab

demo1:
cp shared/demo01/topology.rb topology.rb
vagrant up
vagrant ssh attacker
  ping 192.10.10.4
vagrant destroy

demo2:
cp shared/demo02/topology.rb topology.rb
vagrant up
vagrant ssh attacker
  ping 192.10.10.5
vagrant destroy

Vagrant Commands
----------------
vagrant up - create the OVS networks and VMs
vagrant suspend - suspend your VMs
vagrant halt - shut them down
vagrant destroy - cleanup the setup
vagrant status - view status
