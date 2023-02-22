Work on:
- Creating resources from scratch such as pods, daemonsets and deployments
- Go through pv and pvc
- Go through role, rolebinding and service account
- ETCD backup and restore
- Go through kubeadm join
- Kubelet restart and debugging

https://killer.sh/session/solution/98c65546-97c1-4341-ad9f-f08297d52eac

# Tips

```
alias k=kubectl

export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"
```

# 1

You have access to multiple clusters from your main terminal through kubectl contexts. Write all those context names into /opt/course/1/contexts.

Next write a command to display the current context into /opt/course/1/context_default_kubectl.sh, the command should use kubectl.

Finally write a second command doing the same thing into /opt/course/1/context_default_no_kubectl.sh, but without the use of kubectl.

```
k config get-contexts

k config get-contexts -o name > dir
```

```
kubectl config current-context

cat ~/.kube/config | grep current
```

# 2

Use context: kubectl config use-context k8s-c1-H

Create a single Pod of image httpd:2.4.41-alpine in Namespace default. The Pod should be named pod1 and the container should be named pod1-container. This Pod should only be scheduled on a controlplane node, do not add new labels any nodes.

```
k get node
k describe node cluster1-controlplane1 | grep Taint -A1

k get node cluster1-controlplane1 --show-labels
```

```
k run pod1 --image=httpd:2.4.41-alpine $do > 2.yaml

apiVersion: v1
kind: Pod
metadata:
  namespace: default
  name: pod1
spec:
  containers:
    - image: httpd:2.4.41-alpine
      name: pod1-container #change
  tolerations: # Add tolerations
    - effect: NoSchedule
      key: node-role.kubernetes.io/master
  nodeSelector: # Add node selector
    node-role.kubernetes.io/master: ""

k create -f 2.yaml

k get pod pod1 -o wide
```

# 3

Use context: kubectl config use-context k8s-c1-H

There are two Pods named o3db-* in Namespace project-c13. C13 management asked you to scale the Pods down to one replica to save resources.

```
Find out it is a statefulset

k -n project-c13 get deploy, ds, sts | grep o3db

k -n project-c13 get pod --show-labels | grep o3db

k -n project-c13 scale sts o3db --replicas 1
```

# 4

Do the following in Namespace default. Create a single Pod named ready-if-service-ready of image nginx:1.16.1-alpine. Configure a LivenessProbe which simply executes command true. Also configure a ReadinessProbe which does check if the url http://service-am-i-ready:80 is reachable, you can use wget -T2 -O- http://service-am-i-ready:80 for this. Start the Pod and confirm it isn't ready because of the ReadinessProbe.

Create a second Pod named am-i-ready of image nginx:1.16.1-alpine with label id: cross-server-ready. The already existing Service service-am-i-ready should now have that second Pod as endpoint.

Now the first Pod should be in ready state, confirm that.

```
k run ready-if-service-ready --image=nginx:1.16.1-alpine $do > 4_pod1.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ready-if-service-ready
  name: ready-if-service-ready
spec:
  containers:
  - image: nginx:1.16.1-alpine
    name: ready-if-service-ready
    resources: {}
    livenessProbe: # add this part
      exec:
        command:
          - echo
          - hi
    readinessProbe:
      exec:
        command:
          - wget
          - -T2
          - -O-
          - http://service-am-i-ready:80
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

```
k create -f 4_pod1.yaml

k get pod ready-if-service-ready

k describe pod ready-if-service-ready <- should see probe failing
```

```
k run am-i-ready --image=nginx:1.16.1-alpine --labels="id=cross-server-ready"

k get ep
k describe svc service-am-i-ready
```

# 5

There are various Pods in all namespaces. Write a command into /opt/course/5/find_pods.sh which lists all Pods sorted by their AGE (metadata.creationTimestamp).

Write a second command into /opt/course/5/find_pods_uid.sh which lists all Pods sorted by field metadata.uid. Use kubectl sorting for both commands.

```
kubectl get pod -A --sort-by=.metadata.creationTimestamp

kubectl get pod -A --sort-by=.metadata.uid
```

# 6

Create a new PersistentVolume named safari-pv. It should have a capacity of 2Gi, accessMode ReadWriteOnce, hostPath /Volumes/Data and no storageClassName defined.

Next create a new PersistentVolumeClaim in Namespace project-tiger named safari-pvc . It should request 2Gi storage, accessMode ReadWriteOnce and should not define a storageClassName. The PVC should bound to the PV correctly.

Finally create a new Deployment safari in Namespace project-tiger which mounts that volume at /tmp/safari-data. The Pods of that Deployment should be of image httpd:2.4.41-alpine.

```
kubernetes.io to find:

apiVersion: v1
kind: PersistentVolume
metadata:
  name: safari-pv
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/Volumes/Data"

k create -f 6_pv.yaml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: safari-pvc
  namespace: project-tiger
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

k create -f 6_pvc.yaml

k -n project-tiger get pv,pvc

k -n project-tiger create deploy --image=httpd:2.4.41-alpine $do > 6_dep.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: safari
  name: safari
  namespace: project-tiger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: safari
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: safari
    spec:
      volumes:                                      # add
      - name: data                                  # add
        persistentVolumeClaim:                      # add
          claimName: safari-pvc                     # add
      containers:
      - image: httpd:2.4.41-alpine
        name: container
        volumeMounts:                               # add
        - name: data                                # add
          mountPath: /tmp/safari-data               # add
```

# 7

The metrics-server has been installed in the cluster. Your college would like to know the kubectl commands to:

show Nodes resource usage
show Pods and their containers resource usage
Please write the commands into /opt/course/7/node.sh and /opt/course/7/pod.sh.

```
kubectl top node
kubectl top pod --containers=true
```

# 8

Ssh into the controlplane node with ssh cluster1-controlplane1. Check how the controlplane components kubelet, kube-apiserver, kube-scheduler, kube-controller-manager and etcd are started/installed on the controlplane node. Also find out the name of the DNS application and how it's started/installed on the controlplane node.

Write your findings into file /opt/course/8/controlplane-components.txt. The file should be structured like:

# /opt/course/8/controlplane-components.txt
kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]

Choices of [TYPE] are: not-installed, process, static-pod, pod


```
ssh cluster1-controlplane1

root@cluster1-controlplane1:~# ps aux | grep kubelet # shows kubelet process

➜ root@cluster1-controlplane1:~# find /etc/systemd/system/ | grep kube
/etc/systemd/system/kubelet.service.d
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
/etc/systemd/system/multi-user.target.wants/kubelet.service

➜ root@cluster1-controlplane1:~# find /etc/systemd/system/ | grep etcd

➜ root@cluster1-controlplane1:~# find /etc/kubernetes/manifests/
/etc/kubernetes/manifests/
/etc/kubernetes/manifests/kube-controller-manager.yaml
/etc/kubernetes/manifests/etcd.yaml
/etc/kubernetes/manifests/kube-apiserver.yaml
/etc/kubernetes/manifests/kube-scheduler.yaml

➜ root@cluster1-controlplane1:~# kubectl -n kube-system get pod -o wide | grep controlplane1
coredns-5644d7b6d9-c4f68                            1/1     Running            ...   cluster1-controlplane1
coredns-5644d7b6d9-t84sc                            1/1     Running            ...   cluster1-controlplane1
etcd-cluster1-controlplane1                         1/1     Running            ...   cluster1-controlplane1
kube-apiserver-cluster1-controlplane1               1/1     Running            ...   cluster1-controlplane1
kube-controller-manager-cluster1-controlplane1      1/1     Running            ...   cluster1-controlplane1
kube-proxy-q955p                                    1/1     Running            ...   cluster1-controlplane1
kube-scheduler-cluster1-controlplane1               1/1     Running            ...   cluster1-controlplane1
weave-net-mwj47                                     2/2     Running            ...   cluster1-controlplane1


➜ root@cluster1-controlplane1$ kubectl -n kube-system get ds
NAME         DESIRED   CURRENT   ...   NODE SELECTOR            AGE
kube-proxy   3         3         ...   kubernetes.io/os=linux   155m
weave-net    3         3         ...   <none>                   155m

➜ root@cluster1-controlplane1$ kubectl -n kube-system get deploy
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
coredns   2/2     2            2           155m


# /opt/course/8/controlplane-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
```


# 9

Ssh into the controlplane node with ssh cluster2-controlplane1. Temporarily stop the kube-scheduler, this means in a way that you can start it again afterwards.

Create a single Pod named manual-schedule of image httpd:2.4-alpine, confirm it's created but not scheduled on any node.

Now you're the scheduler and have all its power, manually schedule that Pod on node cluster2-controlplane1. Make sure it's running.

Start the kube-scheduler again and confirm it's running correctly by creating a second Pod named manual-schedule2 of image httpd:2.4-alpine and check if it's running on cluster2-node1.

```
➜ k get node
NAME                     STATUS   ROLES           AGE   VERSION
cluster2-controlplane1   Ready    control-plane   26h   v1.26.0
cluster2-node1           Ready    <none>          26h   v1.26.0

➜ ssh cluster2-controlplane1

➜ root@cluster2-controlplane1:~# kubectl -n kube-system get pod | grep schedule
kube-scheduler-cluster2-controlplane1            1/1     Running   0          6s

➜ root@cluster2-controlplane1:~# cd /etc/kubernetes/manifests/

➜ root@cluster2-controlplane1:~# mv kube-scheduler.yaml ..

k run manual-schedule --image=httpd:2.4-alpine
k get pod manual-schedule -o yaml > 9.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2020-09-04T15:51:02Z"
  labels:
    run: manual-schedule
  managedFields:
...
    manager: kubectl-run
    operation: Update
    time: "2020-09-04T15:51:02Z"
  name: manual-schedule
  namespace: default
  resourceVersion: "3515"
  selfLink: /api/v1/namespaces/default/pods/manual-schedule
  uid: 8e9d2532-4779-4e63-b5af-feb82c74a935
spec:
  nodeName: cluster2-controlplane1        # add the controlplane node name
  containers:
  - image: httpd:2.4-alpine
    imagePullPolicy: IfNotPresent
    name: manual-schedule
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-nxnc7
      readOnly: true
  dnsPolicy: ClusterFirst

k -f 9.yaml replace --force

➜ k get pod manual-schedule -o wide
NAME              READY   STATUS    ...   NODE            
manual-schedule   1/1     Running   ...   cluster2-controlplane1

start scheduler again

➜ ssh cluster2-controlplane1

➜ root@cluster2-controlplane1:~# cd /etc/kubernetes/manifests/

➜ root@cluster2-controlplane1:~# mv ../kube-scheduler.yaml .

➜ root@cluster2-controlplane1:~# kubectl -n kube-system get pod | grep schedule
kube-scheduler-cluster2-controlplane1            1/1     Running   0          16s

k run manual-schedule2 --image=httpd:2.4-alpine

➜ k get pod -o wide | grep schedule
manual-schedule    1/1     Running   ...   cluster2-controlplane1
manual-schedule2   1/1     Running   ...   cluster2-node1
```

# 10

Use context: kubectl config use-context k8s-c1-H

Create a new ServiceAccount processor in Namespace project-hamster. Create a Role and RoleBinding, both named processor as well. These should allow the new SA to only create Secrets and ConfigMaps in that Namespace.

```
k create sa processor -n project-hamster

k create role -n project-hamster -h

k -n project-hamster create role processor \
  --verb=create \
  --resource=secret \
  --resource=configmap


k -n project-hamster create rolebinding processor \
--role processor \
--serviceaccount project-hamster:processor

➜ k -n project-hamster auth can-i create secret \
  --as system:serviceaccount:project-hamster:processor
yes

➜ k -n project-hamster auth can-i create configmap \
  --as system:serviceaccount:project-hamster:processor
yes

➜ k -n project-hamster auth can-i create pod \
  --as system:serviceaccount:project-hamster:processor
no

➜ k -n project-hamster auth can-i delete secret \
  --as system:serviceaccount:project-hamster:processor
no

➜ k -n project-hamster auth can-i get configmap \
  --as system:serviceaccount:project-hamster:processor
no
```

# 11

Use Namespace project-tiger for the following. Create a DaemonSet named ds-important with image httpd:2.4-alpine and labels id=ds-important and uuid=18426a0b-5f59-4e10-923f-c0e078e82462. The Pods it creates should request 10 millicore cpu and 10 mebibyte memory. The Pods of that DaemonSet should run on all nodes, also controlplanes.

```
k -n project-tiger create deployment --image=httpd:2.4-alpine ds-important $do > 11.yaml

vim 11.yaml


apiVersion: apps/v1
kind: DaemonSet                                     # change from Deployment to Daemonset
metadata:
  creationTimestamp: null
  labels:                                           # add
    id: ds-important                                # add
    uuid: 18426a0b-5f59-4e10-923f-c0e078e82462      # add
  name: ds-important
  namespace: project-tiger                          # important
spec:
  #replicas: 1                                      # remove
  selector:
    matchLabels:
      id: ds-important                              # add
      uuid: 18426a0b-5f59-4e10-923f-c0e078e82462    # add
  #strategy: {}                                     # remove
  template:
    metadata:
      creationTimestamp: null
      labels:
        id: ds-important                            # add
        uuid: 18426a0b-5f59-4e10-923f-c0e078e82462  # add
    spec:
      containers:
      - image: httpd:2.4-alpine
        name: ds-important
        resources:
          requests:                                 # add
            cpu: 10m                                # add
            memory: 10Mi                            # add
      tolerations:                                  # add
      - effect: NoSchedule                          # add
        key: node-role.kubernetes.io/control-plane  # add
#status: {}                                         # remove
```

# 12

Use Namespace project-tiger for the following. Create a Deployment named deploy-important with label id=very-important (the Pods should also have this label) and 3 replicas. It should contain two containers, the first named container1 with image nginx:1.17.6-alpine and the second one named container2 with image kubernetes/pause.

There should be only ever one Pod of that Deployment running on one worker node. We have two worker nodes: cluster1-node1 and cluster1-node2. Because the Deployment has three replicas the result should be that on both nodes one Pod is running. The third Pod won't be scheduled, unless a new worker node will be added.

In a way we kind of simulate the behaviour of a DaemonSet here, but using a Deployment and a fixed number of replicas.

Answer:
There are two possible ways, one using podAntiAffinity and one using topologySpreadConstraint.

```
k -n project-tiger create deployment \
  --image=nginx:1.17.6-alpine deploy-important $do > 12.yaml

vim 12.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    id: very-important                  # change
  name: deploy-important
  namespace: project-tiger              # important
spec:
  replicas: 3                           # change
  selector:
    matchLabels:
      id: very-important                # change
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        id: very-important              # change
    spec:
      containers:
      - image: nginx:1.17.6-alpine
        name: container1                # change
        resources: {}
      - image: kubernetes/pause         # add
        name: container2                # add
      affinity:                                             # add
        podAntiAffinity:                                    # add
          requiredDuringSchedulingIgnoredDuringExecution:   # add
          - labelSelector:                                  # add
              matchExpressions:                             # add
              - key: id                                     # add
                operator: In                                # add
                values:                                     # add
                - very-important                            # add
            topologyKey: kubernetes.io/hostname             # add
status: {}
```

```
# 12.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    id: very-important                  # change
  name: deploy-important
  namespace: project-tiger              # important
spec:
  replicas: 3                           # change
  selector:
    matchLabels:
      id: very-important                # change
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        id: very-important              # change
    spec:
      containers:
      - image: nginx:1.17.6-alpine
        name: container1                # change
        resources: {}
      - image: kubernetes/pause         # add
        name: container2                # add
      topologySpreadConstraints:                 # add
      - maxSkew: 1                               # add
        topologyKey: kubernetes.io/hostname      # add
        whenUnsatisfiable: DoNotSchedule         # add
        labelSelector:                           # add
          matchLabels:                           # add
            id: very-important                   # add
status: {}
```

# 13

Create a Pod named multi-container-playground in Namespace default with three containers, named c1, c2 and c3. There should be a volume attached to that Pod and mounted into every container, but the volume shouldn't be persisted or shared with other Pods.

Container c1 should be of image nginx:1.17.6-alpine and have the name of the node where its Pod is running available as environment variable MY_NODE_NAME.

Container c2 should be of image busybox:1.31.1 and write the output of the date command every second in the shared volume into file date.log. You can use while true; do date >> /your/vol/path/date.log; sleep 1; done for this.

Container c3 should be of image busybox:1.31.1 and constantly send the content of file date.log from the shared volume to stdout. You can use tail -f /your/vol/path/date.log for this.

Check the logs of container c3 to confirm correct setup.

```
k run multi-container-playground --image=nginx:1.17.6-alpine $do > 13.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: multi-container-playground
  name: multi-container-playground
spec:
  containers:
  - image: nginx:1.17.6-alpine
    name: c1                                                                      # change
    resources: {}
    env:                                                                          
    - name: MY_NODE_NAME                                                         
      valueFrom:                                                                  
        fieldRef:                                                                 
          fieldPath: spec.nodeName                                                
    volumeMounts:                                                                 
    - name: vol                                                                   
      mountPath: /vol                                                             
  - image: busybox:1.31.1                                                         
    name: c2                                                                      
    command: ["sh", "-c", "while true; do date >> /vol/date.log; sleep 1; done"]  
    volumeMounts:                                                                 
    - name: vol                                                                   
      mountPath: /vol                                                             
  - image: busybox:1.31.1                                                         
    name: c3                                                                      
    command: ["sh", "-c", "tail -f /vol/date.log"]                                
    volumeMounts:                                                                 
    - name: vol                                                                   
      mountPath: /vol                                                             
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:                                                                        
    - name: vol                                                                   
      emptyDir: {}          
```

# 14

Use context: kubectl config use-context k8s-c1-H

You're ask to find out following information about the cluster k8s-c1-H:

How many controlplane nodes are available?
How many worker nodes are available?
What is the Service CIDR?
Which Networking (or CNI Plugin) is configured and where is its config file?
Which suffix will static pods have that run on cluster1-node1?



1
```
➜ k get node
NAME                    STATUS   ROLES          AGE   VERSION
cluster1-controlplane1  Ready    control-plane  27h   v1.26.0
cluster1-node1          Ready    <none>         27h   v1.26.0
cluster1-node2          Ready    <none>         27h   v1.26.0
```

2
```
➜ ssh cluster1-controlplane1

➜ root@cluster1-controlplane1:~# cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep range
    - --service-cluster-ip-range=10.96.0.0/12
```

3
```
➜ root@cluster1-controlplane1:~# find /etc/cni/net.d/
/etc/cni/net.d/
/etc/cni/net.d/10-weave.conflist

➜ root@cluster1-controlplane1:~# cat /etc/cni/net.d/10-weave.conflist
{
    "cniVersion": "0.3.0",
    "name": "weave",
...
```

4
-cluster1-node1

# 15

Write a command into /opt/course/15/cluster_events.sh which shows the latest events in the whole cluster, ordered by time (metadata.creationTimestamp). Use kubectl for it.

Now kill the kube-proxy Pod running on node cluster2-node1 and write the events this caused into /opt/course/15/pod_kill.log.

Finally kill the containerd container of the kube-proxy Pod on node cluster2-node1 and write the events into /opt/course/15/container_kill.log.

Do you notice differences in the events both actions caused?

```
# /opt/course/15/cluster_events.sh
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

```
k -n kube-system get pod -o wide | grep proxy # find pod running on cluster2-node1

k -n kube-system delete pod kube-proxy-z64cg
```

```
➜ ssh cluster2-node1

➜ root@cluster2-node1:~# crictl ps | grep kube-proxy
1e020b43c4423   36c4ebbc9d979   About an hour ago   Running   kube-proxy     ...

➜ root@cluster2-node1:~# crictl rm 1e020b43c4423
1e020b43c4423

➜ root@cluster2-node1:~# crictl ps | grep kube-proxy
0ae4245707910   36c4ebbc9d979   17 seconds ago      Running   kube-proxy     ...     
```

# 16

Write the names of all namespaced Kubernetes resources (like Pod, Secret, ConfigMap...) into /opt/course/16/resources.txt.

Find the project-* Namespace with the highest number of Roles defined in it and write its name and amount of Roles into /opt/course/16/crowded-namespace.txt.

```
k api-resources    # shows all

k api-resources -h # help always good

k api-resources --namespaced -o name > /opt/course/16/resources.txt
```

```
➜ k -n project-c13 get role --no-headers | wc -l
No resources found in project-c13 namespace.
0

➜ k -n project-c14 get role --no-headers | wc -l
300

➜ k -n project-hamster get role --no-headers | wc -l
No resources found in project-hamster namespace.
0

➜ k -n project-snake get role --no-headers | wc -l
No resources found in project-snake namespace.
0

➜ k -n project-tiger get role --no-headers | wc -l
No resources found in project-tiger namespace.
0
```

# 17

In Namespace project-tiger create a Pod named tigers-reunite of image httpd:2.4.41-alpine with labels pod=container and container=pod. Find out on which node the Pod is scheduled. Ssh into that node and find the containerd container belonging to that Pod.

Using command crictl:

Write the ID of the container and the info.runtimeType into /opt/course/17/pod-container.txt
Write the logs of the container into /opt/course/17/pod-container.log
 

```
k run tigers-reunite --image=httpd:2.4.41-alpine --labels "pod=container,container=pod" -n project-tiger


k -n project-tiger get pod -o wide

➜ ssh cluster1-node2

➜ root@cluster1-node2:~# crictl ps | grep tigers-reunite
b01edbe6f89ed    54b0995a63052    5 seconds ago    Running        tigers-reunite ...

➜ root@cluster1-node2:~# crictl inspect b01edbe6f89ed | grep runtimeType
    "runtimeType": "io.containerd.runc.v2",

ssh cluster1-node2 'crictl logs b01edbe6f89ed' &> /opt/course/17/pod-container.log
```

# 18

Use context: kubectl config use-context k8s-c3-CCC

There seems to be an issue with the kubelet not running on cluster3-node1. Fix it and confirm that cluster has node cluster3-node1 available in Ready state afterwards. You should be able to schedule a Pod on cluster3-node1 afterwards.

Write the reason of the issue into /opt/course/18/reason.txt.

```
➜ k get node
NAME                     STATUS     ROLES           AGE   VERSION
cluster3-controlplane1   Ready      control-plane   14d   v1.26.0
cluster3-node1           NotReady   <none>          14d   v1.26.0

➜ ssh cluster3-node1

➜ root@cluster3-node1:~# ps aux | grep kubelet
root     29294  0.0  0.2  14856  1016 pts/0    S+   11:30   0:00 grep --color=auto kubelet

➜ root@cluster3-node1:~# service kubelet status
● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
  Drop-In: /etc/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: inactive (dead) since Sun 2019-12-08 11:30:06 UTC; 50min 52s ago
...

➜ root@cluster3-node1:~# service kubelet start

➜ root@cluster3-node1:~# service kubelet status
● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
  Drop-In: /etc/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: activating (auto-restart) (Result: exit-code) since Thu 2020-04-30 22:03:10 UTC; 3s ago
     Docs: https://kubernetes.io/docs/home/
  Process: 5989 ExecStart=/usr/local/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS (code=exited, status=203/EXEC)
 Main PID: 5989 (code=exited, status=203/EXEC)

Apr 30 22:03:10 cluster3-node1 systemd[5989]: kubelet.service: Failed at step EXEC spawning /usr/local/bin/kubelet: No such file or directory
Apr 30 22:03:10 cluster3-node1 systemd[1]: kubelet.service: Main process exited, code=exited, status=203/EXEC
Apr 30 22:03:10 cluster3-node1 systemd[1]: kubelet.service: Failed with result 'exit-code'.

➜ root@cluster3-node1:~# /usr/local/bin/kubelet
-bash: /usr/local/bin/kubelet: No such file or directory

➜ root@cluster3-node1:~# whereis kubelet
kubelet: /usr/bin/kubelet

vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf # fix

systemctl daemon-reload && systemctl restart kubelet

systemctl status kubelet  # should now show running

# /opt/course/18/reason.txt
wrong path to kubelet binary specified in service config
```

# 20

Do the following in a new Namespace secret. Create a Pod named secret-pod of image busybox:1.31.1 which should keep running for some time.

There is an existing Secret located at /opt/course/19/secret1.yaml, create it in the Namespace secret and mount it readonly into the Pod at /tmp/secret1.

Create a new Secret in Namespace secret called secret2 which should contain user=user1 and pass=1234. These entries should be available inside the Pod's container as environment variables APP_USER and APP_PASS.

Confirm everything is working.

```
k create ns secret

cp /opt/course/19/secret1.yaml 19_secret1.yaml

vim 19_secret1.yaml

apiVersion: v1
data:
  halt: IyEgL2Jpbi9zaAo...
kind: Secret
metadata:
  creationTimestamp: null
  name: secret1
  namespace: secret    # change this


k -f 19_secret1.yaml create

k -n secret create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234

k -n secret run secret-pod --image=busybox:1.31.1 $do -- sh -c "sleep 5d" > 19.yaml

vim 19.yaml

# 19.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secret-pod
  name: secret-pod
  namespace: secret                       # add
spec:
  containers:
  - args:
    - sh
    - -c
    - sleep 1d
    image: busybox:1.31.1
    name: secret-pod
    resources: {}
    env:                                  # add
    - name: APP_USER                      # add
      valueFrom:                          # add
        secretKeyRef:                     # add
          name: secret2                   # add
          key: user                       # add
    - name: APP_PASS                      # add
      valueFrom:                          # add
        secretKeyRef:                     # add
          name: secret2                   # add
          key: pass                       # add
    volumeMounts:                         # add
    - name: secret1                       # add
      mountPath: /tmp/secret1             # add
      readOnly: true                      # add
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:                                # add
  - name: secret1                         # add
    secret:                               # add
      secretName: secret1                 # add
status: {}

k -f 19.yaml create

➜ k -n secret exec secret-pod -- env | grep APP
APP_PASS=1234
APP_USER=user1

➜ k -n secret exec secret-pod -- find /tmp/secret1
/tmp/secret1
/tmp/secret1/..data
/tmp/secret1/halt
/tmp/secret1/..2019_12_08_12_15_39.463036797
/tmp/secret1/..2019_12_08_12_15_39.463036797/halt

➜ k -n secret exec secret-pod -- cat /tmp/secret1/halt
#! /bin/sh
### BEGIN INIT INFO
# Provides:          halt
# Required-Start:
# Required-Stop:
# Default-Start:
# Default-Stop:      0
# Short-Description: Execute the halt command.
# Description:
...
```

# 20

Your coworker said node cluster3-node2 is running an older Kubernetes version and is not even part of the cluster. Update Kubernetes on that node to the exact version that's running on cluster3-controlplane1. Then add this node to the cluster. Use kubeadm for this.

```
➜ ssh cluster3-node2

➜ root@cluster3-node2:~# kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.0", GitCommit:"b46a3f887ca979b1a5d14fd39cb1af43e7e5d12d", GitTreeState:"clean", BuildDate:"2022-12-08T19:57:06Z", GoVersion:"go1.19.4", Compiler:"gc", Platform:"linux/amd64"}

➜ root@cluster3-node2:~# kubectl version --short
Client Version: v1.25.5
Kustomize Version: v4.5.7

➜ root@cluster3-node2:~# kubelet --version
Kubernetes v1.25.5

➜ root@cluster3-node2:~# kubeadm upgrade node
couldn't create a Kubernetes client from file "/etc/kubernetes/kubelet.conf": failed to load admin kubeconfig: open /etc/kubernetes/kubelet.conf: no such file or directory
To see the stack trace of this error execute with --v=5 or higher

➜ root@cluster3-node2:~# apt update
...
Fetched 5,775 kB in 2s (2,313 kB/s)                               
Reading package lists... Done
Building dependency tree       
Reading state information... Done
90 packages can be upgraded. Run 'apt list --upgradable' to see them.

➜ root@cluster3-node2:~# apt show kubectl -a | grep 1.26
Version: 1.26.0-00

➜ root@cluster3-node2:~# apt install kubectl=1.26.0-00 kubelet=1.26.0-00
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be upgraded:
  kubectl kubelet
2 upgraded, 0 newly installed, 0 to remove and 135 not upgraded.
Need to get 30.5 MB of archives.
After this operation, 9,996 kB of additional disk space will be used.
Get:1 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 kubectl amd64 1.26.0-00 [10.1 MB]
Get:2 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 kubelet amd64 1.26.0-00 [20.5 MB]
Fetched 30.5 MB in 1s (29.7 MB/s)  
(Reading database ... 112508 files and directories currently installed.)
Preparing to unpack .../kubectl_1.26.0-00_amd64.deb ...
Unpacking kubectl (1.26.0-00) over (1.25.5-00) ...
Preparing to unpack .../kubelet_1.26.0-00_amd64.deb ...
Unpacking kubelet (1.26.0-00) over (1.25.5-00) ...
Setting up kubectl (1.26.0-00) ...
Setting up kubelet (1.26.0-00) ...

➜ root@cluster3-node2:~# kubelet --version
Kubernetes v1.26.0
```


```
➜ ssh cluster3-controlplane1

➜ root@cluster3-controlplane1:~# kubeadm token create --print-join-command
kubeadm join 192.168.100.31:6443 --token rbhrjh.4o93r31o18an6dll --discovery-token-ca-cert-hash sha256:d94524f9ab1eed84417414c7def5c1608f84dbf04437d9f5f73eb6255dafdb18

➜ root@cluster3-controlplane1:~# kubeadm token list
TOKEN                     TTL         EXPIRES                ...
44dz0t.2lgmone0i1o5z9fe   <forever>   <never>
4u477f.nmpq48xmpjt6weje   1h          2022-12-21T18:14:30Z
rbhrjh.4o93r31o18an6dll   23h         2022-12-22T16:29:58Z
```

```
➜ ssh cluster3-node2

➜ root@cluster3-node2:~# kubeadm join 192.168.100.31:6443 --token rbhrjh.4o93r31o18an6dll --discovery-token-ca-cert-hash sha256:d94524f9ab1eed84417414c7def5c1608f84dbf04437d9f5f73eb6255dafdb18
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.


➜ root@cluster3-node2:~# service kubelet status
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/kubelet.service.d
             └─10-kubeadm.conf
     Active: active (running) since Wed 2022-12-21 16:32:19 UTC; 1min 4s ago
       Docs: https://kubernetes.io/docs/home/
   Main PID: 32510 (kubelet)
      Tasks: 11 (limit: 462)
     Memory: 55.2M
     CGroup: /system.slice/kubelet.service
             └─32510 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runti>
```

# 21

Create a Static Pod named my-static-pod in Namespace default on cluster3-controlplane1. It should be of image nginx:1.16-alpine and have resource requests for 10m CPU and 20Mi memory.

Then create a NodePort Service named static-pod-service which exposes that static Pod on port 80 and check if it has Endpoints and if it's reachable through the cluster3-controlplane1 internal IP address. You can connect to the internal node IPs from your main terminal.

```
➜ ssh cluster3-controlplane1

➜ root@cluster1-controlplane1:~# cd /etc/kubernetes/manifests/

➜ root@cluster1-controlplane1:~# kubectl run my-static-pod \
    --image=nginx:1.16-alpine \
    -o yaml --dry-run=client > my-static-pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: my-static-pod
  name: my-static-pod
spec:
  containers:
  - image: nginx:1.16-alpine
    name: my-static-pod
    resources: # add
      requests: # add
        cpu: 10m # add
        memory: 20Mi # add
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

k expose pod my-static-pod-cluster3-controlplane1 \
  --name static-pod-service \
  --type=NodePort \
  --port 80

# kubectl expose pod my-static-pod-cluster3-controlplane1 --name static-pod-service --type=NodePort --port 80
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    run: my-static-pod
  name: static-pod-service
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: my-static-pod
  type: NodePort
status:
  loadBalancer: {}

➜ k get svc,ep -l run=my-static-pod
NAME                         TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/static-pod-service   NodePort   10.99.168.252   <none>        80:30352/TCP   30s

NAME                           ENDPOINTS      AGE
endpoints/static-pod-service   10.32.0.4:80   30s

```

# 22

Check how long the kube-apiserver server certificate is valid on cluster2-controlplane1. Do this with openssl or cfssl. Write the exipiration date into /opt/course/22/expiration.

Also run the correct kubeadm command to list the expiration dates and confirm both methods show the same date.

Write the correct kubeadm command that would renew the apiserver server certificate into /opt/course/22/kubeadm-renew-certs.sh.

```
➜ ssh cluster2-controlplane1

➜ root@cluster2-controlplane1:~# find /etc/kubernetes/pki | grep apiserver
/etc/kubernetes/pki/apiserver.crt
/etc/kubernetes/pki/apiserver-etcd-client.crt
/etc/kubernetes/pki/apiserver-etcd-client.key
/etc/kubernetes/pki/apiserver-kubelet-client.crt
/etc/kubernetes/pki/apiserver.key
/etc/kubernetes/pki/apiserver-kubelet-client.key

➜ root@cluster2-controlplane1:~# openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep Validity -A2
        Validity
            Not Before: Dec 20 18:05:20 2022 GMT
            Not After : Dec 20 18:05:20 2023 GMT

➜ root@cluster2-controlplane1:~# kubeadm certs check-expiration | grep apiserver
apiserver                Jan 14, 2022 18:49 UTC   363d        ca               no      
apiserver-etcd-client    Jan 14, 2022 18:49 UTC   363d        etcd-ca          no      
apiserver-kubelet-client Jan 14, 2022 18:49 UTC   363d        ca          

# /opt/course/22/kubeadm-renew-certs.sh
kubeadm certs renew apiserver
```
