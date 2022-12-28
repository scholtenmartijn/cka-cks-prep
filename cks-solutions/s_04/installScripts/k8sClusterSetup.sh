#!/bin/bash -x
## TxS 06-2021
## For 1.21 cluster

# *
# * The code herein is: Copyright the Linux Foundation, 2020 GPL v2
# *
# * This Copyright is retained for the purpose of protecting free
# * redistribution of source.
# *
# *     URL:    https://training.linuxfoundation.org
# *     email:  training@linuxfoundation.org
# *

echo "Format is pem key, cp IP, then worker IP"

echo "You passed $1 $2 $3"

echo "Configure the Master first"
# Get and extract tarball
ssh -oStrictHostKeyChecking=no -i $1 student@$2 "wget https://training.linuxfoundation.org/cm/LFS460/LFS460_V1.21_SOLUTIONS.tar.xz --user=LFtraining --password=Penguin2014"

# Ensure this is the tarball mentioned in previous step
ssh -i $1 student@$2 "tar -xvf LFS460_V1.21_SOLUTIONS.tar.xz"


# Copy the script to home directory
ssh -i $1 student@$2 "cp /home/student/LFS460/SOLUTIONS/s_04/k8scp.sh ~"

# Show the script on the screen
echo "################# ABOUT TO RUN THIS ########################
ssh -i $1 student@$2 cat k8scp.sh

echo "################# SCRIPT OUTPUT END ########################"

# Run script and put output to file for later use
echo "Initialize the cp and save output to a file"
ssh -t -i $1 student@$2 "bash k8scp.sh | tee ~/cp.out"


# Find the join command
ssh -i $1 student@$2 "grep -B1 discovery cp.out > /tmp/join.out"

# Bring back the join command
ssh -i $1 student@$2 "cat /tmp/join.out" > /tmp/join.out.local

# Configure the Master Node
ssh -t -i $1 student@$2 "sudo apt-get install nano vim bash-completion -y"
ssh -i $1 student@$2 'source <(kubectl completion bash)'
ssh -i $1 student@$2 'printf "source <(kubectl completion bash)\n" &>> ~/.bashrc'

# MASTER DONE NOW THE WORKER

# Get and extract tarball on worker node
ssh -oStrictHostKeyChecking=no -i $1 student@$3 "wget https://training.linuxfoundation.org/cm/LFS460/LFS460_V1.21_SOLUTIONS.tar.xz --user=LFtraining --password=Penguin2014"

ssh -i $1 student@$3 "tar -xvf LFS460_V1.21_SOLUTIONS.tar.xz"

# Copy and use the k8sSecond.sh script
ssh -i $1 student@$3 "cp /home/student/LFS460/SOLUTIONS/s_04/k8sSecond.sh ~"
ssh -t -i $1 student@$3 "bash k8sSecond.sh"

# Again we need to wait while worker is setup

# Use the join command on the worker node
ssh -i $1 student@$3 "sudo $(cat /tmp/join.out.local)"

# Write node info to a file
echo "" >> /tmp/nodes.txt
echo "Master $2" >> /tmp/nodes.txt
echo "Worker $3" >> /tmp/nodes.txt
echo "" >> /tmp/nodes.txt

# Copy from this file to etherpad. 


