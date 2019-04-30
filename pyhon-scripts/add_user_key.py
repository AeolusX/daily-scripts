#!/usr/bin/env python
# -*- coding: utf-8 -*-
#__author__ = 'discovery'

import os,time,shutil

sshkey_pub={
    "disvovery":"ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5FeeefffrPYDk1AmoBgOdmAC8Wl9sldzvpBRo0EjaCT9qKViPj4VD/f89ROwb699P4hV/AHntLnzBJglVkcZ/aoluq49oiTilb2gbLNyJS7Smba0ziOb16En+qRW/L6dH6Kr/9pK7g24q86wjvudvsP1abYycWZI+xfdvwEiyJY7sl8mLSJbjNVKXB7QGkmm7pEcCitQHKhDhk6SHmxHj7YmvmMPJtx7CpTeGl+yPDsR4LuUEfXR5twJwke89WzG00+KrmcU2ipTdnMvO8aSVYSMDXw/lmzMiZtjOveSa9yyWgYdMXxtDsEdhQwsF4Cy5p1n6weDe1wg2IE5nRp8PWsq6WQ== root@yunwei01",
   
}

user = ["discovery"]
time_now = time.strftime("%Y%m%d%H%M%S",time.localtime())

def add_user_key():
    '''
    创建ssh用户
    :return:
    '''
    print "开始配置sshd"
    for i_user in user:
        home_dir = "/home/%s" % i_user
        if os.path.exists(home_dir):
            print "%s用户已存在,无需创建用户" % i_user
            if os.path.exists("%s/.ssh" % home_dir):
                print "%s用户ssh目录已存在,无需创建" % i_user
            else:
                os.mkdir("%s/.ssh" % home_dir)
        else:
            os.system("useradd %s" % i_user)
            os.mkdir("%s/.ssh" % home_dir)
            print "%s用户创建已完成" % i_user
        authorized_keys_dir = "%s/.ssh/authorized_keys" % home_dir
        f = open(authorized_keys_dir,"wb")
        key = sshkey_pub[i_user]
        f.write(key)
        f.close()
        os.system("chmod 600 %s" % authorized_keys_dir)
        os.system("chown %s:%s %s" % (i_user,i_user,authorized_keys_dir))
        os.system("usermod -a -G wheel %s" % i_user)
        print "%s用户Key已添加完成!" % i_user

def up_sshkey():
    '''
    检查sshd_config配置文件
    :return:
    '''
    singo_pubkey = 0
    singo_author = 0
    singo_rsaa = 0
    Pubkey = "PubkeyAuthentication yes\n"
    Author = "AuthorizedKeysFile .ssh/authorized_keys\n"
    Rsaa = "RSAAuthentication yes\n"

    f_ssh_r = open("/etc/ssh/sshd_config")
    for i_key in f_ssh_r.readlines():
        if Pubkey == i_key:
            singo_pubkey = 1
        if Author == i_key:
            singo_author = 1
        if Rsaa == i_key:
            singo_rsaa = 1
    f_ssh_r.close()
    com_rsaa = "sed -i 's/^#RSAAuthentication.*/RSAAuthentication yes/g' /etc/ssh/sshd_config"
    com_pubkey = "sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config"
    com_author = "sed -i 's/^#AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys/g' /etc/ssh/sshd_config"
    if singo_author == 0:
        os.system(com_author)
        print "AuthorizedKeysFile已添加至配置文件!"
    else:
        print "AuthorizedKeysFile已存在,无需配置!"
    if singo_pubkey == 0:
        os.system(com_pubkey)
        print "PubkeyAuthentication已添加至配置文件!"
    else:
        print "PubkeyAuthentication已存在,无需配置!"
    if singo_rsaa == 0:
        os.system(com_rsaa)
        print "RSAAuthentication已添加至配置文件!"
    else:
        print "RSAAuthentication已存在,无需配置!"

def sudo_nopass():
    '''
    配置sudo无密码!
    :return:
    '''
    singo = 0
    sudoer = "%wheel    ALL=(ALL)       NOPASSWD: ALL"
    f_sudo = open("/etc/sudoers")
    for i_sudo in f_sudo.readlines():
        if sudoer == i_sudo:
            singo = 1
            f_sudo.close()
            print "sudoer配置文件无需配置!"
    if singo == 0:
        shutil.copy("/etc/sudoers","/etc/sudoers%s" % time_now)
        f_sudo_w = open("/etc/sudoers","ab+")
        f_sudo_w.write(sudoer)
        f_sudo_w.close()
        print "sudoer配置文件配置已完成!"

if __name__ == "__main__":
    add_user_key()
    up_sshkey()
    sudo_nopass()
    os.system("service sshd restart")