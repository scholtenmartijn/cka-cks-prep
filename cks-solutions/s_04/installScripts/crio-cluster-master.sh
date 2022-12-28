#!/bin/bash -x 

# This script sets up CRI-O as the runtime
# Intended to run on Ubuntu 18.04 and install Kubernetes 1.21.1
# 
# By Tim Serewicz, 06/2021  GPL


# Update the OS
sudo apt-get update && sudo apt-get upgrade -y

# Install vim (or some other editor)
sudo apt-get install -y vim nano emacs

# Prepare system for CRIO
sudo modprobe overlay
sudo modprobe br_netfilter

#Copy over cri.conf file to modify kernel
sudo cp $(find $HOME -name 99-kubernetes-cri.conf) /etc/sysctl.d/
sudo sysctl --system 

# Install Project Atomic repo
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:projectatomic/ppa -y
sudo apt-get update
sudo apt-get install -y cri-o-1.21 
sudo cp $(find $HOME -name crio.conf) /etc/crio/crio.conf

# Restart 
sudo systemctl daemon-reload 
sudo systemctl enable crio
sudo systemctl start crio

# Copy over kubelet settings to use CRI-O
sudo cp $(find $HOME -name kubelet) /etc/default/kubelet

# Copy over new repo for kubernetes software
sudo cp $(find $HOME -name kubernetes.list) /etc/apt/sources.list.d/
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Install the three packages, and dependencies
sudo apt-get update
sudo apt-get install -y kubeadm=1.21.1-00 kubelet=1.21.1-00 kubectl=1.21.1-00
sudo apt-mark hold kubelet kubeadm kubectl
  
# Set the alias using the primary interface IP address. Could be issue 
echo "$(hostname --ip-address) k8scp" | sudo tee -a /etc/hosts

# Copy over configuration file then initialize the cluster   
sudo cp $(find $HOME -name kubeadm-config.yaml) $HOME
sudo kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.out

# Save the join command to be gotten by the worker node
grep -m 1 -A 2 k8scp:6443 kubeadm-init.out  > joincommand.txt
grep k8scp /etc/hosts > cpalias.txt

# Setup non-root user environment
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo apt-get install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> $HOME/.bashrc

# Use Calico as the network plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Show the state of the node and pods
kubectl get node
kubectl get pod --all-namespaces 


