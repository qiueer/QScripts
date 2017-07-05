@ title kill kbssclient
@ echo off

@ rem 执行慢
@ rem taskkill /F /FI "IMAGENAME eq KBSSClient.exe*"
@ rem taskkill /F /FI "IMAGENAME eq KBSSDocVideoControl.exe*"
@ rem taskkill /F /FI "IMAGENAME eq KBSS_ImgControl.exe*"
@ rem taskkill /F /FI "IMAGENAME eq KBSS_TWainSCan.exe*"

taskkill /F /IM KBSSClient.exe
taskkill /F /IM KBSSDocVideoControl.exe
taskkill /F /IM KBSS_ImgControl.exe
taskkill /F /IM KBSS_TWainSCan.exe

pause