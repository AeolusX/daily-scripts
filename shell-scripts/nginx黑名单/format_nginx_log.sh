#!/bin/bash
#

CREATE_TIME='07/Mar/2019'
SEARCH_KEYWORD='/auth/checkname'
RSA_FILE='/home/discovery/.ssh/id_rsa'
EXECUTE_COMMAND="grep '$CREATE_TIME' /app/local/nginx/logs/access_ptlogin.cn.log| grep '$SEARCH_KEYWORD'"

echo "*** 获取主机日志并格式化"
echo "" >ip_list
for host in `cat hosts`
do
    ssh -o StrictHostKeyChecking=no -i $RSA_FILE zhouda@$host "$EXECUTE_COMMAND" >$host.log
    awk '{print $NF}' $host.log >>ip_list
done 
sed -i 's/"//g' ip_list

echo "*** 筛选IP出现次数大于100"
python3 getip_for_nginx.py >blockip.log

echo "*** 生成支持nginx黑名单的格式"
echo "" >blockip
for ip in `cat blockip.log`
do
    echo "if ( \$http_x_forwarded_for ~* \"$ip\") { return 403; }" >>blockip
done

echo "*** 推送blockip到主机临时目录"
for ip in `cat hosts`
do
    scp -o StrictHostKeyChecking=no -i $RSA_FILE blockip discovery@${ip}:/tmp/
    echo "$host Done."
done
