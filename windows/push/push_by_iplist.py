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

def help():
    print u"""
    本工具实现将文件推送远程服务器，仅适合在windows环境下使用。
    1）默认配置
        iplist文件，默认使用当前目录下的iplist.conf文件
        推送文件，默认使用当前目录下的tools文件夹
    2）iplist.conf文件格式要求
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
        
        usernames = ["system-admin", ".\system-admin"]
        sharenames = ["d$", "e$"]
        destdir = "%s:\qiujingqin" % (av_disk)
        while True:
            (iplist,files) = (None, None)
            while not iplist:
                iplist = raw_input(u"iplist文件: ")
                if not iplist or str(iplist).strip() == "":
                    iplist = "iplist.conf"

            while not files:
                files = raw_input(u"文件或目录: ")
                if not files or str(files).strip() == "":
                    files = "tools"
                    
            if not os.path.exists(iplist):
                print u"iplist文件不存在: %s" % (iplist)
                continue
            if not os.path.exists(files):
                print u"files文件不存在: %s" % (files)
                continue
            
            fd = open(iplist, "r")
            alllines = fd.readlines()
            fd.close()
            now = datetime.datetime.now()
            nowstr = now.strftime('%Y%m%d-%H%M%S')
            
            print "".join(["#"]*60)
            print " IPLIST:    %s" % (iplist)
            print " FILES:     %s" % (files)
            print " USERNAME:  %s" % (usernames)
            print " SHARENAME: %s" % (sharenames)
            print "".join(["#"]*60)
            confirm = raw_input(u"配置如上，是否确认(YES/Y/NO/N)?: ")
            confirm = str(confirm).strip().upper()
            while confirm not in ["YES","Y","NO","N"]:
                confirm = raw_input(u"配置如上，是否确认(YES/Y/NO/N)?: ")
                confirm = str(confirm).strip().upper()
            if confirm in ["NO","N"]:
                continue
                
            for line in alllines:
                if not line or str(line).strip().startswith("#") or str(line).strip() == "":continue
                iphost_password= re.split("[,|;|\s]+", line)
                if not iphost_password or len(iphost_password) < 2:continue
                iphost = iphost_password[0]
                password = iphost_password[1]

                print "\n\r\n\r---------------------------- [%s] BEGIN -----------------------" % (iphost)
                print "".join(["*"]*30)
                print "[INFO]"
                print " IPHOST:    %s" % (iphost)
                print " PASSWORD:  %s" % (password)
                print "".join(["*"]*30)

                cmds = ["net use %s: /delete /y" %(av_disk)]
                for username in usernames:
                    for sharename in sharenames:
                        cmds.append("net use %s: \\\\%s\%s %s /user:%s" % (av_disk, iphost, sharename, password, username))

                cmds.append("md %s" % (destdir,))
                cmds.append("xcopy /s /i /y  %s %s" % (files, destdir))
                
                for cmdstr in cmds:
                    print "-->> %s" % (cmdstr)
                    os.system(cmdstr)
            print u"---------------------------- 华丽的分割线 [%s] END -----------------------\n\r" % (iphost)

    except Exception as expt:
        print traceback.format_exc()
        
if __name__ == "__main__":
    main()
    
    