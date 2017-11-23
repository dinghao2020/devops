


### not ready
```
tail -f /var/log/message

Nov 23 15:06:24 c43-0-17 kubelet: W1123 15:06:24.338346   30222 cni.go:196] Unable to update cni config: No networks found in /etc/cni/net.d
Nov 23 15:06:24 c43-0-17 kubelet: E1123 15:06:24.338525   30222 kubelet.go:2095] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized

执行
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"



```


```

[root@c199 ~]# kubectl get nodes
Unable to connect to the server: x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "kubernetes")
[root@c199 ~]# 
[root@c199 ~]# 
[root@c199 ~]# export KUBECONFIG=/etc/kubernetes/kubelet.conf
[root@c199 ~]# kubectl get nodes


```

### k8s-dns 启动异常

```
applying cgroup configuration for process caused \"No such device or address\""


Here's how to make sure docker and kubelet use same cgroups driver by explicitly configuring both:

Docker:

$ cat /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=cgroupfs"]
}
Kubelet (when set up using with kubeadm):

$ cat /etc/systemd/system/kubelet.service.d/05-custom.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs"
Don't forget to systemctl daemon-reload and restart the services after changing the configs.
```

### 连接k8s控制面板
```
[root@c199 ~]# cat dashboard-admin.yaml 
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
  
```

```

kubectl create -f deploy/kube-config/rbac/heapster-rbac.yaml

E1122 05:52:53.288388       1 reflector.go:190] k8s.io/heapster/metrics/util/util.go:51: Failed to list *v1.Node: nodes is forbidden: User "system:serviceaccount:kube-system:heapster" cannot list nodes at the cluster scope
```

## 报错异常 unknown container

```
/system.slice/docker.service

journalctl -u kubelet -f  
异常
unknown container /system.slice/docker.service

启动命令添加 --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice
vim  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_AUTHZ_ARGS $KUBELET_CADVISOR_ARGS $KUBELET_CGROUP_ARG
S $KUBELET_CERTIFICATE_ARGS $KUBELET_EXTRA_ARGS --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice

systemctl daemon-reload
systemctl restart kubelet
```
### 如果解决了您的问题，欢迎打赏  
<img src="wxzf.jpeg" width = "200" height = "200" />

## k8s 1.8+ 私有仓库镜像，hosts 改名，直接pull(收费),欢迎骚扰 
<img src="add.jpeg" width = "200" height = "200" />
