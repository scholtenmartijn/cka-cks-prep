# Control plane/Master

IP:
10.0.82.169

```
ssh -i ~/.ssh/keys/cka-cks-prep.pem ubuntu@34.241.20.220
```


# Worker

IP:
10.0.15.213


```
ssh -i ~/.ssh/keys/cka-cks-prep.pem ubuntu@334.244.194.27
```


```
kubeadm join \
--token hul7ch.fdqf8xew1ge5swrg \
10.0.82.169:6443 \
--discovery-token-ca-cert-hash \
sha256:60683673e8508c478fa443ba79df73a3defcf94731a6e22bc49d41f64ff5e063
```

# ETCD snapshot

kubectl -n kube-system exec -it etcd-ip-10-0-82-169 -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl endpoint health"


kubectl -n kube-system exec -it etcd-ip-10-0-82-169 -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl --endpoints=https://127.0.0.1:2379 member list"

kubectl -n kube-system exec -it etcd-ip-10-0-82-169 -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl --endpoints=https://127.0.0.1:2379 member list -w table"

kubectl -n kube-system exec -it etcd-ip-10-0-82-169 -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl --endpoints=https://127.0.0.1:2379 snapshot save /var/lib/etcd/snapshot.db"

# Upgrade CP node

ip-10-0-82-169

kubectl drain ip-10-0-82-169 --ignore-daemonsets

sudo kubeadm upgrade apply v1.25.1