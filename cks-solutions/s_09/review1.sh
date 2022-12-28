#!/bin/bash
#/* **************** LFS260:2022-03-25 s_09/review1.sh **************** */
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
# Timothy Serewicz for The Linux Foundation. GPL


sudo sh -c "sed -i 's/--insecure-port=0/--insecure-port=8080/g' /etc/kubernetes/manifests/kube-apiserver.yaml"

kubectl -n kube-system delete pod $(kubectl -n kube-system get pod |grep apiserver |cut -d " " -f 1)




