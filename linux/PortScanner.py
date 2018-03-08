#!/usr/bin/env python
# -*- encoding=utf-8 -*-
'''
多线程扫描端口
'''

import socket
import optparse
import re
import threading
import sys

def anlyze_host(target_host):
    try:
        pattern = re.compile(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}') #匹配标准点进制的IP
        match = pattern.match(target_host)
        if match:
            return match.group()
        else:
            try:
                target_host = socket.gethostbyname(target_host) #如果不是，就把target_host的值作为域名进行解析
                return target_host
            except Exception, err:
                return None
    except Exception as err:
        return None
                    
def anlyze_port(target_port):
    try:
        pattern = re.compile(r'(\d+)-(\d+)')
        match = pattern.match(target_port)
        if match:
            start_port = int(match.group(1))
            end_port = int(match.group(2))
            return([x for x in range(start_port,end_port + 1)])
        else:
            return([int(x) for x in re.split("[,|;|\s]+", target_port)])
    except Exception, err:
        return None

def scanner(target_host,target_port):
    s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    s.settimeout(5)
    try:
        s.connect((target_host,target_port))
	output = u"%s %5s %s" % (target_host, target_port, "OPEN")
    except Exception, err:
	output = u"%s %5s %s" % (target_host, target_port, "CLOSE")
    sys.stdout.write(output+"\n")
    sys.stdout.flush()

def main():
    usage = 'Usage:%prog [-i|--iphost] <host> [-p|--port] <port>'
    parser = optparse.OptionParser(usage,version='%prog v1.0')
    parser.add_option("-i", "--iphost",  
                      action="store", dest="iphost", default=None,type='string',
                      help="ip or hostname", metavar="IP OR HOSTNAME")
    parser.add_option("-p", "--port",  
                      action="store", dest="port", default=None,type='string',
                      help="port", metavar="PORT")
                          
    (options,args) = parser.parse_args()

    target_host = options.iphost
    target_port = options.port
    if None in [target_host, target_port]:
        print(parser.usage)
        sys.exit(1)

    target_host = anlyze_host(target_host)
    target_port = anlyze_port(target_port)

    for port in target_port:
        t = threading.Thread(target=scanner,args=(target_host,port))#多线程扫描端口
        t.start()

if __name__ == '__main__':
    main()  