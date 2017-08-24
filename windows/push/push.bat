@ echo off
@ title Windows File Push Tool By QiuJQ


set RP=%~dp0
set PATH=%PATH%;%RP%;C:\python;C:\python279;C:\python27

cd %RP%
python push.py

pause