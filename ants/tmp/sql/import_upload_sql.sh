#!/bin/bash
sql_dir=/home/dh/sql
sql_url="$sql_dir/sql_url.txt"

cd  $sql_dir
down_sqls(){
    sed -i 's/blob/raw/' $sql_url
    rm -vf ${sql_dir}/*.sql 
    while read line
    do 
        curl $line -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch, br' -H 'Accept-Language: en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Cookie: OUTFOX_SEARCH_USER_ID_NCOO=2062535471.7125645; collapsed_nav=false; _gitlab_session=cdcc68e3d362e4937fcce7ffb550c194; event_filter=all; user_callout_dismissed=true' -H 'Connection: keep-alive' --compressed --compressed -O
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




