* virt-clone -o  kvm_client00 -n kvm_client01 -f /var/lib/libvirt/images/kvm_client01.img

### range ip
* for i in {121..124};do ansible-playbook -i hosts kvm12.yml  -e "name=c-10.130.21.${i}  ip=10.130.21.${i}";done




* ansible-playbook -i hosts kvm.yml  -e "name=c-10.98.130.21  ip=10.98.130.21" 



```
[root@dinghao ~]# virt-clone -h
usage: virt-clone --original [NAME] ...

复制一个虚拟机，需修改如 MAC 地址，名称等所有主机端唯一的配置。

虚拟机的内容并没有改变：virt-clone 不修改任何客户机系统内部的配置，它只复制磁盘和主机端的修改。所以像修改密码，修改静态 IP 地址等操作都在本工具复制范围内。如何修改此类型的配置，请参考 virt-sysprep(1)。

optional arguments:
  -h, --help            show this help message and exit
  --version             show program's version number and exit
  --connect URI         通过 libvirt URI 连接到虚拟机管理程序

通用选项:
  -o ORIGINAL_GUEST, --original ORIGINAL_GUEST
                        原始客户机名称；必须为关闭或者暂停状
                        态。
  --original-xml ORIGINAL_XML
                        将 XML 文件用于原始客户机。
  --auto-clone          从原始客户机配置中自动生成克隆名称和
                        存储路径。
  -n NEW_NAME, --name NEW_NAME
                        新客户机的名称
  --reflink             使用 btrfs COW 轻量副本

存储配置:
  -f NEW_DISKFILE, --file NEW_DISKFILE
                        为新客户机使用新的磁盘镜像文件
  --force-copy TARGET   强制复制设备(例如：如果 'hdc'
                        是只读光驱设备，则使用 --force-copy=hdc)
  --nonsparse           不使用稀疏文件作为克隆的磁盘镜像
  --preserve-data       不克隆存储，通过 --file
                        参数指定的新磁盘镜像将保留不变

联网配置:
  -m NEW_MAC, --mac NEW_MAC
                        为克隆客户机生成新的固定 MAC
                        地址。默认为随机生成 MAC。

其它选项:
  --replace             不检查命名冲突，覆盖任何使用相同名称
                        的客户机。
  --print-xml           打印生成的 XML 域，而不是创建客户机。
  --check CHECK         启用或禁用验证检查。例如：
                        --check path_in_use=off
                        --check all=off
  -q, --quiet           抑制非错误输出
  -d, --debug           输入故障排除信息

请参考 man 手册，以便了解示例和完整的选项语法
```
