# 使用说明
- 扫描出ip地址 
- zmap -p 6379 188.0.0.0/8 -B 10m -o ip.txt
- bash scan_redis.sh ip.txt
- 扫描结果会保存在文本中，最后再统计结果
