#!/usr/bin/env python
# -*- coding: utf-8 -*-

import smtplib,os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.Header import Header
import sys,logging,time
from optparse import OptionParser
import xmlrpclib
import socket
import os
import subprocess


parser = OptionParser(add_help_option=1)
parser.add_option("-t","--mailto",action="store",type="string",dest="mailto",default="opt@qq.cn")
parser.add_option("-c","--context",action="store",type="string",dest="context",default="test context")
parser.add_option("-C","--contextfile",action="store",type="string",dest="contextfile",default="")
parser.add_option("-T","--title",action="store",type="string",dest="title",default="sub")
parser.add_option("-H","--host",action="store",type="string",dest="host",default="10.21.23.20:9082")
parser.add_option("-s","--status",action="store",type="string",dest="status",default="1")
#'status 1表示失败，0表示成功'

(options,args) = parser.parse_args()
mailto = options.mailto
context = options.context
contextfile = options.contextfile
host= options.host
title = options.title
status= int(options.status)
mail_host ="smtp.exmail.qq.com"
mail_user = "alert"
mail_postfix = 'qq.com'
mail_pass = "qazwsx"
mail_log='/tmp/sendmail.log'

if contextfile:
  cfile = open(contextfile,'r')
  context = cfile.read()
  cfile.close()

def get_hostname():
    '''get hostname'''
    try:
        import salt.config
        import salt.loader
        __opts__ = salt.config.minion_config('/etc/salt/minion')
        if "id" in __opts__:
            return __opts__['id']
        else:
            return subprocess.Popen("hostname", stdout=subprocess.PIPE).stdout.read()
    except Exception,e:
        return subprocess.Popen("hostname", stdout=subprocess.PIPE).stdout.read()



def update_status(status=1):
    'status 1表示失败，0表示成功'
    hostname=get_hostname()
    ip="127.0.0.1"
    try:
        server = xmlrpclib.ServerProxy("http://%s" % host)
        if server.update_status(hostname,ip,status):
            logging.basicConfig(filename=mail_log, level=logging.DEBUG)
            logging.info(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + "update host %s:%s backup status %s" %(hostname,ip,status))
            print "update host %s:%s backup status %s" %(hostname,ip,status)
            return True
        else:
            print "Err: update host %s backup status filed!" %hostname
            return False

    except Exception,e:
        logging.basicConfig(filename=mail_log, level=logging.DEBUG)
        logging.error(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + str(e))
        logging.error(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + "Err: update host %s backup status filed!" % hostname)
        print "Err: update host %s backup status filed!" % hostname
        return False

def sendMail(to_list,subject,content):
    try:
        server = xmlrpclib.ServerProxy("http://%s"% host)
        if server.send_mail(to_list,subject,content):
            logging.basicConfig(filename = mail_log, level = logging.DEBUG)
            logging.info(time.strftime('%Y-%m-%d %H:%I:%M',time.localtime(time.time()))+subject)
            print "Send mail to %s.." % mailto
            return True
        else:
            print "Err: Send mail filed!"
            return False

    except Exception,e:
        logging.basicConfig(filename = mail_log, level = logging.DEBUG)
        logging.error(time.strftime('%Y-%m-%d %H:%I:%M',time.localtime(time.time()))+str(e))
        print "Err: Send mail filed!"
        return False
if status is None or status != 0:
    sendMail(mailto,title,context)
update_status(status)

