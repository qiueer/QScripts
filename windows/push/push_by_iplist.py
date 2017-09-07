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
import socket

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

def help():
    print u"""
    本工具实现将文件推送远程服务器，仅适合在windows环境下使用。
    iplist.conf文件内容要求：
        ip password
        ip password
        ......
    -- by QiuJingQin @ 20170824
"""

def main():
    help()
    rp = get_realpath()
    av_disk = get_available_disk()
    try:
        hostname = socket.gethostname()
        usernames = ["%s\system-admin"%(hostname),"system-admin"]
        sharenames = ["d$", "e$"]
        destdir = "%s:\qiujingqin" % (av_disk)
        while True:
            (iplist,files) = (None, None)
            while not iplist:
                iplist = raw_input(u"iplist文件(默认当前目录iplist.conf): ")
                if not iplist or str(iplist).strip():
                    iplist = "iplist.conf"

            while not files:
                files = raw_input(u"文件或目录(默认是当前目录下的tools文件夹): ")
                if not files or str(files).strip():
                    files = "tools"
                    
            if not os.path.exists(iplist):
                print "iplist文件不存在: %s" % (iplist)
                sys.exit(1)
            if not os.path.exists(files):
                print "files文件不存在: %s" % (files)
                sys.exit(1)
            
            fd = open(iplist, "r")
            now = datetime.datetime.now()
            nowstr = now.strftime('%Y%m%d-%H%M%S')
            for line in fd:
                if not line or str(line).strip().startswith("#") or str(line).strip() == "":continue
                iphost_password= re.split("[,|;|\s]+", line)
                if not iphost_password or len(iphost_password) < 2:continue
                iphost = iphost_password[0]
                password = iphost_password[1]

                print "\r"
                print "".join(["#"]*60)
                print "[INFO]"
                print " IPHOST:   %s" % (iphost)
                print " PASSWORD:  %s" % (password)
                print " FILES:     %s" % (files)
                print " USERNAME:  %s" % (usernames)
                print " SHARENAME: %s" % (sharenames)
                print "".join(["#"]*60)

                cmds = ["net use %s: /delete /y" %(av_disk)]
                for username in usernames:
                    for sharename in sharenames:
                        cmds.append("net use %s: \\\\%s\%s %s /user:%s" % (av_disk, iphost, sharename, password, username))

                cmds.append("md %s" % (destdir,))
                cmds.append("xcopy /s /i /y  %s %s" % (files, destdir))
                
                for cmdstr in cmds:
                    print "-->> %s" % (cmdstr)
                    os.system(cmdstr)
            print u"---------------------------- 华丽的分割线 -----------------------\r"

    except Exception as expt:
        print traceback.format_exc()
        
if __name__ == "__main__":
    main()
    
    