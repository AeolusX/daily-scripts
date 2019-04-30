#!/bin/bash
#
############################################################################
# This script is used for block x_forward_for ip in nginx conf #
############################################################################
#
DATE=`date +%Y%m%d%H%M%S`
NGINX_HOME=/app/local/senginx
CONF_FILE=$NGINX_HOME/conf/vhosts/nginx.conf
LOG_PATH=$NGINX_HOME/logs/nginx.log
#BLACK_IP=`tail -n 10000 $LOG_PATH | grep -E "site/ajaxLogin|site/login" | awk '{print $12,$NF}'|grep -i -v -E "google|yahoo|baidu|msnbot|FeedSky|sogou" | grep -v -E "114.111.114.114|" | grep -v -E "\-|unknown|127.0.0.1"  |  awk '{print $2}' | sort | uniq -c|sort -rn|awk '{if($1>50)print $2}'|sed -e '/"/s/"//g'|perl -p -e 's/\n/|/'|sed -r 's/\|$//'`
BLACK_IP=`tail -n 10000 $LOG_PATH | grep -E "site/ajaxLogin|site/login" | awk -F'"' '{print $4, $8}' | sed 's/,/ /g' |awk '{print $1, $2}'|grep -i -v -E "google|yahoo|baidu|msnbot|FeedSky|sogou" | grep -v -E "114.111.114.114|114.111.114.114" | grep -v -E "\-|unknown|127.0.0.1"  |  awk '{print $2}' | sort | uniq -c|sort -rn|awk '{if($1>50)print $2}'|sed -e '/"/s/"//g'|perl -p -e 's/\n/|/'|sed -r 's/\|$//'`
FORWARD_FOR_IP='if ($http_x_forwarded_for ~ "'${BLACK_IP}'"){'

if [ -z $BLACK_IP ];then
	exit
else
       sed -i '/if ($http_x_forwarded_for/d' $CONF_FILE
       sed -i "/#acl forbidden_userip hdr(Cdn-Src-Ip) -i 114.114.114.114 114.114.114.114/a$FORWARD_FOR_IP" $CONF_FILE && /etc/init.d/nginx reload

fi
