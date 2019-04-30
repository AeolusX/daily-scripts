#!/bin/bash
zabbix_url='http://repo-ops.soft.com/soft/zabbix/zabbix-agent-3.2.11-1.el6.x86_64.rpm'
wget $zabbix_url  || exit 1
rpm -ivh zabbix-agent-3.2.11-1.el6.x86_64.rpm
wget 'http://repo-ops.soft.com/soft/zabbix/zabbix_agentd.conf'
wget 'http://repo-ops.soft.com/soft/zabbix/zabbix_config/soft.conf'
wget 'http://repo-ops.soft.com/soft/zabbix/zabbix_config/zabbix.tar.gz'
if [ -f zabbix_agentd.conf ] ; then
    cp -ar  zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf && echo "copy zabbix_agentd.conf success" || echo "copy zabbix_agentd.conf failed"
fi
[ -d /home/zabbix/agent_bin ] && rm -rf /home/zabbix/agent_bin && echo "remove file ok"
cp -ar  soft.conf /etc/zabbix/zabbix_agentd.d && echo "copy soft.conf success" || echo "copy soft.conf failed"
[ -f zabbix.tar.gz ] && tar -xf zabbix.tar.gz
if [ -d zabbix ] ; then
    cp -ar zabbix /home/ && echo "copy zabbix file ok"
else
    echo "get file failed" && exit 1
fi

chown -R  zabbix:zabbix /home/zabbix/agent_bin 
mkdir /var/lib/zabbix && chown zabbix:zabbix /var/lib/zabbix 

if ! grep 'zabbix' /etc/sudoers >/dev/null ; then
   echo 'zabbix ALL=(ALL) NOPASSWD: /bin/netstat'>>/etc/sudoers
fi
host=`hostname`
 if ! grep 'zabbix bash /home/zabbix/cron/mz_iostat_cron.sh' /etc/cron.d/zabbix >/dev/null; then
    echo "*/5 * * * * zabbix bash /home/zabbix/cron/mz_iostat_cron.sh" >> /etc/cron.d/zabbix
 fi
if [ -f /etc/zabbix/zabbix_agentd.conf ]; then
  sed -i "s/Hostname=.*/Hostname=${host}/g" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/Server=.*/Server=10.1.0.7/g" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=.*/#ServerActive=10.1.0.7/g" /etc/zabbix/zabbix_agentd.conf
  service zabbix-agent restart && echo "success start zabbix"
else 
    echo "zabbix config not found"
fi
rm -rf zabbix_agentd.conf
rm -rf soft.conf
rm -rf zabbix
rm -rf zabbix.tar.gz
rm -rf zabbix-agent-3.2.11-1.el6.x86_64.rpm


