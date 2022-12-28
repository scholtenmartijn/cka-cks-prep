#!/bin/bash -x 

# This script sets up CRI-O as the runtime
# Intended to run on Ubuntu 18.04 and install Kubernetes 1.19.0
#  This one sets up the worker 
# By Tim Serewicz, 11/2020  GPL


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
sudo apt-get install -y cri-o-1.15 
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
sudo apt-get install -y kubeadm=1.19.0-00 kubelet=1.19.0-00 kubectl=1.19.0-00
sudo apt-mark hold kubelet kubeadm kubectl
  
# Get the join command and the alias from the cp node.
cat cpalias.txt | sudo tee -a /etc/hosts 
cat joincommand.txt |sudo bash



