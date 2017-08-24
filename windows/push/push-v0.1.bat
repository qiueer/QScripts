@ echo off
@ title backup kcxp queue and clear


set RP=%~dp0
set PATH=%PATH%;%RP%

@ rem 日期与时间
set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
set minute=%time:~3,2%
set second=%time:~6,2%
set ms=%time:~9,2%

@ rem if %hour:~1,1% LSS 10 set hour=0%hour:~1,1%
if "%hour:~0,1%"==" " set "hour=0%hour:~1,1%"

set today=%year%%month%%day%
set now_time=%hour%%minute%%second%
set now_dt=%today%%now_time%
set now_dt_ms=%today%%now_time%%ms%

set now_dt_str=%today%_%now_time%%ms%


set USER=.\system-admin
set SHARENAME=d
set DISK=T

:loop
echo 用户名默认使用: %USER%
set /p IP=IP:
set /p PASSWD=密码:

net use %DISK%: /delete /y
net use %DISK%: \\%IP%\%SHARENAME% %PASSWD% /user:%USER%

set tool_dir=%DISK%\qiujingqin\
if not exist %tool_dir% md %tool_dir%

set src_dir=%RP%/tools
if exist %tool_dir% xcopy /s /i /y  %src_dir% %tool_dir%


goto loop

pause