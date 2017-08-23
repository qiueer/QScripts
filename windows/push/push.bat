@ echo off
@ title send init package


set RP=%~dp0
set PATH=%PATH%;%RP%;C:\python;C:\python279;C:\python27

cd %RP%
python push.py

pause