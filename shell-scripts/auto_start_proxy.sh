#!/bin/bash
netstat -tlnp |grep 19000
if [ $? -eq 1 ];then
 sleep 10
 echo `date` "restart codis_proxy" >> /tmp/proxy.log.time
/app/local/codis/src/github.com/CodisLabs/codis/admin/codis-proxy-admin.sh start
fi
