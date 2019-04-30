#!/usr/bin/env bash
base_dir=/app/local/php
srvurl="http://repo-ops.soft.com/soft/php"

path_check(){
    echo "开始检测目录"
    for dir in $base_dir
    do
        if [ -d $dir ];then
            echo -e "\033[31mError:${dir}目录已存在,请先确认次目录是否已安装php,如果没有安装,请手动删除此目录,并重新运行此程序!\033[0m"
            exit 0
        else
            mkdir -p ${dir}
            echo "${dir}目录已创建完成!"
        fi
    done
}

port_check(){
    port_nu=`netstat -ntlp | grep -w 9000 |wc -l`
    if [ $port_nu -gt 0 ]; then
        echo -e "\033[31mError: 安装程序已退出，PHP port 被占用,请确认该端口号\033[0m"
        exit 0
    fi
}

user_check(){
    num1=`id www| wc -l`
    if [ $num1 -lt 1 ]; then
        /usr/sbin/groupadd www
        /usr/sbin/useradd www -g www
		mkdir /home/www/.ssh -p
		cd /home/www/.ssh && wget $srvurl/authorized_keys
		chmod 600 /home/www/.ssh/authorized_keys
		chmod 700 /home/www/.ssh/
		chown www:www /home/www/.ssh -R
        echo "www用户已创建完成"
    else
        echo "www用户已存在,无需创建"
    fi
}

dev_install(){
    yum -y install yum-fastestmirror
    yum remove httpd mysql mysql-server php php-cli php-common php-devel php-gd  -y
    yum install -y wget gcc gcc-c++ openssl* curl curl-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel gd gd2 gd-devel gd2-devel libaio autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel
    echo "基础开发环境已安装完成!"
}

soft_install(){
    wget $srvurl/libmcrypt-2.5.8.tar.gz
    tar -zxvf libmcrypt-2.5.8.tar.gz 1> /dev/null
    cd libmcrypt-2.5.8
    ./configure && make && make install
    cd ../ && rm -rf libmcrypt-2.5.8*

    wget $srvurl/mhash-0.9.9.9.tar.gz
    tar -zxvf mhash-0.9.9.9.tar.gz 1> /dev/null
    cd mhash-0.9.9.9
    ./configure
    make && make install
    cd ../ && rm -rf mhash-0.9.9.9*

    wget $srvurl/mcrypt-2.6.8.tar.gz
    tar -zxvf mcrypt-2.6.8.tar.gz 1> /dev/null
    cd mcrypt-2.6.8
    LD_LIBRARY_PATH=/usr/local/lib ./configure
    make && make install
    cd ../ && rm -rf mcrypt-2.6.8*
}

php5.5_install(){
    wget $srvurl/php5.5/php-5.5.27.tar.gz
    tar zxvf php-5.5.27.tar.gz 1> /dev/null
    cd php-5.5.27
    ./configure --prefix=/app/local/php \
    --with-config-file-path=/app/local/php/etc \
    --enable-fpm \
    --enable-mbstring \
    --with-mhash \
    --with-mcrypt \
    --with-curl \
    --with-openssl \
    --with-mysql=mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd
    make && make install
    cp ./sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm
    cd ../ && rm -rf php-5.5.27*

    wget $srvurl/php5.5/src/memcache-3.0.8.tgz
    tar zxvf memcache-3.0.8.tgz  1> /dev/null
    cd memcache-3.0.8
    /app/local/php/bin/phpize
    ./configure --enable-memcache \
    --with-php-config=/app/local/php/bin/php-config \
    --with-zlib-dir
    make && make install
    cd ../ && rm -rf memcache-3.0.8*

    wget $srvurl/php5.5/src/mongo-1.6.10.tgz
    tar zxvf mongo-1.6.10.tgz  1> /dev/null
    cd mongo-1.6.10
    /app/local/php/bin/phpize
    ./configure --with-php-config=/app/local/php/bin/php-config
    make && make install
    cd ../ && rm -rf mongo-1.6.10*

    wget $srvurl/php5.5/src/redis-2.2.7.tgz
    tar zxvf redis-2.2.7.tgz  1> /dev/null
    cd redis-2.2.7
    /app/local/php/bin/phpize
    ./configure --with-php-config=/app/local/php/bin/php-config
    make && make install
    cd ../ && rm -rf redis-2.2.7*

    wget $srvurl/php5.5/init/php.ini
    wget $srvurl/php5.5/init/php-fpm.conf
}

php7.0_install(){
    wget $srvurl/php7.0/src/libmemcached-1.0.18.tar.gz
    tar -zxvf libmemcached-1.0.18.tar.gz 1> /dev/null
    cd libmemcached-1.0.18
    ./configure --prefix=/app/local/libmemcached --with-memcached
    make && make install
    cd ../ && rm -rf libmemcached-1.0.18*

    wget $srvurl/php7.0/php-7.0.4.tar.gz
    tar -zxvf php-7.0.4.tar.gz 1> /dev/null
    cd php-7.0.4
    ./configure --prefix=/app/local/php \
    --with-config-file-path=/app/local/php/etc \
    --enable-fpm \
    --enable-mbstring \
    --with-mhash \
    --with-mcrypt \
    --with-curl \
    --with-openssl \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd
    make && make install
    cp ./sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm
    cd ../ && rm -rf php-7.0.4*

    wget $srvurl/php7.0/src/php-memcached-php7.zip
    unzip php-memcached-php7.zip  1> /dev/null
    cd php-memcached-php7
    /app/local/php/bin/phpize
    ./configure --enable-memcached \
    --with-php-config=/app/local/php/bin/php-config \
    --with-zlib-dir \
    --with-libmemcached-dir=/app/local/libmemcached \
    --disable-memcached-sasl
    make && make install
    cd ../ && rm -rf php-memcached-php7*

    wget $srvurl/php7.0/src/pecl-memcache-php7.zip
    unzip pecl-memcache-php7.zip  1> /dev/null
    cd pecl-memcache-php7
    /app/local/php/bin/phpize
    ./configure --with-php-config=/app/local/php/bin/php-config
    make && make install
    cd ../ && rm -rf pecl-memcache-php7*

    wget $srvurl/php7.0/src/mongodb-1.1.5.tgz
    tar zxvf mongodb-1.1.5.tgz  1> /dev/null
    cd mongodb-1.1.5
    /app/local/php/bin/phpize
    ./configure --with-php-config=/app/local/php/bin/php-config
    make && make install
    cd ../ && rm -rf mongodb-1.1.5*

    wget $srvurl/php7.0/src/phpredis-php7.zip
    unzip phpredis-php7.zip  1> /dev/null
    cd phpredis-php7
    /app/local/php/bin/phpize
    ./configure --with-php-config=/app/local/php/bin/php-config
    make && make install
    cd ../ && rm -rf phpredis-php7*

    wget $srvurl/php7.0/init/php.ini
    wget $srvurl/php7.0/init/php-fpm.conf
}

php_config(){
    cp php.ini /app/local/php/etc/
    cp php-fpm.conf /app/local/php/etc/
    echo 'export PATH=$PATH:/app/local/php/bin'>>/etc/profile && source /etc/profile
    touch /app/local/php/var/log/php-fpm.slow.log
    chmod +x /etc/rc.d/init.d/php-fpm
    chkconfig --add php-fpm
    chkconfig php-fpm on
    /etc/init.d/php-fpm start
    rm -rf  php.ini && rm -rf php-fpm.conf && rm -rf package.xml
}

php_logrotate(){
  echo '/app/local/php/var/log/*.log {
  daily
  missingok
  notifempty
  nocompress
  dateext
  dateformat %Y%m%d
  rotate 20
  sharedscripts
  postrotate
  if [ -s "/app/local/php/var/run/php-fpm.pid" ] ; then
    /bin/kill -SIGUSR1 `cat /app/local/php/var/run/php-fpm.pid 2>/dev/null` 2>/dev/null || true
  fi
  endscript
}' > /etc/logrotate.d/php-fpm
}

php_package_choice(){
    read -p "Please choose php version (press 5.5/7.0) :" php_version
    case $php_version in
        5|5.5|php5.5)
            echo "php5.5 will be installed."
            path_check
            port_check
            user_check
            dev_install
            soft_install
            php5.5_install
            php_config
            php_logrotate
        ;;
        7|7.0|php7)
            echo "php7.0 will be installed."
            path_check
            port_check
            user_check
            dev_install
            soft_install
            php7.0_install
            php_config
            php_logrotate
        ;;
        *)
            echo "Your input is wrong, please try again."
            php_package_choice
        ;;
    esac
}

php_package_choice
