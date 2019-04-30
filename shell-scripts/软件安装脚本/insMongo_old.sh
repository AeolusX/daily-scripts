#!/usr/bin/env bash
cat << EOF


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REQUIRED:     centOS-6 (Defulte 64bit)
DESCRIPTION:  Install Mongodb in CentOS
SOFTVERSION:    mongodb-linux-x86_64-2.6.11
AUTHOR:       
REVISION:     1.2
++++++++++++++++++++++++++++++++++++++++++++++++++++++++


EOF
usage="\033[31mUsage: $0 [mongo27017|mongo27018|mongo27019]\033[0m"

mongo27017_port=27017
mongo27018_port=27018
mongo27019_port=27019

base27017_dir=/app/local/mongo${mongo27017_port}
base27018_dir=/app/local/mongo${mongo27018_port}
base27019_dir=/app/local/mongo${mongo27019_port}

data27017_dir=/app/data/mongodb${mongo27017_port}
data27018_dir=/app/data/mongodb${mongo27018_port}
data27019_dir=/app/data/mongodb${mongo27019_port}

#yum install wget

#conf_path=${base_dir}/etc/mongodb.conf

path_test(){
    #检查mongodb目录是否存在,$1:baseDir $2:dataDir
    echo "开始检测目录"
    for dir in $1 $2
    do
        if [ -d $dir ];then
            echo -e "\033[31mError:${dir}目录已存在,请先确认次目录是否已安装mongodb,如果没有安装,请手动删除此目录,并重新运行此程序!\033[0m"
            exit 0
        else
            mkdir -p ${dir}
            echo "${dir}目录已创建完成!"
        fi
    done
}

port_test(){
    port_nu=` netstat -ntlp | grep ${1} |wc -l`
    if [ $port_nu -gt 0 ]; then
        echo -e "\033[31mError: 安装程序已退出，mongodb port 被占用,请确认该端口号\033[0m"
        exit 0
    fi
}

user_test(){
    #检查mysql用户是否存在
    num1=`id mongodb| wc -l`
	if [ $num1 -lt 1 ]; then
	    /usr/sbin/groupadd mongodb
		/usr/sbin/useradd mongodb -g mongodb -s /sbin/nologin
		echo "mongodb用户已创建完成"
	else
	    echo "Mongodb用户已存在,无需创建"
	fi
}

develop_install(){
    #安装基础开发环境
    yum -y install wget dos2unix
    echo "基础开发环境已安装完成!"
}

get_soft(){
    #软件下载
    if [ ! -e mongodb-linux-x86_64-2.6.11.tar ]; then
        echo "开始下载mongodb-linux-x86_64-2.6.11.tar"
        wget http://oms.softgy.com:810/upfiles/soft/mongodb-linux-x86_64-2.6.11.tar
        echo "软件下载成功，开始解压配置"
        Install
    fi
}

Install(){
    #解压安装mongo $1:baseDir $2:dataDir
    echo "开始解压软件."
    tar xvf mongodb-linux-x86_64-2.6.11.tar
    echo "解压已完成。"
    echo "开始配置软件"
    cp -rf mongodb-linux-x86_64-2.6.11/* ${1}
    rm -rf mongodb-linux-x86_64-2.6.11/
    mkdir  ${1}/etc ${2}/data ${2}/logs
    echo "软件配置已完成。"
    chown -R mongodb.mongodb ${1}
    chown -R mongodb.mongodb ${2}
}

config(){
    #开始生成mongo配置文件及配置环境变量,$1:baseDir $2:dateDir $3:port
    echo "开始配置mongodb.conf"
    conf_path=${1}/etc/mongodb.conf
    echo dbpath=${2}/data >>${conf_path}
    echo logpath=${2}/logs/mongodb.log >>${conf_path}
    echo pidfilepath=${2}/mongodb.pid >>${conf_path}
    echo port=${3} >>${conf_path}
    echo logappend=true >>${conf_path}
    echo journal=true >>${conf_path}
    echo fork=true >>${conf_path}
    echo nohttpinterface=true >>${conf_path}
    echo oplogSize=100 >>${conf_path}
    echo "mongodb.conf 配置已完成"
    echo export PATH=\$PATH:${1}/bin >/etc/profile.d/mongodb${3}.sh
    source /etc/profile
    echo "mongodb${3}加入环境变量已完成"
    chown -R mongodb.mongodb ${1}
    chown -R mongodb.mongodb ${2}
    #source /etc/profile
}

edit_start_file(){
    #编辑开机启动文件,$1:MysqlPort
    echo "开始导入开机启动文件############################"
    wget -P ./mongo_tmp/ http://oms.softgy.com:810/upfiles/soft/config/mongodb/mongo${1}
    dos2unix ./mongo_tmp/mongo${1}
    cp -rf ./mongo_tmp/mongo${1} /etc/init.d/
    rm -rf ./mongo_tmp/
    chmod 755 /etc/init.d/mongo${1}
    chkconfig --add mongo${1}
    echo "mongo${1}已加入开机启动"
}

start(){
    ${1}/bin/mongod -f ${1}/etc/mongodb.conf
    echo -e "\033[31m安装已全部完成,请执行下面的语句刷新环境变量\033[0m"
    echo "source /etc/profile"
}

case $1 in
    mongo27017)
        path_test ${base27017_dir} ${data27017_dir}
        port_test ${mongo27017_port}
        user_test
        develop_install
        get_soft
        Install ${base27017_dir} ${data27017_dir}
        config ${base27017_dir} ${data27017_dir} ${mongo27017_port}
        edit_start_file ${mongo27017_port}
        start ${base27017_dir}
        ;;
    mongo27018)
        path_test ${base27018_dir} ${data27018_dir}
        port_test ${mongo27018_port}
        user_test
        develop_install
        get_soft
        Install ${base27018_dir} ${data27018_dir}
        config ${base27018_dir} ${data27018_dir} ${mongo27018_port}
        edit_start_file ${mongo27018_port}
        start ${base27018_dir}
        ;;
    mongo27019)
        path_test ${base27019_dir} ${data27019_dir}
        port_test ${mongo27019_port}
        user_test
        develop_install
        get_soft
        Install ${base27019_dir} ${data27019_dir}
        config ${base27019_dir} ${data27019_dir} ${mongo27019_port}
        edit_start_file ${mongo27019_port}
        start ${base27019_dir}
        ;;
    *)
       echo -e $usage
       exit 0
       ;;
esac
