#!/bin/bash
#/* **************** LFS260:2022-03-25 s_05/secureserver.sh **************** */
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
#!/bin/bash

# Created by Tim Serewicz, for The Linux Foundation, 11/2020. GPL

sudo sed -e '/insecure-port/s/^/#/g' -i /etc/kubernetes/manifests/kube-apiserver.yaml

# This value has been deprecated in 1.20. If set to anything other
# than zero the kube-apiserver pod will not start. But removing the
# value or commenting it out returns it to a default state, which is
# enabled. To be fully removed in version 1.24.
