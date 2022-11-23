#!/bin/bash

#network set
echo "======== Kubernetes Network Setting ========"
ip a | grep '^[0-9]' |awk '{print $2}' |grep -v -e 'lo' -e 'v' -e 't'
read -p "Plaase input network interface: " net_name
read -p "Plaase input network ip(ex.192.168.123.100/24):" net_ip
read -p "Plaase input network gateway (Null = pass): " net_gw
read -p "Plaase input network dns (Null = pass): " net_dns

if [[ -z $net_gw ]] || [[ -z $net_dns ]] ;
then
  nmcli con mod $net_name ipv4.address $net_ip
  sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-$net_name
else
  nmcli con mod $net_name ipv4.address $net_ip ipv4.gateway $net_gw ipv4.dns $net_dns ipv4.method manual
  sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-$net_name
fi

echo ""
echo "======== Kubernetes Host name & IP Setting ========"
#host name
read -p "Plaase Master_Hostname: " master_name
read -p "Plaase Node1_Hostname: " node1_name
read -p "Plaase Node2_Hostname: " node2_name
echo ""
#host IP
read -p "Plaase Master_IP: " master_ip
read -p "Plaase Node1_IP: " node1_ip
read -p "Plaase Node2_IP: " node2_ip

echo ""
#Position
echo "======== you Position ========"
read -p "You master or node1 or node2 ?: " position
cat /dev/null > /etc/hostname
echo -e "$position" >> /etc/hostname

cat /dev/null > /etc/hosts
echo -e "127.0.0.1    localhost localhost.localdomain" >> /etc/hosts
echo -e "::1            localhost localhost.localdomain" >> /etc/hosts
echo -e "$master_ip $master_name" >> /etc/hosts
echo -e "$node1_ip $node1_name" >> /etc/hosts
echo -e "$node2_ip $node2_name" >> /etc/hosts


#sellinux firewall
sed -i 's/SELINUX=disabled/SELINUX=permissive/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux 
setenforce 0

#reboot
echo ""
echo "Please reboot."