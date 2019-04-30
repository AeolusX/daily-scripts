#!/usr/bin/env bash
cat << EOF


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REQUIRED:     centOS-6 (Defulte 64bit)
DESCRIPTION:  Install Redis sentinel  in CentOS
SOFTVERSION:    Redis-2.8.23
AUTHOR:      
REVISION:     0.1
++++++++++++++++++++++++++++++++++++++++++++++++++++++++


EOF


download_url=http://repo-ops.soft.com

path_test(){
    #检查redis目录是否存在,$1:baseDir
    echo "开始检测目录"
    for dir in $1
    do
        if [ -d $dir ];then
            echo -e "\033[31mError:${dir}目录已存在,请先确认次目录是否已安装redis sentinel ,如果没有安装,请手动删除此目录,并重新运行此程序!\033[0m"
            exit 0
        else
            mkdir -p ${dir}
            echo "${dir}目录已创建完成!"
        fi
    done
}

port_test(){
    #检查端口号是否占用,$1:Port
    port_nu=` netstat -ntlp | grep ${1} |wc -l`
    if [ $port_nu -gt 0 ]; then
        echo -e "\033[31mError: 安装程序已退出，redis sentinel port:${1}被占用,请确认该端口号\033[0m"
        exit 0
    fi
}

develop_install(){
    #安装基础开发环境
    yum -y install gcc-c++ wget dos2unix
    echo "基础开发环境已安装完成!"
}


get_soft(){
    #软件下载
    if [ ! -e redis-2.8.23.tar ]; then
        echo "开始下载redis-2.8.23.tar"
        wget ${download_url}/soft/redis/redis-2.8.23.tar
        echo "软件下载成功，开始解压配置"
    fi
}

Install(){
    #解压安装redis $1:baseDir
    echo "开始解压软件."
    if [ ! -e redis-2.8.23.tar ]; then
        echo -e "\033[31mError: redis-2.8.23.tar下载失败，请检测网络\033[0m"
        exit 0
    fi

    tar xvf redis-2.8.23.tar
    echo "解压已完成。"
    cd redis-2.8.23
    make
    echo "编译已完成,开始配置软件"
    mkdir ${1}/bin ${1}/log ${1}/data
    cp -rf src/redis-server ${1}/bin
    cp -rf src/redis-benchmark ${1}/bin
    cp -rf src/redis-cli ${1}/bin
    cp -rf src/redis-check-aof ${1}/bin
    cp -rf src/redis-check-dump ${1}/bin
    cp -rf src/redis-sentinel ${1}/bin
    cd ../
    rm -rf ./redis-2.8.23
    echo "软件配置已完成."
}

config(){
    #开始修改配置文件,$1:baseDir,$2:sentinel port $3 redisport
    echo "开始修改配置sentinel.conf"
    wget -P ./redis_tmp/ ${download_url}/soft/config/redis/sentinel/sentinel_template.conf
    if [ -f ./redis_tmp/sentinel_template.conf ];then
        sed -i "s/{Port}/${2}/g" ./redis_tmp/sentinel_template.conf
        sed -i "s/{Rport}/${3}/g" ./redis_tmp/sentinel_template.conf
        cp -rf ./redis_tmp/sentinel_template.conf ${1}/sentinel.conf
        chown -R root.root ${1}
        echo "sentinel.conf配置文件修改完成!"
        echo export PATH=\$PATH:${1}/bin >/etc/profile.d/sentinel.sh
        source /etc/profile
        echo "sentinel加入环境变量已完成"
    else
        echo -e "\033[31mError: 安装程序已退出，sentinel_template.conf 下载失败,请检测网络连通!\033[0m"
        exit 0
    fi
}

edit_start_file(){
    #编辑开机启动文件,$1:port
    echo "开始导入开机启动文件############################"
    wget -P ./redis_tmp/ ${download_url}/soft/config/redis/sentinel/sentinel_template
    if [ -f ./redis_tmp/sentinel_template ];then
        dos2unix ./redis_tmp/sentinel_template
        sed -i "s/{Port}/${1}/g" ./redis_tmp/sentinel_template
        cp -rf ./redis_tmp/sentinel_template /etc/init.d/sentinel${1}
        rm -rf ./redis_tmp/
        chmod 755 /etc/init.d/sentinel${1}
        chkconfig --add sentinel${1}
        echo "sentinel已加入开机启动"
    else
        echo -e "\033[31mError: 安装程序已退出，redis_template 文件下载失败,请检测网络连通!\033[0m"
        exit 0
    fi
}

start(){
    echo -e "安装路径为: ${1}"
    echo -e "端口号为: ${2}"
    echo -e "\033[31m安装已全部完成,请执行下面的语句刷新环境变量\033[0m"
    echo "source /etc/profile"
}

usage="\033[31mUsage: $0 [26379|26380|26381|26382|26383]\033[0m"
if [ $# -gt 0 ]; then
    if [ ${1} != 26379 -a ${1} != 26380 -a ${1} != 26381 -a ${1} != 26382 -a ${1} != 26383 ];then
        echo -e ${usage}
        exit 0
    else
        sentialport=${1}
        base_dir=/app/local/sentinel${sentialport}
        redisport=`echo ${sentialport} | sed  's/^[0-9]//g'`

        path_test ${base_dir}
        port_test ${sentialport}
        develop_install
        get_soft
        Install ${base_dir}
        config ${base_dir} ${sentialport} ${redisport}
        edit_start_file ${sentialport}
        start ${base_dir} ${sentialport} ${redisport}
    fi
else
    echo -e ${usage}
    exit 0
fi
