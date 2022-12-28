# *
# * The code herein is: Copyright the Linux Foundation, 2020 GPL v2
# *
# * This Copyright is retained for the purpose of protecting free
# * redistribution of source.
# *
# *     URL:    https://training.linuxfoundation.org
# *     email:  training@linuxfoundation.org
# * 

## TxS 06-2020 
## v1.18.1 

## For internal Linux Foundation use only


You will need the expect package. This script tested
from a RHEL box, your version of expect may require slight differences.

This script also assumes these files in the current directory:

- An expect script named ConfigureTwoNodeCluster.exp
- A k8sClusterSetup.sh script. 
- The NodeIPAddrs.txt file with two IP addresses per line. Be aware
  that empty lines are read into the script.
- The use of LF-Class.pem as the SSH identity to access the domains.
  Edit the ConfigureTwoNodeCluster.exp to use your pem key,
  or change the name of the pem key you use. 

This will create a file called /tmp/nodes.txt where you can find 
the IPs to copy and paste into the class etherpad. You may 
want to clear out this file so you can tell which ones are new,
prior to running the expect script.

Baisc Steps:

1) Start two instances per student using GCE, AWS, or Digital Ocean

2) Once you have the instance IPs edit the NodeIPAddrs.txt. Put two IPs
per line, sperated by a space.  The first IP will become the cp,
the second on the line will join as a worker.

3) When instances are ready run this command:

while read name; do ./ConfigureTwoNodeCluster.exp $name; done < NodeIPAddrs.txt

This calls the ConfigureTwoNodeCluster.exp
which is an expect script which calls  ./k8sClusterSetup.sh
which will populate /tmp/Nodes.txt file


