#!/usr/bin/env bash
cat << EOF

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REQUIRED:     centOS-6 (Defulte 64bit)
DESCRIPTION:  Install memcached in CentOS
AUTHOR:       
REVISION:     1.0
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

EOF

usage="\033[31mUsage: $0 [install]\033[0m"

memcached_port=11211
soft1=libevent
soft2=memcached


rpm_test(){
  #检查rpm是否存在,$1:dirname
  echo "开始判断${1}是否安装"
  rpm_num=`rpm -qa ${1}| wc -l`
  rpm_na=`rpm -qa ${1}`
  if [ ${rpm_num} -lt 1 ]; then
    echo "${1}软件不存在,开始安装"
    yum install -y ${1}
  else
    echo "${rpm_na}软件已存在"
  fi
}

port_test(){
  #检查端口号是否占用,$1:Port
  echo "开始检查端口号是否被占用...."
  port_nu=` netstat -ntlp | grep ${1} |wc -l`
  if [ $port_nu -gt 0 ]; then
    echo -e "\033[31mError: 安装程序已退出，memcached ${1} 被占用,请确认该端口号\033[0m"
    exit 0
  else
    echo "端口号未被占用,继续下一步"
  fi
}

case ${1} in
    install)
        port_test ${memcached_port}
        rpm_test ${soft1}
        rpm_test ${soft2}
        echo "所有操作已结束"
        ;;
    *)
        echo -e ${usage}
        ;;
esac


