#!bin/bash

touch /etc/yum.repos.d/nginx.repo

echo -e"[nginx]
\nname=nginx repo
\nbaseurl=http://nginx.org/packages/centos/7/$basearch/
\ngpgcheck=0
\nenabled=1" >> /etc/yum.repos.d/nginx.repo

yum install -y nginx

firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --reload

systemctl enable nginx
systemctl start nginx