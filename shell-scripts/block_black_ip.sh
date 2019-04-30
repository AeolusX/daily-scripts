#!/bin/bash
DATE=`date +%Y%m%d%H%M%S`
NGINX_HOME=/app/local/senginx
LOG_PATH=$NGINX_HOME/logs/access_web_cn2.log
BLOCK_IP=`cat $NGINX_HOME/conf/vhosts/blockip.conf`
BLACK_IP=`tail -n 10000 $LOG_PATH | grep -E "site/ajaxLogin|site/login" | awk '{print $1,$12}' |grep -i -v -E "google|yahoo|baidu|msnbot|FeedSky|sogou" | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{if($1>20)print "deny "$2";"}'`
tail -n 10000 $LOG_PATH | grep -E "site/ajaxLogin|site/login" | awk '{print $1,$12}' |grep -i -v -E "google|yahoo|baidu|msnbot|FeedSky|sogou" | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{if($1>20)print "deny "$2";"}' > $NGINX_HOME/conf/vhosts/blockip.conf && /etc/init.d/nginx reload 
if [ -z $BLACK_IP ];then
	exit
else
	echo "$DATE	$BLOCK_IP" >> $NGINX_HOME/conf/tmp/block_ip.txt
fi
