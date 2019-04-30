#!/bin/bash

# 备份存储路径，注意最后不带/
BACKUPROOT=/app/script/backup


function backup(){
        #PORT=3306
        #MYSQLUSER=root
        #MYSQLPWD=123456
        DBNAME=$1
        MYSQL_SK=$2
        BACKUPDIR=${BACKUPROOT}/`date '+%Y%m%d'`
        TAG=$DBNAME
        #在备份路径生成tmp目录
        mkdir -p  ${BACKUPDIR}/tmp
        NUM=`mysql -S"${MYSQL_SK}" -s -vv -e "show tables" -D "${DBNAME}"|wc -l`
        HEADNUM=`expr ${NUM} - 3`
        TAILNUM=`expr ${NUM} - 7`
        ARR1=`mysql -S"${MYSQL_SK}" -s -vv -e "show tables" -D "${DBNAME}"| head -n"${HEADNUM}" | tail -n "${TAILNUM}"`
        ARR2=(${ARR1})
        i=0
        while [ "${i}" -lt "${#ARR2[@]}" ]
        do
                tmpFileName=${ARR2[$i]}

                mysqldump -S${MYSQL_SK} --lock-tables=false --default-character-set=utf8 ${DBNAME} ${tmpFileName} > ${BACKUPDIR}/tmp/${tmpFileName}
                let "i++"
        done
        cd ${BACKUPDIR}/tmp
        #打包数据库
        tar czf ${BACKUPDIR}/${TAG}`date '+%Y%m%d'`.tgz *
        #删除临时TMP目录
        cd ${BACKUPDIR}
        rm -rf tmp/

}


backup finance /usr/local/var/mysql1/mysql1.sock
#backup uc /usr/local/var/mysql1/mysql1.sock

cd ${BACKUPROOT}
find ${BACKUPROOT}/ -type d -mtime +2 -exec rm -rf {} \;

# rsync -avu --progress /opt/backup 10.10.16.53:/home/mysqlbackup/db1


