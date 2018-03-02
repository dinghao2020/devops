### ceph 在k8s 上的应用实践

#### 1 下载插件
```
默认rbd不存在，网上教程几乎没有一个直接拿来用的，记录一下踩坑
github地址: https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd/deploy
注意说明及应用

  wget https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/ceph/rbd/deploy/rbac/clusterrole.yaml
  wget https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/ceph/rbd/deploy/rbac/clusterrolebinding.yaml
  wget https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/ceph/rbd/deploy/rbac/deployment.yaml
  wget https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/ceph/rbd/deploy/rbac/role.yaml
  wget https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/ceph/rbd/deploy/rbac/rolebinding.yaml
  wget https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/ceph/rbd/deploy/rbac/serviceaccount.yaml
 
  
暂时使用默认的命名空间，也可以自行指定(可以提前拉取镜像: ansible -i hosts k8spro -mshell -a'docker pull quay.io/external_storage/rbd-provisioner:latest' )


NAMESPACE=default
sed -r -i "s/namespace: [^ ]+/namespace: $NAMESPACE/g" ./clusterrolebinding.yaml ./rolebinding.yaml
kubectl -n $NAMESPACE apply -f ./

查看是否有 rbd-provisioner开头运行的容器
[root@k8s-2-1 tt1]# kubectl get pods
NAME                                 READY     STATUS    RESTARTS
rbd-provisioner-6b8b6c77-rqlkt       1/1       Running   0          3h
```
---


#### 2 开始调用rbd及pvc绑定
```

1 创建 secret ----> 2 创建 StorageClass ----> 3 PersistentVolumeClaim ----> 4 测试
1 
cat > ceph-secret-admin.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret-admin
type: "kubernetes.io/rbd"  
data:
  key: QVFBdEZIQmFWWllSQVJBQVNkSEVlbGVkeitSbjhVMDV3MEdGZUE9PQ==
EOF

2 
cat > rbd-storage-class.yaml << EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: rbd
provisioner: ceph.com/rbd
parameters:
  monitors: 10.130.21.222:6789
  adminId: admin
  adminSecretName: ceph-secret-admin
  adminSecretNamespace: default
  pool: rbd
  userId: admin
  userSecretName: ceph-secret-admin
EOF

3 
cat > rbd-dyn-pv-claim.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ceph-rbd-dyn-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: rbd
  resources:
    requests:
      storage: 1Gi
EOF

4
cat > rbd-dyn-pvc-pod1.yaml < EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: rbd-dyn-pvc-pod
  name: ceph-rbd-dyn-pv-pod1
spec:
  containers:
  - name: ceph-rbd-dyn-pv-busybox1
    image: busybox
    command: ["sleep", "60000"]
    volumeMounts:
    - name: ceph-dyn-rbd-vol1
      mountPath: /mnt/ceph-dyn-rbd-pvc/busybox
      readOnly: false
  volumes:
  - name: ceph-dyn-rbd-vol1
    persistentVolumeClaim:
      claimName: ceph-rbd-dyn-pv-claim
EOF
 
kubectl get sc,pv,pvc,pod
kubectl exec -it ceph-rbd-dyn-pv-pod1  -- /bin/sh
kubectl exec -it ceph-rbd-dyn-pv-pod1  -- df -Th
/dev/rbd0            ext4          975.9M      2.5M    906.2M   0% /mnt/ceph-dyn-rbd-pvc/busybox

```


