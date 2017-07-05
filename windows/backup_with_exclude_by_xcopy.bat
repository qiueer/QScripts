@ echo off
@ title backup kbssclient

set CWD=%~dp0
set PATH=%PATH%;c:\python279
set PROJECT_PATH=D:\KBSSClient
set BACKUP_ROOT=D:\backup\KBSSClient

set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%
set hour=%time:~0,2%
set minute=%time:~3,2%
set second=%time:~6,2%
set ms=%time:~9,2%

@ rem if %hour:~1,1% LSS 10 set hour=0%hour:~1,1%
if %hour:~0,1%==" " set hour=0%hour:~1,1%

set today=%year%%month%%day%
set now_time=%hour%%minute%%second%
set now_dt=%today%%now_time%
set now_dt_ms=%today%%now_time%%ms%

set backup_dir=%BACKUP_ROOT%\%now_dt_ms%

if not exist %PROJECT_PATH% echo "%PROJECT_PATH% Not Exist!" && pause && exit 1


@ rem 排除哪些文件或目录
set exclude_dir=%CWD%\exclude_files
set exclude_file=%exclude_dir%\%now_dt_ms%.txt
set exclude_str="PrintBuffer"
md %exclude_dir%
:GOON
for /f "delims=;, tokens=1,*" %%i in (%exclude_str%) do (
    echo %%i>>%exclude_file%
    set exclude_str="%%j"
    goto GOON
)

md %backup_dir%
xcopy /s /i /y /EXCLUDE:%exclude_file% %PROJECT_PATH% %backup_dir%

echo From: %PROJECT_PATH%
echo To: %backup_dir%

pause