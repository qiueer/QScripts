@ echo off
@ title datetime

set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
set minute=%time:~3,2%
set second=%time:~6,2%
set ms=%time:~9,2%

echo %hour%
@ rem if %hour:~1,1% LSS 10 set hour=0%hour:~1,1%
if %hour:~0,1%==" " set hour=0%hour:~1,1%

set today=%year%%month%%day%
set now_time=%hour%%minute%%second%
set now_dt=%today%%now_time%
set now_dt_ms=%today%%now_time%%ms%

echo %today%
echo %hour%
echo %minute%
echo %second%
echo %now_time%
echo %now_dt%
echo %now_dt_ms%

pause