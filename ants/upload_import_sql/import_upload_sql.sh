#!/bin/bash
sql_dir=/home/dh/sql
sql_url="$sql_dir/sql_url.txt"

cd  $sql_dir
down_sqls(){
    sed -i 's/blob/raw/' $sql_url
    rm -vf ${sql_dir}/*.sql 
    while read line
    do 
        curl $line -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch, br' -H 'Accept-Language: zh-CN,zh;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cookie: _gitlab_session=144180505f73a8db4895f56a4f181bac' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --compressed -O
    done < $sql_url
}

upload_import_sqls(){
    #sql_dir=/home/dh/sql
    nc -v -w 1 -z 127.0.0.1 2121 || ssh -N -f -L 2121:10.170.180.132:8015 dinghao@182.92.191.34 -p8015
    echo "清除远程sql文件夹下sql文件"
    ssh -p2121 dinghao@127.0.0.1 '/bin/rm -vf /home/dinghao/sql/*'
    rsync -avczP --delete ${sql_dir}/*.sql -e'ssh -p 2121' dinghao@127.0.0.1:~/sql/
    echo "sql 文件上传完成！"
    sleep 5
    echo "开始备份与导入数据"
    ssh -p2121 dinghao@127.0.0.1 '/bin/sudo /bin/bash -x /home/dinghao/shell/import_mysql57.sh'
    echo "sql导入完成!"
}

down_sqls || { echo "sql 文件下载失败或异常，退出！！！"  &&　exit 0 ; }
upload_import_sqls




