#!/usr/bin/env bash
base_dir=/app/local/nginx
srvurl="http://repo-ops.soft.com/soft/nginx"

path_check(){
    echo "开始检测目录"
    for dir in $base_dir
    do
        if [ -d $dir ];then
            echo -e "\033[31mError: ${dir}目录已存在,请先确认次目录是否已安装nginx,如果没有安装,请手动删除此目录,并重新运行此程序!\033[0m"
            exit 0
        else
            mkdir -p ${dir}
            echo "${dir}目录已创建完成!"
        fi
    done
}

port_check(){
    port_nu=`netstat -ntlp | grep -w 80 |wc -l`
    if [ $port_nu -gt 0 ]; then
        echo -e "\033[31mError: 安装程序已退出,nginx port被占用,请确认该端口号\033[0m"
        exit 0
    fi
}

user_check(){
    num1=`id www| wc -l`
    if [ $num1 -lt 1 ]; then
        /usr/sbin/groupadd www
        /usr/sbin/useradd www -g www
        echo "www用户已创建完成"
    else
        echo "www用户已存在,无需创建"
    fi
}

dev_install(){
    yum -y install gcc gcc-c++ autoconf automake libtool make cmake
    yum -y install zlib zlib-devel openssl openssl-devel pcre-devel
    echo "基础开发环境已安装完成!"
}

pcre_install(){
    wget $srvurl/pcre-8.37.tar.gz
    tar zxvf pcre-8.37.tar.gz 1> /dev/null
    cd pcre-8.37
    ./configure && make && make install
    cd .. && rm -rf pcre-8.37*
}

ngx_install(){
    wget $srvurl/tengine-2.1.0.tar.gz 1> /dev/null
    tar zxvf tengine-2.1.0.tar.gz 1> /dev/null
    cd tengine-2.1.0
    ./configure --user=www --group=www \
    --prefix=/app/local/nginx \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_sub_module \
    --with-http_sub_module=shared \
    --with-pcre
    make && make install && cd ..
}

ngx_config(){
    wget $srvurl/nginx.conf 1> /dev/null
    wget $srvurl/nginx 1> /dev/null
    mkdir /app/local/nginx/conf/vhosts -p
    cp nginx.conf /app/local/nginx/conf/
    echo 'export PATH=$PATH:/app/local/nginx/sbin'>>/etc/profile && source /etc/profile
    cp nginx /etc/rc.d/init.d/
    chmod +x /etc/init.d/nginx
    chkconfig --add nginx
    chkconfig nginx on
    /etc/init.d/nginx start
    rm -rf nginx && rm -rf nginx.conf && rm -rf tengine-2.1.0*
}

ngx_logrotate(){
  echo '/app/local/nginx/logs/*.log {
  missingok
  daily
  rotate 30
  notifempty
  dateext
  compress
  dateformat %Y%m%d
  create 0664 www www
  sharedscripts
  postrotate
    if [ -f /app/local/nginx/logs/nginx.pid ]; then
      kill -USR1 `cat /app/local/nginx/logs/nginx.pid`
    fi
  endscript
}' > /etc/logrotate.d/nginx
}

path_check
port_check
user_check
dev_install
pcre_install
ngx_install
ngx_config
ngx_logrotate
