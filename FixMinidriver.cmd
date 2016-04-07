@echo off
>nul 2>nul dir /b /a-d /s "C:\Windows\System32\DriverStore\FileRepository\esteidcm.inf" && (
   echo "esteidcm.inf found"
) || (
   wmic product where "Name like '%%Eesti ID%%'" Call Reinstall
   wmic product where "Name like '%%minidriver%%'" Call Reinstall
)