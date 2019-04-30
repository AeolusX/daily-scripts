#!/usr/bin/env bash
cat << EOF


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REQUIRED:     centOS-6 (Defulte 64bit)
DESCRIPTION:  Install Mysql in CentOS
SOFTVERSION:    mysql-5.5.46
AUTHOR:       
REVISION:     1.2
++++++++++++++++++++++++++++++++++++++++++++++++++++++++


EOF

usage="Usage: $0 [mysql3306|mysql3307|mysql3308]"


mysql3306_port=3306
mysql3307_port=3307
mysql3308_port=3308

base3306_dir=/app/local/mysql3306
base3307_dir=/app/local/mysql3307
base3308_dir=/app/local/mysql3308

data3306_dir=/app/data/mysqldb3306
data3307_dir=/app/data/mysqldb3307
data3308_dir=/app/data/mysqldb3308

check_dir(){
    #检查mysql目录是否存在,$1:baseDir $2:dataDir
    echo "开始检测目录"
    for dir in $1 $2
    do
        if [ -d $dir ];then
            echo "${dir}目录已存在,请先确认是否已安装mysql,如果没有安装,请手动删除此目录,并重新运行此程序!"
            exit 0
        else
            mkdir -p $dir
            echo "${dir}目录已创建完成!"
        fi
    done
}

check_port(){
    #检查mysql端口号是否被占用,$1:MysqlPort
    echo "开始检测端口号"
    port_nu=` netstat -ntlp | grep $1 |wc -l`
    if [ $port_nu -gt 0 ]; then
        echo "Info: 安装程序已退出，Mysql${1}port 被占用,请确认该端口号"
        exit 0
    else
        echo "Mysql ${1} 端口号正常!"
    fi
}

check_mysql_user(){
    #检查mysql用户是否存在
    num1=`id mysql| wc -l`
	if [ $num1 -lt 1 ]; then
	    /usr/sbin/groupadd mysql
		/usr/sbin/useradd mysql -g mysql -s /sbin/nologin
		echo "Mysql用户已创建完成"
	fi
}

develop_install(){
    #安装基础开发环境
    yum -y install gcc gcc-c++ ncurses-devel perl wget cmake
    echo "基础开发环境已安装完成!"
}

get_soft(){
    if [ ! -e mysql-5.5.46-2.tar ]; then
        echo "开始下载mysql-5.5.46-2.tar"
        wget http://oms.softgy.com:810/upfiles/soft/mysql-5.5.46-2.tar
        echo "软件下载成功，开始解压配置"
    fi
}

Insall(){
    #解压编译安装mysql,$1:basedir,$2:datadir
    echo "开始解压软件."
    tar xvf mysql-5.5.46-2.tar
    echo "解压已完成。"
    cd mysql-5.5.46
    cmake . -DCMAKE_INSTALL_PREFIX=${1} -DMYSQL_DATADIR=${2}/data -DSYSCONFDIR=${1} -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1  -DWITH_LIBWRAP=0 -DMYSQL_UNIX_ADDR=${2}/data/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_USER=mysql -DMYSQL_TCP_PORT=${3}
    echo "Cmake已完成##############################!"
    make && make install
    echo "编译安装已完成##########################"
    chown -R mysql.mysql $1
    chown -R mysql.mysql $2
}

import_config(){
    #导入my.cnf配置文件,$1:MysqlPort,$2:basedir
    echo "开始导入my.cnf############################"
    wget -P ./mysql55_tmp/ http://oms.softgy.com:810/upfiles/soft/config/mysql55/my${1}.cnf
    wget -P ./mysql55_tmp/ http://oms.softgy.com:810/upfiles/soft/config/mysql55/mysqld${1}
    dos2unix ./mysql55_tmp/mysqld${1}
    cp -rf ./mysql55_tmp/my${1}.cnf ${2}/my.cnf
    cp -rf ./mysql55_tmp/mysqld${1} /etc/init.d/
    rm -rf ./mysql55_tmp/
    #cp -rf ${2}/support-files/mysql.server /etc/init.d/mysqld${1}
    chmod 755 /etc/init.d/mysqld${1}
    chkconfig --add mysqld${1}
    echo "mysqld${1}已加入开机启动"
}
db_config(){
    #配置数据库,$1:baseDir,$2:datadir
    mkdir -p ${2}/log
    chown -R root.mysql ${1}
    chown -R mysql.mysql ${2}
    ${1}/scripts/mysql_install_db --defaults-file=${1}/my.cnf --basedir=$1 --datadir=${2}/data/ --user=mysql
    echo "数据库初始化已完成!#########################"
}

start_mysql(){
    #启动Mysql服务,$1:MysqlPort
    /etc/init.d/mysqld${1} start
}

case $1 in
    mysql3306)
        check_dir ${base3306_dir} ${data3306_dir}
        check_port ${mysql3306_port}
        check_mysql_user
        develop_install
        get_soft
        Insall ${base3306_dir} ${data3306_dir} ${mysql3306_port}
        import_config ${mysql3306_port} ${base3306_dir}
        db_config ${base3306_dir} ${data3306_dir}
        start_mysql ${mysql3306_port}
        ;;
    mysql3307)
        check_dir ${base3307_dir} ${data3307_dir}
        check_port ${mysql3307_port}
        check_mysql_user
        develop_install
        get_soft
        Insall ${base3307_dir} ${data3307_dir} ${mysql3307_port}
        import_config ${mysql3307_port} ${base3307_dir}
        db_config ${base3307_dir} ${data3307_dir}
        start_mysql ${mysql3307_port}
        ;;
    mysql3308)
        check_dir ${base3308_dir} ${data3308_dir}
        check_port ${mysql3308_port}
        check_mysql_user
        develop_install
        get_soft
        Insall ${base3308_dir} ${data3308_dir} ${mysql3308_port}
        import_config ${mysql3308_port} ${base3308_dir}
        db_config ${base3308_dir} ${data3308_dir}
        start_mysql ${mysql3308_port}
        ;;
    *)
       echo $usage
       exit 0
       ;;
esac






