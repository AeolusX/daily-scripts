#!/bin/bash


users=('ansible')

for user in ${users[@]}
do
   num=`id ${user}| wc -l`
   if [ $num -lt 1 ] ; then
      /usr/sbin/useradd ${user} -G wheel
       mkdir /home/${user}/.ssh -p
      cd /home/${user}/.ssh && wget http://repo-ops.soft.com/soft/pubkey/${user}.pem.pub && cat ${user}.pem.pub >>authorized_keys && rm -rf *.pem.pub
      chmod 600 /home/${user}/.ssh/authorized_keys
      chmod 700 /home/${user}/.ssh/
      chown ${user}:${user} /home/${user}/.ssh -R
        echo "$user用户已创建完成"
else
   echo "用户$user 已经存在，无需创建"
fi

done



#添加wheel 到suders 中
if ! grep '%wheel  ALL=(ALL) NOPASSWD: ALL' /etc/sudoers >/dev/null; then
  echo "%wheel  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi
