#!/bin/bash
set -x

centos_version(){
  yum install lsb -y
  #version=$(lsb_release -a | grep Release | awk '{print $2}')
  version=$(lsb_release -rs)
  export version
}


zabbix_install()
{
 yum install -y sysstat
 # install zabbix-agent
  zbxurl="http://repo-ops.soft.com/soft/zabbix"
  filepath=$(cd "$(dirname "$0")"; pwd)
  cd $filepath
  if [[ $version =~ ^6 ]]; then
    wget $zbxurl/zabbix-agent-2.2.10-1.el6.x86_64.rpm || exit 1
    wget $zbxurl/zabbix-2.2.10-1.el6.x86_64.rpm || exit 1
    rpm -ivh zabbix-agent-2.2.10-1.el6.x86_64.rpm zabbix-2.2.10-1.el6.x86_64.rpm
    rm -rf zabbix*
  elif [[ $version =~ ^7 ]]; then
    wget $zbxurl/zabbix22-agent-2.2.16-1.el7.x86_64.rpm || exit 1
    wget $zbxurl/zabbix22-2.2.16-1.el7.x86_64.rpm || exit 1
    rpm -ivh zabbix22-agent-2.2.16-1.el7.x86_64.rpm zabbix22-2.2.16-1.el7.x86_64.rpm
    rm -rf zabbix*
  fi
}

zabbix_config()
{
wget 'http://repo-ops.soft.com/soft/zabbix/zabbix2.2_config/zabbix_agentd.conf'
wget 'http://repo-ops.soft.com/soft/zabbix/zabbix2.2_config/soft.conf'
wget 'http://repo-ops.soft.com/soft/zabbix/zabbix2.2_config/zabbix.tar.gz'
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
[ ! -d /var/lib/zabbix ]&& mkdir /var/lib/zabbix && chown zabbix:zabbix /var/lib/zabbix 

if ! grep 'zabbix' /etc/sudoers >/dev/null ; then
   echo 'zabbix ALL=(ALL) NOPASSWD: /bin/netstat'>>/etc/sudoers
fi
host=`hostname`
 if ! grep 'zabbix bash /home/zabbix/cron/mz_iostat_cron.sh' /etc/cron.d/zabbix >/dev/null; then
    echo "*/5 * * * * zabbix bash /home/zabbix/cron/mz_iostat_cron.sh" >> /etc/cron.d/zabbix
 fi
if [ -f /etc/zabbix/zabbix_agentd.conf ]; then
  sed -i "s/Hostname=.*/Hostname=${host}/g" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/Server=.*/Server=10.105.109.252/g" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=.*/#ServerActive=10.105.109.252/g" /etc/zabbix/zabbix_agentd.conf
  service zabbix-agent restart && echo "success start zabbix"
  chkconfig  zabbix-agent on && echo "success add zabbix to chkconfig"
else 
    echo "zabbix config not found"
fi
rm -rf zabbix_agentd.conf
rm -rf soft.conf
rm -rf zabbix
rm -rf zabbix.tar.gz
}

centos_version
zabbix_install
zabbix_config



