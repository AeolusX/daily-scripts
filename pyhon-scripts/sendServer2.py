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
import MySQLdb
import datetime

parser = OptionParser(add_help_option=1)
parser.add_option("-p","--port",action="store",type="int",dest="port",default=9082)
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
        self.mail_pass = "qazwx"
        self.mail_log = '/var/log/sendmail.log'
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
            logging.basicConfig(filename = self.mail_log, level = logging.DEBUG)
            logging.info(time.strftime('%Y-%m-%d %H:%I:%M',time.localtime(time.time()))+subject+"success")
            return True
        except Exception, e:
            logging.basicConfig(filename=self.mail_log, level=logging.DEBUG)
            logging.error(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + str(e))
            return False
    def update_status(self,hostname='localhost',ip='127.0.0.1',status=0):
        self.my_host="127.0.0.1"
        self.my_user="opcron"
        self.passwd="q1w2e3r4"
        self.db="bck_status"
        if hostname:
            self.hostname=hostname
        else:
            self.hostname="localhost"
        if ip:
            self.ip=ip
        else:
            self.ip="127.0.0.1"
        self.status=status
        self.back_time= datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        try:
            "更新数据库，如果没有主机记录则添加"
            conn = MySQLdb.connect(host=self.my_host, user=self.my_user, passwd=self.passwd, db=self.db)
            cur = conn.cursor()
            sql = 'insert into bck_status (hostname,ip,status,backup_time) values("%s","%s",%s,"%s")' % (self.hostname, self.ip, self.status, self.back_time)
            cur.execute(sql)
            conn.commit()
            sql = 'select hostname,ip from bck_hosts where hostname="%s" and ip="%s"' % (self.hostname, self.ip)
            cur.execute(sql)
            if not cur.fetchone():
                sql = 'insert into bck_hosts(hostname,ip) values("%s","%s")' % (self.hostname, self.ip)
                cur.execute(sql)
                conn.commit()
            if conn:
                conn.close()
            return True
        except Exception, e:
            if conn:
                conn.close()
            logging.basicConfig(filename='/var/log/sendmail.log', level=logging.DEBUG)
            logging.error(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + sql)
            logging.error(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + str(e))
            return False


mail_obj=newMail()
try:
    server = ThreadXMLRPCServer(("0.0.0.0", port), allow_none=True)
    server.register_instance(mail_obj)
    print "Listening on port %s" % port
    server.serve_forever()
except Exception, e:
    logging.basicConfig(filename='/var/log/sendmail.log',level=logging.DEBUG)
    logging.error(time.strftime('%Y-%m-%d %H:%I:%M', time.localtime(time.time())) + str(e))
