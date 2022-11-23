#!/bin/bash

echo "======== vDCM Network Setting ========"
ip a | grep '^[0-9]' |awk '{print $2}' |grep -v -e 'lo' -e 'v' -e 't'
read -p "Plaase input network interface: " net_name
read -p "Plaase input network ip(ex.192.168.100.100/24):" net_ip

if [[ -z $net_gw ]] || [[ -z $net_dns ]] ;
then
  nmcli con mod $net_name ipv4.address $net_ip
fi

read -p "vDCM Input Output fist setting? (y/n): " yesorno

if [[ $yesorno = "y" ]] || [[ $yesorno = "yes" ]] || [[ $yesorno = "Y" ]] || [[ $yesorno = "YES" ]];
then
	sed -i 's/BROWSER_ONLY=/#BROWSER_ONLY=/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/IPV4_FAILURE_FATAL=/#IPV4_FAILURE_FATAL=/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/IPV6INIT=yes/IPV6INIT=no/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/IPV6_AUTOCONF=/#IPV6_AUTOCONF=/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/IPV6_DEFROUTE=/#IPV6_DEFROUTE=/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/IPV6_FAILURE_FATAL=/#IPV6_FAILURE_FATAL=/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/IPV6_ADDR_GEN_MODE=/#IPV6_ADDR_GEN_MODE=/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/DEFROUTE=/#DEFROUTE=/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	sed -i 's/PROXY_METHOD=/#PROXY_METHOD=/' /etc/sysconfig/network-scripts/ifcfg-$net_name
	echo -e "NM_CONTROLLED=no" >> /etc/sysconfig/network-scripts/ifcfg-$net_name
	cat /etc/sysconfig/network-scripts/ifcfg-$net_name
	echo "Success Setting!!!!"
else
	echo "Fail try again"
fi
