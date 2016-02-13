#!/bin/bash
# Author: Bharanidharan Seetharaman
# Script to install packages needed for testing OVS samples
#
INSTALLER_CACHE=~/.installer_cache

function c_wget {
  if ! [ -s $2 ]; then
    rm $2
  fi
  ls -l $2 >& /dev/null || {
     wget $1 -O $2
  }
}

function is_installed_pkg {
   _pkg=$1
   _pkg_ver=$2
   sudo dpkg -s $_pkg | grep "Status:" | grep "installed" >& /dev/null && {
     sudo dpkg -s $_pkg | grep "Version:" | grep "$_pkg_ver" >& /dev/null && {
       return 0
     }
   }
   return 1
}

function install_pkg {
  for _pkg in $@; do
    if is_installed_pkg $_pkg ; then
      echo "skipping already installed  `dpkg-query --show $_pkg`"
    else
      echo "installing  $_pkg"
      sudo apt-get install -y $_pkg
    fi
  done
}

function install_base_packages {
  echo "Updating apt-cache"
  #sudo apt-get update
  echo "-------------------"
  install_pkg git
  install_pkg lynx curl
  install_pkg vim
  install_pkg firefox
  install_pkg virtualbox
  install_pkg bsdtar
  install_pkg libvirt-dev
  install_pkg nfs-kernel-server
  install_pkg autoconf gcc uml-utilities libtool
  install_pkg pkg-config linux-headers-`uname -r`
  install_pkg build-essential fakeroot
  #Chef Installation:
  #chef-shell -v || curl -L https://www.opscode.com/chef/install.sh | sudo bash
  #install_pkg filters    # filters => chef
  #install_pkg python-simplejson python-qt4 python-twisted-conch automake 
}


function install_vagrant {
  version="${1:-1.8.1}"
  #install_pkg vagrant
  debfile="vagrant_${version}_x86_64.deb"
  debpkg="vagrant"
  c_wget https://releases.hashicorp.com/vagrant/${version}/$debfile $INSTALLER_CACHE/$debfile
  if is_installed_pkg $debpkg $version; then
     echo "already installed  $debpkg $version"
  elif is_installed_pkg $debpkg ; then
     echo "already installed  `dpkg-query --show vagrant`"
     echo "if the installed version is < $version,  select 'y' to uninstall now"
     echo -n "uninstall [y/n]: "
     read response
     if [ "$response" == "y" ]; then
        sudo apt-get remove -y $debpkg
     fi
  fi
  if ! is_installed_pkg $debpkg $version; then
     cd $INSTALLER_CACHE
     ls -l $pkg
     sudo dpkg -i $pkg
     sudo apt-get install -f
  fi
  vagrant plugin list | grep "vagrant-kvm" || vagrant plugin install vagrant-kvm
  vagrant plugin list | grep "vagrant-vbguest" || vagrant plugin install vagrant-vbguest
  vagrant plugin list | grep "vagrant-host-shell" || vagrant plugin install vagrant-host-shell
  vagrant plugin list | grep "vagrant-pristine" || vagrant plugin install vagrant-pristine
  vagrant plugin list | grep "vagrant-triggers" || vagrant plugin install vagrant-triggers
}

function install_ovs {
  install_pkg openvswitch-switch qemu-kvm libvirt-bin
}

function install_ovs_source {
  version="${1:-v.2.4.0}"
  ls ~/.openvswitch || {
    clone_git https://github.com/openvswitch/ovs ovs
    cd $INSTALLER_CACHE/ovs
    git checkout $version
    ./boot.sh
    ./configure --with-linux=/lib/modules/`uname -r`/build
    make && sudo make install
    ./boot.sh
    ./configure --with-linux=/lib/modules/`uname -r`/build
    make && sudo make install
  }
}


function install_kvm {
  install_pkg cpu-checker
  kvm-ok
  install_pkg qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
  groups | grep libvirtd >& /dev/null && echo "group 'libvirtd' already exists "
  groups | grep libvirtd >& /dev/null || {
    sudo adduser `id -un` libvirtd
    me=`basename $0`
    echo "To complete installation you need to logout."
    echo "Relogin and execute $me"
    echo "Hit Enter to logout"
    read
    #gnome-session-quit
  } 
  
  virsh -c qemu:///system list >& /dev/null || {
    echo "virsh -c qemu:///system list - failed !!!"
    echo "try relogging in. Or rebooting."
    echo "Hit Enter to logout"
    read
    gnome-session-quit
  }

  sudo ls -la /var/run/libvirt/libvirt-sock | grep "srwxrwx.* root libvirtd" >& /dev/null || {
    echo "you dont have access to /var/run/libvirt/libvirt-sock ???"
    echo "can't continue instllation. try Manual installation:"
    echo "https://help.ubuntu.com/community/KVM/Installation"
    exit
  }

  install_pkg virt-manager

  return 
  ls -l /dev/kvm | grep libvirtd || {
    echo "force /dev/kvm to libvirtd group"
    sudo chown root:libvirtd /dev/kvm
    echo "restarting kvm module"
    sudo rmmod kvm_intel
    sudo rmmod kvm 
#    || {
#      echo "unable to remove kernel module kvm !!"
#      echo "forcing a user logoff to complete installation"
#      echo "Hit Enter to logout"
#      read
#      gnome-session-quit
#    }
    sudo modprobe -a kvm
    sudo modprobe -a kvm_intel
  }
}
  

function clone_git {
  _git_url=$1
  _git_folder=$2
  _branch="${3:-master}"
  ls -l $INSTALLER_CACHE/$_git_folder > /dev/null || git clone $_git_url $INSTALLER_CACHE/$_git_folder
  cd $INSTALLER_CACHE/$_git_folder
  git checkout $_branch
}

function install_packages {
  install_base_packages
  install_vagrant
  install_kvm
  install_ovs
}

################# MAIN #########################
function main {
  mkdir -p $INSTALLER_CACHE
  mkdir -p $INSTALLER_CACHE/vagrant

  install_packages

  clone_git https://github.com/barney-s/ovs-lab ovs-lab
  cd $INSTALLER_CACHE/ovs-lab
  #vagrant up
}

main
