#!/bin/bash
#/* **************** LFS260:2022-03-25 s_04/setupscript.sh **************** */
#/*
# * The code herein is: Copyright the Linux Foundation, 2022
# *
# * This Copyright is retained for the purpose of protecting free
# * redistribution of source.
# *
# *     URL:    https://training.linuxfoundation.org
# *     email:  info@linuxfoundation.org
# *
# * This code is distributed under Version 2 of the GNU General Public
# * License, which you should have received with the source.
# *
# */
#!/bin/bash -x

# Setup script for the LFS460 Kubernetes Security course
# Timothy Serewicz for The Linux Foundation - GPL

# Make sure vim and bash-completion is installed

sudo apt-get install bash-completion vim -y

# Enable kubectl completion

source <(kubectl completion bash)

echo "source <(kubectl completion bash)" >> $HOME/.bashrc

# Add two users

sudo sh -c "useradd -m -s /bin/bash dan ; echo "dan:danpassword" | chpasswd"

sudo sh -c "useradd -m -s /bin/bash paul ; echo "paul:paulpassword" | chpasswd"

# Add two new namespaces

kubectl create ns dev-ns

kubectl create ns prod-a

kubectl create ns prod-b

