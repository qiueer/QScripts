# -*- encoding=utf-8 -*-
# qiueer@20170406
    
import sys
import os
import datetime
import traceback
import time
import win32api

reload(sys)
sys.setdefaultencoding('utf8')

def get_realpath():
    return os.path.split(os.path.realpath(__file__))[0]

def get_binname():
    return os.path.split(os.path.realpath(__file__))[1]

if __name__ == "__main__":
    NOW = datetime.datetime.now() - datetime.timedelta(minutes=2)
    dtstr = NOW.strftime('%Y%m%d')
    tmstr = NOW.strftime('%H%M')
    CWD = get_realpath()
    #dtstr = NOW.strftime('%Y%m%d%H%M%S')  

    try:
        COMMAND="%s\\kcbp.exe" % (CWD)
        DISK = CWD[0:2]
        LOGFILE = "%s\\applogs\\kcbp\\log\\run\\%s\\runlog0.log" % (DISK, dtstr)
        #LOGFILE = "%s\\KCBP\\bin\\log\\run\\%s\\runlog0.log" % (DISK, dtstr)
        start_flag  = False
        check_flag = False

        print "START COMMAND: %s" % (COMMAND)
        win32api.ShellExecute(0, 'open', COMMAND, "start", '', 0)           # 后台执行，不阻塞
        start_flag = True

        start_time = int(time.time())
        time_delta = 0
        keyword = "KCBP daemon start successfully"

        check_cnt = 0
        while time_delta < (60*1):
            check_cnt += 1
            print "[INFO] Check Count: %s" % (check_cnt)
            if not os.path.exists(LOGFILE):
                #print LOGFILE
                #print "Not Exist!"
                time.sleep(1)
                continue
            if check_flag == True:break
            fd = open(LOGFILE, "r")
            for line in fd:
                if not line or str(line).strip() == "":continue
                if str(line).find(keyword) != -1:
                    check_flag = True
                    break
            fd.close()
            time.sleep(1)
            time_delta = int(time.time()) - start_time
            
        print "Start: %s" % ("OK" if start_flag == True else "FAIL")
        print "Check: %s" % ("OK" if check_flag == True else "FAIL")
        
        if start_flag == True and check_flag == True:
            sys.exit(0)
        sys.exit(1)

    except Exception, expt:
        print traceback.format_exc()
        sys.exit(1)
