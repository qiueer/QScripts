@ title split
@ echo off

set exclude_str="PrintBuffer;logs;/abc/"
:GOON
for /f "delims=;, tokens=1,*" %%i in (%exclude_str%) do (
	echo %%i
    set exclude_str="%%j"
    goto GOON
)

pause