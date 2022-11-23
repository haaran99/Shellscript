#!/bin/bash
modprobe --first-time bonding
echo "======== Bonding Network Setting ========"
read -p "bonding Name:(ex.bond0): " bon_name
read -p "bonding IPADDR:(ex.192.168.123.123): " bon_ip
read -p "bonding Netmask:(ex.255.255.255.0): " bon_netmask
read -p "bonding Mode select (1.ative_backup) (4.ative_ative): " bon_mode

if [[ -z $bon_name ]] || [[ -z $bon_ip ]] || [[ -z $bon_netmask ]] || [[ -z $bon_mode ]] ; then
  read -p "MEET CRITERIA"
else
	touch /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "DEVICE=$bon_name" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "DEVICE=$bon_name" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "NAME=$bon_name" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "TYPE=Bond" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "IPADDR=$bon_ip" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "NETMASK=$bon_netmask" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
	echo -e "BONDING_OPTS=mode=$bon_mode miimon=100" >> /etc/sysconfig/network-scripts/ifcfg-$bon_name
fi

echo "======== Slave Setting ========"
ip a | grep '^[0-9]' |awk '{print $2}' |grep -v -e 'lo' -e 'v' -e 't'
read -p "Slave1 network name:" slave1
read -p "Slave2 network name:" slave2

cp /etc/sysconfig/network-scripts/ifcfg-$slave1 /root
cp /etc/sysconfig/network-scripts/ifcfg-$slave2 /root

rm -rf /etc/sysconfig/network-scripts/ifcfg-$slave1
rm -rf /etc/sysconfig/network-scripts/ifcfg-$slave2

touch /etc/sysconfig/network-scripts/ifcfg-$slave1
echo -e "\nifcfg-$slave1
\nDEVICE=$slave1
\nNAME=$slave1
\nTYPE=Ethernet
\nBOOTPROTO=none
\nONBOOT=yes
\nMASTER=$bon_name
\nSLAVE=yes" >>/etc/sysconfig/network-scripts/ifcfg-$slave1

touch /etc/sysconfig/network-scripts/ifcfg-$slave2
echo -e "\nifcfg-$slave2
\nDEVICE=$slave2
\nNAME=$slave2
\nTYPE=Ethernet
\nBOOTPROTO=none
\nONBOOT=yes
\nMASTER=$bon_name
\nSLAVE=yes" >>/etc/sysconfig/network-scripts/ifcfg-$slave2

service network restart
cat /proc/net/bonding/bond0
