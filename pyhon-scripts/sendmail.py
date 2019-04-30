#!/usr/bin/env python
# -*- coding: utf-8 -*-

import smtplib,os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.Header import Header
import sys,logging,time
from optparse import OptionParser

parser = OptionParser(add_help_option=1)
parser.add_option("-t","--mailto",action="store",type="string",dest="mailto",default="opt@qq.cn")
parser.add_option("-c","--context",action="store",type="string",dest="context",default="test context")
parser.add_option("-C","--contextfile",action="store",type="string",dest="contextfile",default="")
parser.add_option("-T","--title",action="store",type="string",dest="title",default="sub")
(options,args) = parser.parse_args()
mailto = options.mailto
context = options.context
contextfile = options.contextfile
title = options.title
mail_host ="smtp.exmail.qq.com"
mail_user = "alertmail"
mail_postfix = 'qq.com'
mail_pass = "qazwsx"
mail_log='/tmp/sendmail.log'

if contextfile:
  cfile = open(contextfile,'r')
  context = cfile.read()
  cfile.close()

def send_mail(to_list,subject,content):
    me = mail_user+"<"+mail_user+"@"+mail_postfix+">"
    #content = Header(content,'utf-8')
    #msg = MIMEText(content,'base64','utf-8')
    msg = MIMEMultipart('alternative')
    msg['Subject'] = Header(subject,'utf-8')
    msg['From'] = me
    msg['to'] = to_list
    to_list = to_list.split(",")
    part = MIMEText(content,'plain','utf-8')
    msg.attach(part)
    try:
        s = smtplib.SMTP()
        s.connect(mail_host)
        s.login(mail_user+'@'+mail_postfix,mail_pass)
        s.sendmail(me,to_list,msg.as_string())
        s.close()
        #logging.basicConfig(filename = mail_log, level = logging.DEBUG)
        #logging.info(time.strftime('%Y-%m-%d %H:%I:%M',time.localtime(time.time()))+subject)
        return True
    except Exception,e:
        logging.basicConfig(filename = mail_log, level = logging.DEBUG)
        logging.error(time.strftime('%Y-%m-%d %H:%I:%M',time.localtime(time.time()))+str(e))
        return False

if (True == send_mail(mailto,title,context)):
    print "Send mail to %s.." %mailto
else:
    print "Err: Send mail filed!"


