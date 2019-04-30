#!/usr/bin/env bash
cat << EOF


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REQUIRED:     centOS-6 (Defulte 64bit)
DESCRIPTION:  Install VSFTP or create vsftp user in CentOS
AUTHOR:       
REVISION:     1.0
++++++++++++++++++++++++++++++++++++++++++++++++++++++++


EOF

vsftp_dir="/etc/vsftpd/"

install_soft(){
	#安装vsftpd软件
	echo "开始安装vsftp软件"
	yum -y install vsftpd db4 db4-utils
}
uninstall_soft(){
	#卸载vsftpd软件
	echo "开始卸载vsftpd软件"
	yum -y remove vsftpd
	echo "vsftpd卸载完成"
}

edit_config(){
	#创建vsftp.conf配置文件
	cp -rf ${vsftp_dir}vsftpd.conf  ${vsftp_dir}vsftpd.conf.bak 
	rm -rf ${vsftp_dir}vsftpd.conf 
	echo anonymous_enable=NO >${vsftp_dir}vsftpd.conf
	echo local_enable=YES >>${vsftp_dir}vsftpd.conf
	echo write_enable=YES >>${vsftp_dir}vsftpd.conf
	echo local_umask=022 >>${vsftp_dir}vsftpd.conf
	echo anon_upload_enable=NO >>${vsftp_dir}vsftpd.conf
	echo anon_mkdir_write_enable=NO >>${vsftp_dir}vsftpd.conf
	echo dirmessage_enable=YES >>${vsftp_dir}vsftpd.conf
	echo xferlog_enable=YES >>${vsftp_dir}vsftpd.conf
	echo connect_from_port_20=YES >>${vsftp_dir}vsftpd.conf
	echo chown_uploads=NO >>${vsftp_dir}vsftpd.conf
	echo xferlog_file=/var/log/xferlog >>${vsftp_dir}vsftpd.conf
	echo xferlog_std_format=YES >>${vsftp_dir}vsftpd.conf
	echo nopriv_user=www >>${vsftp_dir}vsftpd.conf
	echo async_abor_enable=YES >>${vsftp_dir}vsftpd.conf
	echo ascii_upload_enable=YES >>${vsftp_dir}vsftpd.conf
	echo ascii_download_enable=YES >>${vsftp_dir}vsftpd.conf
	echo ftpd_banner=Welcome to blah FTP service. >>${vsftp_dir}vsftpd.conf
	echo chroot_local_user=NO >>${vsftp_dir}vsftpd.conf
	echo chroot_list_enable=YES >>${vsftp_dir}vsftpd.conf
	echo chroot_list_file=${vsftp_dir}vsftpd.chroot_list >>${vsftp_dir}vsftpd.conf
	echo listen=YES >>${vsftp_dir}vsftpd.conf
	echo pam_service_name=vsftpd >>${vsftp_dir}vsftpd.conf
	echo userlist_enable=YES >>${vsftp_dir}vsftpd.conf
	echo tcp_wrappers=YES >>${vsftp_dir}vsftpd.conf
	echo background=YES >>${vsftp_dir}vsftpd.conf
	echo guest_enable=YES >>${vsftp_dir}vsftpd.conf
	echo guest_username=www >>${vsftp_dir}vsftpd.conf
	echo user_config_dir=${vsftp_dir}vuser_conf >>${vsftp_dir}vsftpd.conf
	echo max_clients=100 >>${vsftp_dir}vsftpd.conf
	echo max_per_ip=20 >>${vsftp_dir}vsftpd.conf
	echo 该文件是判断能否添加用户的问题，请勿删除！>${vsftp_dir}tag_vsftpd
}

create_ftp(){
	#判断ftp系统用户是否存在
	num1=`id ftp| wc -l`
	if [ $num1 -lt 1 ]; then
	    /usr/sbin/groupadd ftp
		/usr/sbin/useradd ftp -g ftp -s /sbin/nologin
	fi
	echo ftp >${vsftp_dir}vsftpd.chroot_list
}
judge(){
	#判断该工具是否适合给ftp创建版本
	if [ -f ${vsftp_dir}tag_vsftpd ]; then
		echo "该版本适合创建ftp账号"
	else
		echo "ftp不是该工具创建，无法创建用户。"
		exit
	fi
}

create_user(){
	#创建虚拟ftp用户
	echo "开始创建FTP虚拟账号。"
	read -p "请输入ftp用户名：" ftp_user
	read -p "请输入ftp密码：" ftp_password
	echo $ftp_user >> ${vsftp_dir}vuser_passwd.txt
	echo $ftp_password >> ${vsftp_dir}vuser_passwd.txt
	db_load -T -t hash -f ${vsftp_dir}vuser_passwd.txt ${vsftp_dir}vuser_passwd.db
	echo "${ftp_user} 账号已创建成功"
}

create_vir_dir(){
	#为ftp虚拟用户创建存储目录
	for i in 3; do
		echo "开始创建用户ftp目录"
		read -p "请输入用户ftp目录的绝对路径，如果目录不存在，将自动创建：" vir_user_dir
		if [ -d ${vir_user_dir} ]; then
			echo "${vir_dir} 目录已存在，无需创建。"
			#chown -R www.www $vir_user_dir
		else
			mkdir -p ${vir_user_dir}
			if [ $? -eq 0 ]; then
				echo "${vir_user_dir}目录创建成功。" 
				chown -R www.www ${vir_user_dir}
				break
			else
				echo "目录格式输入错误，请重新输入。"
			fi
		fi
	done
}

create_vir_config(){
	#创建虚拟ftp用户配置文件
	create_user
	create_vir_dir
	echo "开始创建虚拟用户配置文件"
	if [ -d ${vsftp_dir}vuser_conf ]; then
		echo "${vsftp_dir}vuser_conf 目录已存在，无需创建。"
	else
		mkdir -p ${vsftp_dir}vuser_conf
		echo "${vsftp_dir}vuser_conf 目录以创建成功"
	fi
	echo local_root=$vir_user_dir >${vsftp_dir}vuser_conf/$ftp_user
	echo write_enable=YES >>${vsftp_dir}vuser_conf/$ftp_user
	echo anon_umask=022 >>${vsftp_dir}vuser_conf/$ftp_user
	echo anon_world_readable_only=NO >>${vsftp_dir}vuser_conf/$ftp_user
	echo anon_upload_enable=YES >>${vsftp_dir}vuser_conf/$ftp_user
	echo anon_mkdir_write_enable=YES >>${vsftp_dir}vuser_conf/$ftp_user
	echo anon_other_write_enable=YES >>${vsftp_dir}vuser_conf/$ftp_user
	echo "虚拟用户文件已创建完成。"
}

create_pam(){
	#创建密码审核pam文件
	echo "开始创建pam文件"
	cp -rf /etc/pam.d/vsftpd /etc/pam.d/vsftpd.bak
	rm -rf /etc/pam.d/vsftpd
	echo auth required pam_userdb.so db=${vsftp_dir}vuser_passwd >>/etc/pam.d/vsftpd
	echo account required pam_userdb.so db=${vsftp_dir}vuser_passwd >>/etc/pam.d/vsftpd
	echo "pam文件已创建完成"
}

start(){
	service vsftpd start
	chkconfig vsftpd on
	echo "vsftpd软件部署已全部完成。"
}

check_soft(){
	#判断系统是否已安装vsfpt软件
	num=`rpm -qa | grep vsftpd| wc -l`
	if [ $num -gt 0 ]; then
		read -p "Vsftp已存在。是否重新安装，请输入yes卸载并重新或者no取消： " ask
		while [[ $ask = "yes" && $ask = "no" ]]; do
			if [ $ask = no ]; then
				echo '安装程序已退出'
				exit
			fi
			read -p "请输入yes或者no继续安装或者取消：" ask
		done
		uninstall_soft
		install_soft
		edit_config
		create_ftp
		judge
		create_vir_config
		create_pam
		start
	else
		install_soft
		edit_config
		create_ftp
		judge
		create_vir_config
		create_pam
		start
	fi
}
######################################################################
read -p "请输入install或者create_fuser: " aNum
case $aNum in
	install) echo "准备安装vsfptd"
	check_soft
	;;
	create_fuser) echo "准备创建fpt虚拟用户"
	judge
	create_vir_config
	;;
	*) echo "输入错误，安装程序已退出"
	;;
esac




