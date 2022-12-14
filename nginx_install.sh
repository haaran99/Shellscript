#!bin/bash

touch /etc/yum.repos.d/nginx.repo

echo -e '[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1' > /etc/yum.repos.d/nginx.repo


yum install -y nginx

firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --reload

systemctl enable nginx
systemctl start nginx
