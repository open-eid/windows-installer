@echo off
echo This process might restart windows, Press ENTER to execute the command
pause > nul
wmic product where "Name like '%%Eesti ID%%'" Call Reinstall
for /f "delims=" %%a in ('dir /b /a-d /s "C:\ProgramData\Open-EID*.exe"') do "%%~fa" /repair /quiet RunQesteidutil=0