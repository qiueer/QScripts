# -*- encoding=utf-8 -*-
# qiujingqin
#
import os 
import sys
import re
import time 
import datetime
import traceback
import tarfile
from optparse import OptionParser

reload(sys) 
sys.setdefaultencoding('GBK')

def get_realpath():
    return os.path.split(os.path.realpath(__file__))[0]

def get_binname():
    return os.path.split(os.path.realpath(__file__))[1]

def get_available_disk():
    DISKS = ["F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    for d in DISKS:
        fpath ="%s:" % (d)
        if not os.path.exists(fpath):
            return d
    return None


def main():
    rp = get_realpath()
    av_disk = get_available_disk()
    try:

        parser = OptionParser()
        parser.add_option("-i", "--iphost",  
                  action="store", dest="iphost", default=None,  
                  help="iphost", metavar="IPHOST")
        parser.add_option("-u", "--username",  
                  action="store", dest="username", default="system-admin",  
                  help="username, such as system-admin", metavar="USERNAME")
        parser.add_option("-f", "--file",  
                  action="store", dest="file", default="tools",  
                  help="file", metavar="SHARENAME")
        parser.add_option("-p", "--password",  
                  action="store", dest="password", default=None,  
                  help="password", metavar="PASSWORD")
        parser.add_option("-s", "--sharename",  
                  action="store", dest="sharename", default="d$",  
                  help="share name", metavar="SHARENAME")

        (options, args) = parser.parse_args()
        iphost_src = options.iphost
        password = options.password
        files = options.file
        username = options.username
        sharename = options.sharename

        
        while not iphost:
            iphost = raw_input(u"IP或主机名: ")
            
        while not password:
            password = raw_input(u"密码: ")
            
        while not files:
            files = raw_input(u"文件或目录: ")
            
        while not username:
            username = raw_input(u"用户名: ")
            
        while not sharename:
            sharename = raw_input(u"共享名: ")
            
        iphosts= re.split("[,|;]", iphost_src)
        now = datetime.datetime.now()
        nowstr = now.strftime('%Y%m%d-%H%M%S')
        
		print "\r###################################"
        print "[INFO]"
        print " IPHOSTS:   %s" % (iphosts)
        print " PASSWORD:  %s" % (password)
        print " FILES:     %s" % (files)
        print " USERNAME:  %s" % (username)
        print " SHARENAME: %s" % (sharename)
		print "###################################"
        
        destdir = "%s:\qiujingqin" % (av_disk)
		
		for iphost in iphosts:
			cmds = [
				"net use %s: /delete /y" %(av_disk),
				"net use %s: \\\\%s\%s %s /user:%s" % (av_disk, iphost, sharename, password, username),
				## 如果异构环境不多，可将下面3条语句删掉
				"net use %s: \\\\%s\%s %s /user:%s" % (av_disk, iphost, sharename, password, ".\system-admin"), ## win 2008以上
				"net use %s: \\\\%s\%s %s /user:%s" % (av_disk, iphost, "e$", password, username), ## UAT环境
				"net use %s: \\\\%s\%s %s /user:%s" % (av_disk, iphost, "e$", password, ".\system-admin"), ## win 2003 环境
				"md %s" % (destdir,),
				"xcopy /s /i /y  %s %s" % (files, destdir),
			]
			
			for cmdstr in cmds:
				print cmdstr
				os.system(cmdstr)

    except Exception as expt:
        print traceback.format_exc()
        
if __name__ == "__main__":
    main()
    
    