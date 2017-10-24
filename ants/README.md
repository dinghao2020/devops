# 项目说明
## sql 自动执行
### 使用说明
- *注意脚本内定义路径，根据需要自行调整
- 1 把开发给定的url 写入sql_url.txt
- 2 bash  执行　import_upload_sql.sh

 > - bash import_upload_sql.sh 
 > - 或chmod +x import_upload_sql.sh, ./import_upload_sql.sh

## 初始化新增服务器
- 1 利用ansible 指定新服务器，利用script 模块本地脚本远程执行　
- 2 利用etcd 更新iptables ，已经集成在init_new_servers 
