#!/usr/bin/env python
# -*- coding: utf-8 -*-

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.Header import Header
import logging,time
from optparse import OptionParser
from SimpleXMLRPCServer import SimpleXMLRPCServer
from SocketServer import ThreadingMixIn


parser = OptionParser(add_help_option=1)
parser.add_option("-p","--port",action="store",type="int",dest="port",default=9081)
(options,args) = parser.parse_args()
port=int(options.port)

class ThreadXMLRPCServer(ThreadingMixIn, SimpleXMLRPCServer):pass

class newMail():

    def __int__(self):
        pass
    def send_mail(self,to_list, subject, content):
        self.mail_host = "smtp.exmail.qq.com"
        self.mail_user = "alertmail"
        self.mail_postfix = 'qq.cn'
        self.mail_pass = "qazwsx"
        self.mail_log = '/tmp/sendmail.log'
        me = self.mail_user + "<" + self.mail_user + "@" + self.mail_postfix + ">"
        # content = Header(content,'utf-8')
        # msg = MIMEText(content,'base64','utf-8')
        msg = MIMEMultipart('alternative')
        msg['Subject'] = Header(subject, 'utf-8')
        msg['From'] = me
        msg['to'] = to_list
        to_list = to_list.split(",")
        part = MIMEText(content, 'plain', 'utf-8')
        msg.attach(part)
        try:
            s = smtplib.SMTP()
            s.connect(self.mail_host)
            s.login(self.mail_user + '@' + self.mail_postfix, self.mail_pass)
            s.sendmail(me, to_list, msg.as_string())
            s.close()
            #logging.basicConfig(filename = self.mail_log, level = logging.DEBUG)
            # logging.info(time.strftime('%Y-%m-%d %H:%I:%M',time.localtime(time.time()))+subject)
            return True
        except Exception, e:
            logging.basicConfig(filename=self.mail_log, level=logging.DEBUG)
            logging.error(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + str(e))
            return False

mail_obj=newMail()
try:
    server = ThreadXMLRPCServer(("0.0.0.0", port), allow_none=True)
    server.register_instance(mail_obj)
    print "Listening on port %s" % port
    server.serve_forever()
except Exception, e:
    logging.basicConfig(filename='/tmp/sendmail.log',level=logging.DEBUG)
    logging.error(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + str(e))
