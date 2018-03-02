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


#### 3 查看rbd 信息
```
[root@c221 ~]# rbd list
foo3
kubernetes-dynamic-pvc-df16cf99-1de3-11e8-ad18-0a580af4010a
foo
foo2
test-image
testnbdrbd
[root@c221 ~]# rbd info kubernetes-dynamic-pvc-df16cf99-1de3-11e8-ad18-0a580af4010a
rbd image 'kubernetes-dynamic-pvc-df16cf99-1de3-11e8-ad18-0a580af4010a':
        size 1024 MB in 256 objects
        order 22 (4096 kB objects)
        block_name_prefix: rb.0.1179.2ae8944a
        format: 1
[root@c221 ~]# rbd list
foo3
kubernetes-dynamic-pvc-6c08298b-1dea-11e8-ad18-0a580af4010a
kubernetes-dynamic-pvc-df16cf99-1de3-11e8-ad18-0a580af4010a
foo
foo2
test-image
testnbdrbd
[root@c221 ~]# rbd info kubernetes-dynamic-pvc-6c08298b-1dea-11e8-ad18-0a580af4010a
rbd image 'kubernetes-dynamic-pvc-6c08298b-1dea-11e8-ad18-0a580af4010a':
        size 5120 MB in 1280 objects
        order 22 (4096 kB objects)
        block_name_prefix: rb.0.1194.2ae8944a
        format: 1
```
#### 其他说明
````
我们使用动态配置的卷，则默认的回收策略为 “删除”。这意味着，在默认的情况下，当 PVC 被删除时，基础的 PV 和对应的存储也会被删除。如果需要保留存储在卷上的数据，则必须在 PV 被设置之后将回收策略从 delete 更改为 retain。可以通过修改 PV 对象中的 persistentVolumeReclaimPolicy 字段的值来修改 PV 的回收策略
````
