# Used for CKA/CKS prep

cdk-k8s contains a CDK app that spins up an vpc and two autoscaling groups which will be used in the assignments. Each autoscaling group either refers to the master nodes or regular nodes.

To start:

Create an EC2 Key pair 

Deploy the stack: 

```
cdk bootstrap
cdk deploy
```



1.






21

Use context: kubectl config use-context k8s-c3-CCC

Create a Static Pod named my-static-pod in Namespace default on cluster3-controlplane1. It should be of image nginx:1.16-alpine and have resource requests for 10m CPU and 20Mi memory.

Then create a NodePort Service named static-pod-service which exposes that static Pod on port 80 and check if it has Endpoints and if it's reachable through the cluster3-controlplane1 internal IP address. You can connect to the internal node IPs from your main terminal.

22
Use context: kubectl config use-context k8s-c2-AC

Check how long the kube-apiserver server certificate is valid on cluster2-controlplane1. Do this with openssl or cfssl. Write the exipiration date into /opt/course/22/expiration.

Also run the correct kubeadm command to list the expiration dates and confirm both methods show the same date.

Write the correct kubeadm command that would renew the apiserver server certificate into /opt/course/22/kubeadm-renew-certs.sh.

23

Use context: kubectl config use-context k8s-c2-AC

Node cluster2-node1 has been added to the cluster using kubeadm and TLS bootstrapping.

Find the "Issuer" and "Extended Key Usage" values of the cluster2-node1:

kubelet client certificate, the one used for outgoing connections to the kube-apiserver.
kubelet server certificate, the one used for incoming connections from the kube-apiserver.
Write the information into file /opt/course/23/certificate-info.txt.

Compare the "Issuer" and "Extended Key Usage" fields of both certificates and make sense of these.

24

Use context: kubectl config use-context k8s-c1-H

There was a security incident where an intruder was able to access the whole cluster from a single hacked backend Pod.

To prevent this create a NetworkPolicy called np-backend in Namespace project-snake. It should allow the backend-* Pods only to:

connect to db1-* Pods on port 1111
connect to db2-* Pods on port 2222
Use the app label of Pods in your policy.

After implementation, connections from backend-* Pods to vault-* Pods on port 3333 should for example no longer work.

25

Use context: kubectl config use-context k8s-c3-CCC

Make a backup of etcd running on cluster3-controlplane1 and save it on the controlplane node at /tmp/etcd-backup.db.

Then create a Pod of your kind in the cluster.

Finally restore the backup, confirm the cluster is still working and that the created Pod is no longer with us.



EQ1

Use context: kubectl config use-context k8s-c1-H

Check all available Pods in the Namespace project-c13 and find the names of those that would probably be terminated first if the Nodes run out of resources (cpu or memory) to schedule all Pods. Write the Pod names into /opt/course/e1/pods-not-stable.txt.

Extra Question 2
Use context: kubectl config use-context k8s-c1-H

There is an existing ServiceAccount secret-reader in Namespace project-hamster. Create a Pod of image curlimages/curl:7.65.3 named tmp-api-contact which uses this ServiceAccount. Make sure the container keeps running.

Exec into the Pod and use curl to access the Kubernetes Api of that cluster manually, listing all available secrets. You can ignore insecure https connection. Write the command(s) for this into file /opt/course/e4/list-secrets.sh.

Preview Question 1
Use context: kubectl config use-context k8s-c2-AC

The cluster admin asked you to find out the following information about etcd running on cluster2-controlplane1:

Server private key location
Server certificate expiration date
Is client certificate authentication enabled
Write these information into /opt/course/p1/etcd-info.txt

Finally you're asked to save an etcd snapshot at /etc/etcd-snapshot.db on cluster2-controlplane1 and display its status.


Preview Question 2
Use context: kubectl config use-context k8s-c1-H

You're asked to confirm that kube-proxy is running correctly on all nodes. For this perform the following in Namespace project-hamster:

Create a new Pod named p2-pod with two containers, one of image nginx:1.21.3-alpine and one of image busybox:1.31. Make sure the busybox container keeps running for some time.

Create a new Service named p2-service which exposes that Pod internally in the cluster on port 3000->80.

Find the kube-proxy container on all nodes cluster1-controlplane1, cluster1-node1 and cluster1-node2 and make sure that it's using iptables. Use command crictl for this.

Write the iptables rules of all nodes belonging the created Service p2-service into file /opt/course/p2/iptables.txt.

Finally delete the Service and confirm that the iptables rules are gone from all nodes.

Preview Question 3
Use context: kubectl config use-context k8s-c2-AC

Create a Pod named check-ip in Namespace default using image httpd:2.4.41-alpine. Expose it on port 80 as a ClusterIP Service named check-ip-service. Remember/output the IP of that Service.

Change the Service CIDR to 11.96.0.0/12 for the cluster.

Then create a second Service named check-ip-service2 pointing to the same Pod to check if your settings did take effect. Finally check if the IP of the first Service has changed.