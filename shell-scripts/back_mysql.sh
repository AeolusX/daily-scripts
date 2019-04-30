#!/bin/bash

function backup(){
BACKDIR=/opt/backup/
SOC=$1
DATABASENAME=$2

mkdir -p  "$BACKDIR"tmp
/usr/bin/mysqldump -uroot -S "$SOC" "$DATABASENAME" >"$BACKDIR"tmp/"$DATABASENAME".sql
mkdir -p "$BACKDIR"`date '+%Y%m%d'`
tar czvf "$BACKDIR"`date '+%Y%m%d'`/"$DATABASENAME"`date '+%Y%m%d'`.tgz "$BACKDIR"tmp/*
rm -rf "$BACKDIR"tmp/*
}

backup /usr/local/var/mysql2/mysql2.sock web
backup /usr/local/var/mysql2/mysql2.sock passport
backup /usr/local/var/mysql2/mysql2.sock game_info
backup /usr/local/var/mysql2/mysql2.sock payment
backup /usr/local/var/mysql2/mysql2.sock ucenter
