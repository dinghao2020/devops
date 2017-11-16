## 说明
```
42是物理机IP最后8八位，方便区分N个虚拟机位置
name 为kvm 虚拟机名字
ip 为kvm虚拟机IP
pre 网关前缀多少位
gw_ip  虚拟机网关
hn 虚拟机hostname
```

### 批量生出虚拟机
```
for i in {3..50};do ansible-playbook -i hosts kvm43.yml  -e "name=42-10.110.0.${i}  ip=10.110.0.${i} pre=16 gw_ip=10.110.0.1";done
```
### 单机添加
```
ansible-playbook -i hosts kvm43.yml  -e "name=42-10.110.0.51  ip=10.110.0.51 pre=16 gw_ip=10.110.0.1 hn=c42-0-51
```

### 单机删除
```
ansible-playbook -i hosts kvm43-del.yml  -e "name=42-10.110.0.4"
```
### 批量删除虚拟机
```
for i in {4..50};do ansible-playbook -i hosts kvm43-del.yml  -e "name=42-10.110.0.${i} ";done
```
