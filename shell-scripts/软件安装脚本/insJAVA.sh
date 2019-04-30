#!/bin/bash
jdkurl="http://repo-ops.soft.com/soft/java/jdk-8u161-linux-x64.tar.gz"
dirname=jdk1.8.0_161
filename=jdk-8u161-linux-x64.tar.gz

mkdir -p /app/local 

[ -d /app/local/${dirname} ] && echo "java exits in /app/local" && exit 1
[ ! -w p /app/local ] && echo "can't write /app/local" && exit 1
wget $jdkurl || exit 1 
tar -xf ${filename} -C /app/local && echo "extract jdk file success"

if ! grep "JAVA_HOME" /etc/profile >/dev/null ; then
cat >>/etc/profile<<EOF
JAVA_HOME=/app/local/${dirname}
JRE_HOME=\$JAVA_HOME/jre
PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin
CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib
export JAVA_HOME JRE_HOME PATH CLASSPATH 
EOF
source /etc/profile
else
    echo "java profile setting is exiting in java"
    exit  1 ;
fi
echo "install java success"
