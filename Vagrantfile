# -*- mode: ruby -*-
# vi: set ft=ruby :
# author: bharanidharan seetharaman

VAGRANTFILE_API_VERSION = "2"
require './topology.rb'
require './network_util'
include NetworkUtil

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  VMInstances.each do |opts|
    config.vm.define opts[:vmname] do |server|
      if opts[:box] != nil
         server.vm.box  = opts[:box]
      end

      config.trigger.after :destroy, :force=>true, :vm=>[opts[:vmname].to_s] do
        Bridges.each do |bropts|
          bropts[:hosts].each do |hname|
             if hname == opts[:vmname].to_s
                run "ovs-vsctl del-port #{bropts[:name]} #{bropts[:name]}_#{hname}"
                run "ip tuntap del mode tap #{bropts[:name]}_#{hname}"
             end
          end
          run "ovs-vsctl del-br #{bropts[:name]}"
        end
      end

      config.trigger.before :up, :force=>true, :vm=>[opts[:vmname].to_s] do
        Bridges.each do |bropts|
          run "ovs-vsctl add-br #{bropts[:name]}"
          bropts[:hosts].each do |hname|
             if hname == opts[:vmname].to_s
               run "ip tuntap add mode tap #{bropts[:name]}_#{hname}"
               run "ip link set #{bropts[:name]}_#{hname} up"
               run "ovs-vsctl add-port #{bropts[:name]} #{bropts[:name]}_#{hname}"
             end
          end
        end
      end

      server.vm.hostname  = "%s" % opts[:vmname].to_s
      #server.vm.box_url  = "http://files.vagrantup.com/precise32.box"
      server.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", opts[:mem]  ? opts[:mem] :  "256"]
        vb.customize ["modifyvm", :id, "--cpus"  , opts[:cpus] ? opts[:cpus] : "1"]
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
      end
      #server.vm.boot_mode = :headless
      #server.vm.network :forwarded_port, guest: 22,   host: opts[:ssh_port], auto_correct: true
      ## vagrant-kvm provider needs explicit setting of VM Base MAC to avoid MAC collisions
      server.vm.base_mac  = NetworkUtil::append_mac_ipaddr("A6:12", opts[:ip])
      server.vm.network :private_network, adapter: 2, ip: opts[:ip]

      adapter = 3
      Bridges.each do |bropts|
          #puts "scanning host #{opts[:vmname]} #{bropts}"
          setad = false
          if bropts[:hosts].include? opts[:vmname].to_s
            #puts "interface scanning host #{opts[:vmname]} >> #{adapter} #{opts[:vmname]} #{bropts[:name]}"
            ip  = NetworkUtil::append_ip_lastbyte(bropts[:ip_prefix], bropts[:ip_last] + bropts[:hosts].index(opts[:vmname].to_s))
            mac = NetworkUtil::append_mac_ipaddr(bropts[:mac_prefix], ip)
            server.vm.network :public_network, bridge: bropts[:name].to_s+"_"+opts[:vmname].to_s, adapter: adapter, mac: mac, ip: ip
            setad = true
          end

          if bropts[:promiscous].include? opts[:vmname].to_s
            vad = adapter
            server.vm.provider :virtualbox do |vb|
               #puts "promiscous scanning host #{opts[:vmname]} >> #{vad} #{opts[:vmname]} #{bropts[:name]} #{bropts}"
               vb.customize ["modifyvm", :id, "--nicpromisc#{vad}", "allow-all"]
            end
          end

            #server.vm.provision :shell, :inline => "/sbin/ifconfig eth"+(adapter-1).to_s+" "+ip+" netmask 255.255.255.0 up"
            #"/sbin/ifconfig eth"+(adapter-1).to_s+" hw ether "+mac
           if setad
             adapter = adapter + 1
           end 
      end

      opts[:provisioning].each do |p|
        if p[:chef_role] != nil
          server.vm.provision :chef_solo do |chef|
            chef.roles_path     = "../chef/roles"
            chef.add_role p[:chef_role]
          end
        end
        if p[:chef_recipe] != nil
          server.vm.provision :chef_solo do |chef|
            chef.add_recipe p[:chef_recipe]
          end
        end
        if p[:shell] != nil
          server.vm.provision :shell, :inline => p[:shell]
        end

        if p[:puppet] != nil
          server.vm.provision :puppet do |puppet|
            puppet.manifests_path = "puppet/manifests"
            if p[:path] != nil
	       puppet.manifests_path = p[:path]
            end
            puppet.manifest_file  = p[:puppet]
            puppet.options = "--verbose --debug"
          end
        end
      end
    end
  end
end
