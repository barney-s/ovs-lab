#author: bharanidharan seetharaman
module NetworkUtil

  def append_ip_lastbyte(ip, lastbyte)
    nip = ip.split(".").map!{ |i| i.to_i }
    nip[3] = lastbyte
    ip = nip.join(".")
  end

  def append_mac_ipaddr(mac, ip)
    nmac = mac.split(":").map!{ |i| i.hex }
    nip = ip.split(".").map!{ |i| i.to_i }
    nmac[2] = nip[0]
    nmac[3] = nip[1]
    nmac[4] = nip[2]
    nmac[5] = nip[3]
    mac = "%02X%02X%02X%02X%02X%02X" % nmac
  end

  #puts append_ip_lastbyte("124.33.44.5", 3)
  #puts append_mac_ipaddr("02:AB", "124.33.44.5")
  #124.33.44.3
  #02:AB:7C:21:2C:05

end
