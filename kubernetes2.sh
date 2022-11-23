#!/bin/bash

echo "======== You Master Node? ========"
read -p "yes or no: " master_yes_no

#firewall disable
systemctl stop firewalld && systemctl disable firewalld

#swap disable
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab

#modprobe modul run
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#iptable6 set
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

#docker install
yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io

mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

#docker active
systemctl enable --now docker

#kubernetes repo 
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#kubernetes install
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

#kubernetes active
systemctl enable --now kubelet

#kubernetes docker set
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF


if [ $master_yes_no == "y" ] || [ $master_yes_no == "yes" ]
then 
echo ""
read -p "Master IP: " master_ip
kubeadm init --apiserver-advertise-address $master_ip --apiserver-cert-extra-sans $master_ip --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
kubectl apply -f calico.yaml
else 
echo ""
echo "you node!" 
echo ""
fi
