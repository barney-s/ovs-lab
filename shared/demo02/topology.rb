# author: bharanidharan seetharaman
#


#VM Instance definitions:
#========================

VMInstances = [
 { :vmname => :attacker, :ip => '192.168.101.10', :provisioning => [{:puppet => 'site.pp'}]}, 
 { :vmname => :sensor, :ip => '192.168.101.20', :provisioning => [{:puppet => 'site.pp'}]},
 { :vmname => :shvtep, :ip => '192.168.101.30', :provisioning => [{:puppet => 'site.pp'}]},
 { :vmname => :shadow, :ip => '192.168.101.40', :provisioning => [{:puppet => 'site.pp'}]}
]



#openvswitch bridge config:
#==========================

Bridges = [ 
  { :name => :sens0, :ip_prefix => '192.10.10.0', :ip_last => 2, :mac_prefix => '02:AB', :hosts => [ "attacker", "sensor"] , :promiscous => ["sensor"]},
  #{ :name => :dcc0,  :ip_prefix => '192.20.20.0', :ip_last => 2, :mac_prefix => '02:AB', :hosts => [ "sensor", "shvtep"] , :promiscous => []},
  { :name => :shdw0, :ip_prefix => '192.30.30.0', :ip_last => 2, :mac_prefix => '02:AB', :hosts => [ "shvtep", "shadow"], :promiscous => ["shvtep"]} 
]
