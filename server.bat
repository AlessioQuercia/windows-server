@echo off

if "%1" == "" echo Argument not specified! & echo. & goto :p_help

if "%1" == "/on" (
    goto :turn_on
    ) else if "%1" == "on" (
    goto :turn_on
    ) else if "%1" equ "/off" (
    goto :turn_off
    ) else if "%1" equ "off" (
    goto :turn_off
    ) else if "%1" equ "/access" (
    goto :access
    ) else if "%1" equ "access" (
    goto :access
    ) else if "%1" equ "/backup" (
    goto :backup
    ) else if "%1" equ "backup" (
    goto :backup
    ) else if "%1" equ "/set_usr" (
    goto :set_username
    ) else if "%1" equ "/set_ip" (
    goto :set_ip_address 
    ) else if "%1" equ "/set_mac" (
    goto :set_mac_address 
    ) else if "%1" equ "/set_src_bkp" (
    goto :set_src_bkp
    ) else if "%1" equ "/set_dst_bkp" (
    goto :set_src_bkp 
    ) else if "%1" equ "/?" (
    goto :p_help
    ) else if "%1" equ "?" (
    goto :p_help
    ) else (
    echo Argument not supported!
    exit /b
    )


:turn_on
wolcmd %SERVER_MAC_ADDRESS% %SERVER_IP_ADDRESS% 255.255.255.255
exit /b


:turn_off
ssh %SERVER_USERNAME%@%SERVER_IP_ADDRESS% "cmd.exe /k shutdown /h"
exit /b


:access
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no %SERVER_USERNAME%@%SERVER_IP_ADDRESS%
exit /b


:backup
goto :backup_reg
wsl.exe rsync -aruvPR %SRC_BKP% %SERVER_USERNAME%@%SERVER_IP_ADDRESS%:%DST_BKP%
exit /b


:backup_reg
mkdir "reg"
reg export HKLM "reg/HKLM.reg" /y
reg export HKCU "reg/HKCU.reg" /y
reg export HKCR "reg/HKCR.reg" /y
reg export HKU "reg/HKU.reg" /y
reg export HKCC "reg/HKCC.reg" /y
wsl.exe rsync -aruvP "reg/" %SERVER_USERNAME%@%SERVER_IP_ADDRESS%:%DST_BKP%/
rmdir /s "reg"
exit /b


:set_username
setx SERVER_USERNAME %2
exit /b


:set_ip_address
setx SERVER_IP_ADDRESS %2
exit /b


:set_mac_address
setx SERVER_MAC_ADDRESS %2
exit /b


:set_src_bkp
setx SRC_BKP %2
exit /b


:set_dst_bkp
setx DST_BKP %2
exit /b


:p_help
echo.Usage:
echo.
echo.  server [Options]
echo.
echo.Options:
echo.
echo.  /on                     Turn the Server on.
echo.  /off                    Turn the Server off.
echo.  /access                 Access the Server.
echo.  /backup                 Backup data to the server (from %SRC_BKP% to %SERVER_USERNAME%@%SERVER_IP_ADDRESS%:%DST_BKP%).
echo.  /set_usr [username]     Set an environment variable with the Server username you want to connect to.
echo.  /set_ip [ip_address]    Set an environment variable with the Server IP address.
echo.  /set_mac [mac_address]  Set an environment variable with the Server MAC address.
echo.  /set_src_bkp [src]      Set an environment variable with the source path of the backup.
echo.  /set_dst_bkp [dst]      Set an environment variable with the destination path of the backup (Server excluded).
echo.
echo.Note: Before using the on, off, access Options, you need to set the following environment variables (either manually or using the /set options):
echo.      - SERVER_USERNAME      Username of the account you want to connect in the Server.
echo.      - SERVER_IP_ADDRESS    IP address of the Server.
echo.      - SERVER_MAC_ADDRESS   MAC address of the Server.
echo.
echo.      Before using the backup Option, you need to additionally set the following environment variables:
echo.      - SRC_BKP              Source path you want to backup to the Server.
echo.      - DST_BKP              Destination in the Server where you want to backup the data.
echo.  If you don't want to use environment variables, you can manually insert the required Server information in this script.  
exit /b
