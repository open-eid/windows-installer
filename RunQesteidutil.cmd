@echo off
if [%1] NEQ [1] goto :eof
IF EXIST "C:\Program Files\Open-EID\qesteidutil.exe" (start "" "C:\Program Files\Open-EID\qesteidutil.exe")
IF EXIST "C:\Program Files (x86)\Open-EID\qesteidutil.exe" (start "" "C:\Program Files (x86)\Open-EID\qesteidutil.exe")
