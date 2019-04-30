#!/usr/bin/env bash
cat << EOF


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REQUIRED:     centOS-6 (Defulte 64bit)
DESCRIPTION:  Install Mysql in CentOS
SOFTVERSION:  mysql-5.6.35
AUTHOR:       
REVISION:     1.0
++++++++++++++++++++++++++++++++++++++++++++++++++++++++


EOF



download_url=http://repo-ops.soft.com/soft/mysql


check_dir(){
    #检查mysql目录是否存在,$1:baseDir $2:dataDir
    echo "开始检测目录"
    for dir in $1 $2
    do
        if [ -d $dir ];then
            echo -e "\033[31m${dir}目录已存在,请先确认是否已安装mysql,如果没有安装,请手动删除此目录,并重新运行此程序!\033[0m"
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
        echo -e "\033[31mInfo: 安装程序已退出，Mysql${1}port 被占用,请确认该端口号\033[0m"
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
    yum -y install gcc gcc-c++ ncurses-devel wget dos2unix
    echo "基础开发环境已安装完成!"
}

get_soft(){
    #软件下载
    if [ ! -e mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz ]; then
        echo "开始下载mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz"
        wget ${download_url}/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
        echo "软件下载成功，开始解压配置"
    fi
}

Insall(){
    #解压安装mysql,$1:basedir,$2:datadir
    echo "开始解压软件."
    tar zxvf mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
    echo "解压已完成。"
    mv mysql-5.6.35-linux-glibc2.5-x86_64/* ${1}
    rm -rf mysql-5.6.35-linux-glibc2.5-x86_64
    echo "目录移动已完成##########################"
    chown -R mysql.mysql $1
    chown -R mysql.mysql $2
}

import_config(){
    #导入my.cnf配置文件以及配置环境变量,$1:basedir,$2:MysqlPort
    echo "开始导入my.cnf############################"
    wget -P ./mysql56_tmp/ ${download_url}/init/mysql56/my_templet.cnf
    wget -P ./mysql56_tmp/ ${download_url}/init/mysql56/mysqld_templet
	wget -P ./mysql56_tmp/ ${download_url}/init/mysql56/mysqld_safe
    dos2unix ./mysql56_tmp/mysqld_templet
    sed -i "s/{Port}/${2}/g" ./mysql56_tmp/my_templet.cnf
    sed -i "s/{Port}/${2}/g" ./mysql56_tmp/mysqld_templet
    cp -rf ./mysql56_tmp/my_templet.cnf ${1}/my.cnf
	cp -rf ./mysql56_tmp/mysqld_safe ${1}/bin/mysqld_safe
    cp -rf ./mysql56_tmp/mysqld_templet /etc/init.d/mysqld${2}
    rm -rf ./mysql56_tmp/
    chmod 755 /etc/init.d/mysqld${2}
    chkconfig --add mysqld${2}
    echo "mysqld${2}已加入开机启动"
    echo export PATH=${1}/bin:\$PATH >/etc/profile.d/mysql${2}.sh
    source /etc/profile
    echo "mysql${2}加入环境遍历完成"
}
db_config(){
    #配置数据库,$1:baseDir,$2:datadir
    mkdir -p ${2}/log
    chown -R root.mysql ${1}
    chown -R mysql.mysql ${2}
    ${1}/scripts/mysql_install_db --defaults-file=${1}/my.cnf --basedir=$1 --datadir=${2}/data/ --user=mysql
    echo "数据库初始化已完成!#########################"
}

lib_config(){
    #导出mysql lib和include文件
    echo ${1}/lib > /etc/ld.so.conf.d/mysql${2}.conf
    ldconfig
    ln -s ${1}/include /usr/include/mysql${2}
    echo "mysql${2} lib和include文件都已导出."
}

start_mysql(){
    #启动Mysql服务,$1:MysqlPort
    /etc/init.d/mysqld${1} start
}

create_password(){
    #创建Mysql 127.0.0.1 root 密码.$1:baseDir;$2:MysqlPort
    read -p "请为Mysql设置for 127.0.0.1 root密码(直接回车将设置为默认密码):" mysql_password
    if [[ ${mysql_password} = '' ]]; then
        mysql_password="Mysql@soft_default"
    fi
    ${1}/bin/mysqladmin -u root -h 127.0.0.1 -P ${2} password ${mysql_password}
    echo -e "\033[34mMysql for 127.0.0.1 root 密码为: ${mysql_password}\033[0m"
}

print_info(){
    #打印Mysql 安装信息.$1:MysqlPort;$2:basedir;$3:datadir
    echo -e "\033[34mMysql端口号: ${1}\033[0m"
    echo -e "\033[34mMysql程序存放目录: ${2}\033[0m"
    echo -e "\033[34mMysql数据存放目录: ${3}\033[0m"
    echo -e "\033[34mmy.cnf配置文件所在路径: ${2}/my.cnf\033[0m"
    echo -e "\033[31m安装已全部完成,请执行下面的语句刷新环境变量\033[0m"

    echo -e "\033[34m source /etc/profile\033[0m"
}


usage="\033[31mUsage: $0 [3306|3307|3308|3309|3310]\033[0m"
if [ $# -gt 0 ]; then
    if [ ${1} -ne 3306 -a ${1} -ne 3307 -a ${1} -ne 3308 -a ${1} -ne 3309 -a ${1} -ne 3310 ];then
        echo -e $usage
        exit 0
    else
        mysql_port=${1}
        base_dir=/app/local/mysql${mysql_port}
        data_dir=/app/data/mysqldb${mysql_port}
        check_dir ${base_dir} ${data_dir}
        check_port ${mysql_port}
        check_mysql_user
        develop_install
        get_soft
        Insall ${base_dir} ${data_dir} ${mysql_port}
        import_config ${base_dir} ${mysql_port}
        db_config ${base_dir} ${data_dir}
        lib_config ${base_dir} ${mysql_port}
        start_mysql ${mysql_port}
        create_password ${base_dir} ${mysql_port}
        print_info  ${mysql_port} ${base_dir} ${data_dir}
    fi
else
    echo -e $usage
    exit 0
fi
