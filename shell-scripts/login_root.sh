#!/usr/bin/env bash
#控制是否允许root通过ssh登录,

usage="Usage: login_root.sh [start|stop]"

root_off(){
    #拒绝root通过ssh登录
    sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
    sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
    service sshd restart
}

root_on(){
    #允许root通过ssh登录
    sed -i "s/^PermitRootLogin.*/#PermitRootLogin no/g" /etc/ssh/sshd_config
    service sshd restart
}

case $1 in
    start)
        root_on
        ;;
    stop)
        root_off
        ;;
    *)
        echo $usage
        exit 1
        ;;
esac
