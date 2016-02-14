# author: bharanidharan seetharaman
#
# Topology
# -------------
#
# vxlan via same interface
#
#    attacker   sensor    
#       |         |       
#    ---+---------+----+-----sens0
#                      |
#                      gw
#                      |
#    ---+---------+----+-----shdw0
#       |         |
#     shadow     shvtep
#
#

# VM Instance definitions:
# ========================

VMInstances = [
 { :vmname => :attacker, :provisioning => [{:puppet => 'site.pp'}]}, 
 { :vmname => :sensor,   :provisioning => [{:puppet => 'site.pp'}, {:shell => "/vagrant/shared/demo02/sensor.sh"}]},
 { :vmname => :gw,       :provisioning => [{:puppet => 'site.pp'}, {:shell => "/vagrant/shared/demo02/gw.sh"}]},
 { :vmname => :shvtep,   :provisioning => [{:puppet => 'site.pp'}, {:shell => "/vagrant/shared/demo02/shvtep.sh"}]},
 { :vmname => :shadow,   :provisioning => [{:puppet => 'site.pp'}, {:shell => "/vagrant/shared/demo02/shadow.sh"}]}
]



# openvswitch bridge config:
# ==========================

Bridges = [ 
  { :name => :sens0, :ip_prefix => '192.10.10.0', :ip_last => 2, :mac_prefix => '02:AB', :hosts => [ "gw", "attacker", "sensor" ] , :promiscous => ["sensor"]},
  { :name => :shdw0, :ip_prefix => '192.30.30.0', :ip_last => 2, :mac_prefix => '02:AB', :hosts => [ "gw", "shvtep", "shadow" ], :promiscous => ["shvtep"]} 
]


