#!/usr/bin/env python
# -*- coding: utf-8 -*-

import smtplib,os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.Header import Header
import sys,logging,time
from optparse import OptionParser
import xmlrpclib

parser = OptionParser(add_help_option=1)
parser.add_option("-t","--mailto",action="store",type="string",dest="mailto",default="opt@qq.cn")
parser.add_option("-c","--context",action="store",type="string",dest="context",default="test context")
parser.add_option("-C","--contextfile",action="store",type="string",dest="contextfile",default="")
parser.add_option("-T","--title",action="store",type="string",dest="title",default="sub")
parser.add_option("-H","--host",action="store",type="string",dest="host",default="10.10.16.20:9081")
(options,args) = parser.parse_args()
mailto = options.mailto
context = options.context
contextfile = options.contextfile
host= options.host
title = options.title
mail_host ="smtp.exmail.qq.com"
mail_user = "alertmail"
mail_postfix = 'qq.com'
mail_pass = "eeeeee"
mail_log='/tmp/sendmail.log'

if contextfile:
  cfile = open(contextfile,'r')
  context = cfile.read()
  cfile.close()

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
sendMail(mailto,title,context)