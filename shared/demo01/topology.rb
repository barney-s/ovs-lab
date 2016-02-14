# author: bharanidharan seetharaman
#
# Topology
# -------------
#
# vxlan via separate interface
#
#                 +-------------------+
#                 |                   |
#    attacker   sensor                |
#       |         |                   |
#    ---+---------+-----sens0         |
#                                     |
#                                     |  
#    ---+---------+-----shdw0         |
#       |         |                   |
#     shadow     shvtep               |
#                 |                   |
#                 +-------------------+




#VM Instance definitions:
#========================

VMInstances = [
 { :vmname => :attacker, :ip => '192.168.101.10', :provisioning => [{:puppet => 'site.pp'}]}, 
 { :vmname => :sensor, :ip => '192.168.101.20', :provisioning => [{:puppet => 'site.pp'}, {:shell => "/vagrant/shared/demo01/sensor.sh"}]},
 { :vmname => :shvtep, :ip => '192.168.101.30', :provisioning => [{:puppet => 'site.pp'}, {:shell => "/vagrant/shared/demo01/shvtep.sh"}]},
 { :vmname => :shadow, :ip => '192.168.101.40', :provisioning => [{:puppet => 'site.pp'}, {:shell => "/vagrant/shared/demo01/shadow.sh"}]}
# { :vmname => :hname,    :box => 'precise64',   :ip => '192.168.101.20', :cpus =>1, :mem => 2048, :provisioning => [ {:role => 'sample'} ] }
]



#openvswitch bridge config:
#==========================

Bridges = [ 
  { :name => :sens0, :ip_prefix => '192.10.10.0', :ip_last => 2, :mac_prefix => '02:AB', :hosts => [ "attacker", "sensor"] , :promiscous => ["sensor"]},
  #{ :name => :dcc0,  :ip_prefix => '192.20.20.0', :ip_last => 2, :mac_prefix => '02:AB', :hosts => [ "sensor", "shvtep"] , :promiscous => []},
  { :name => :shdw0, :ip_prefix => '192.30.30.0', :ip_last => 2, :mac_prefix => '02:AB', :hosts => [ "shvtep", "shadow"], :promiscous => ["shvtep"]} 

]
