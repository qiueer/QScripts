title update_kbssclient_files
echo off
set CWD=%~dp0
set srcdir=%CWD%\current_version\KBSSClient
set destdir=D:\KBSSClient
xcopy /s /i /y "%srcdir%" "%destdir%"

pause