#!/bin/bash

Pwd_file=/etc/openvpn/psw-file
Pwdinfo_dir=/etc/openvpn/openvpn_pwd_info

which pwgen || exit 1
test -d $Pwdinfo_dir || mkdir -pv $Pwdinfo_dir
cd ${Pwdinfo_dir}
\cp -f ${Pwd_file} ${Pwdinfo_dir}/backup/psw-file_`date +%F`
find ${Pwdinfo_dir}/backup/ -mtime +14 -name psw-file_* -exec rm -f {} \;

infofun(){
        case $i in  
    1) egrep -v "^$" ${Pwd_file} | awk -v i=$i '{print $i}' > ${Pwdinfo_dir}/user_info
    ;;  
    2) egrep -v "^$" ${Pwd_file} | awk -v i=$i '{print $i}' > ${Pwdinfo_dir}/pwd_info 
    ;;  
    3) egrep -v "^$" ${Pwd_file} | awk -v i=$i '{print $i}' > ${Pwdinfo_dir}/person_info 
    ;; 
esac 
}

sendmail(){
    tt=$(date +%F)
        mail_address=`echo $line | cut -d" " -f 1`
        pass_wd=`echo $line|cut -d" " -f 2`
    echo $pass_wd | mailx -s "$tt-您的VPN新密码" $mail_address
    }

for i in {1..3}; do infofun; done
pwgen -ncy1 12 `egrep -v "^$" ${Pwd_file} |wc -l` > ${Pwdinfo_dir}/pwd_info
paste user_info pwd_info person_info > ${Pwd_file}
cat ${Pwd_file} | while read line; do sendmail; done
