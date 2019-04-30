#!/bin/bash
function  Usage()
{
echo "$0 [-H hostname | -h help"
exit 1
}

#获取输入主机名，如果没有给出主机名退出
while getopts H:h OPTION
do
  case $OPTION in
       H)host=$OPTARG
       ;;
       h)Usage
       ;;
       ?)Usage
       ;;
   esac

done

function set_sys_host()
{

if [ ! -z $host ] ; then
   hostname ${host}
   sed -i '/HOSTNAME=/{d}' /etc/sysconfig/network
    if ! grep 'HOSTNAME=' /etc/sysconfig/network >/dev/null; then
      echo "HOSTNAME=${host}" >> /etc/sysconfig/network
    fi
echo "modify system hostname OK"
else
echo "hostname not given ,exit "  && exit 1
fi

}


function set_salt_host()
{
sed -i "s/id:[ ].*/id: ${host}/g" /etc/salt/minion
if [ -d /etc/salt/pki/minion/minion/ ] ; then
     service salt-minion stop
     rm -rf /etc/salt/pki/minion/minion/*
fi
service salt-minion restart

}

function set_zabbix_host()
{
if [ -f /etc/zabbix/zabbix_agentd.conf ]; then
sed -i "s/Hostname=.*/Hostname=${host}/g" /etc/zabbix/zabbix_agentd.conf
service zabbix-agent stop
service zabbix-agent start && echo "success start zabbix"
else 
echo "zabbix config not found"
fi
}


set_sys_host
set_salt_host
set_zabbix_host


