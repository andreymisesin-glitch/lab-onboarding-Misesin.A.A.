@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
REM Тема: Диагностика клиентского компьютера
REM Выполнил: [Ваша Фамилия Имя]

set "REPORT_FILE=%~dp0pc_report.txt"
echo Отчет о состоянии компьютера > "%REPORT_FILE%"
echo ======================================== >> "%REPORT_FILE%"

echo Диагностика компьютера
echo ========================================
echo Диагностика компьютера >> "%REPORT_FILE%"
echo ======================================== >> "%REPORT_FILE%"
echo.

REM --- Сведения об операционной системе ---
echo Операционная система:
echo Операционная система: >> "%REPORT_FILE%"
powershell -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version | Format-List"
powershell -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version | Format-List" >> "%REPORT_FILE%"
echo.
echo. >> "%REPORT_FILE%"

REM --- Сведения о процессоре ---
echo Процессор:
echo Процессор: >> "%REPORT_FILE%"
powershell -Command "Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name"
powershell -Command "Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name" >> "%REPORT_FILE%"
echo.
echo. >> "%REPORT_FILE%"

REM --- Сведения об оперативной памяти ---
echo Оперативная память:
echo Оперативная память: >> "%REPORT_FILE%"
for /f "usebackq tokens=*" %%A in (`powershell -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1048576)"`) do set TOTAL_RAM=%%A
for /f "usebackq tokens=*" %%A in (`powershell -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1048576)"`) do set FREE_RAM=%%A
echo Всего памяти: %TOTAL_RAM% ГБ
echo Свободно памяти: %FREE_RAM% ГБ
echo Всего памяти: %TOTAL_RAM% ГБ >> "%REPORT_FILE%"
echo Свободно памяти: %FREE_RAM% ГБ >> "%REPORT_FILE%"
echo.
echo. >> "%REPORT_FILE%"

REM --- Свободное место на диске C ---
echo Диск C:
echo Диск C: >> "%REPORT_FILE%"
for /f "usebackq tokens=*" %%A in (`powershell -Command "[math]::Round((Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'}).Size / 1073741824)"`) do set TOTAL_DISK=%%A
for /f "usebackq tokens=*" %%A in (`powershell -Command "[math]::Round((Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'}).FreeSpace / 1073741824)"`) do set FREE_DISK=%%A
echo Общий размер: %TOTAL_DISK% ГБ
echo Свободно: %FREE_DISK% ГБ
echo Общий размер: %TOTAL_DISK% ГБ >> "%REPORT_FILE%"
echo Свободно: %FREE_DISK% ГБ >> "%REPORT_FILE%"
echo.
echo. >> "%REPORT_FILE%"

REM --- Список установленных программ ---
echo Установленные программы (идет поиск, может занять несколько минут):
echo Установленные программы: >> "%REPORT_FILE%"
echo Пожалуйста, подождите...
echo Пожалуйста, подождите... >> "%REPORT_FILE%"

reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2>nul | findstr /C:"DisplayName" | findstr /V "HKEY" | findstr /V "End"
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2>nul | findstr /C:"DisplayName" | findstr /V "HKEY" | findstr /V "End" >> "%REPORT_FILE%"

reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2>nul | findstr /C:"DisplayName" | findstr /V "HKEY" | findstr /V "End"
reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2>nul | findstr /C:"DisplayName" | findstr /V "HKEY" | findstr /V "End" >> "%REPORT_FILE%"

echo.
echo. >> "%REPORT_FILE%"
echo ========================================
echo ======================================== >> "%REPORT_FILE%"
echo Отчёт сохранён в файл pc_report.txt
echo Отчёт сохранён в файл pc_report.txt >> "%REPORT_FILE%"

pause