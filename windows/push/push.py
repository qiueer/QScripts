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
    -- by QiuJingQin @ 20170824
"""

def main():
    help()
    rp = get_realpath()
    av_disk = get_available_disk()
    try:
        hostname = socket.gethostname()
        usernames = ["system-admin", "%s\system-admin"%(hostname)]
        sharenames = ["d$", "e$"]
        destdir = "%s:\qiujingqin" % (av_disk)
        while True:
        
            (iphost, password, files) = (None, None, None)
            while not iphost:
                iphost = raw_input(u"IP或主机名: ")
                
            while not password:
                password = raw_input(u"密码: ")
                
            while not files:
                files = raw_input(u"文件或目录(默认是当前目录下的tools文件夹): ")
                if not files or str(files).strip() == "":
                    files = "tools"

            iphosts= re.split("[,|;]", iphost)
            now = datetime.datetime.now()
            nowstr = now.strftime('%Y%m%d-%H%M%S')
            
            print "\r"
            print "".join(["#"]*60)
            print "[INFO]"
            print " IPHOSTS:   %s" % (iphosts)
            print " PASSWORD:  %s" % (password)
            print " FILES:     %s" % (files)
            print " USERNAME:  %s" % (usernames)
            print " SHARENAME: %s" % (sharenames)
            print "".join(["#"]*60)

            for iphost in iphosts:
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
    
    