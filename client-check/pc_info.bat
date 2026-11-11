@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
REM Тема: Диагностика клиентского компьютера + Аудит
REM Выполнил: [Ваша Фамилия Имя]

set "REPORT_FILE=%~dp0pc_report.txt"
set "TEMP_APPS=%~dp0apps_list.txt"

:: Очищаем файл отчета перед началом
echo Отчет о состоянии компьютера > "%REPORT_FILE%"
echo ======================================== >> "%REPORT_FILE%"
call :log "Дата и время формирования отчета: %DATE% %TIME%"
call :log "========================================"

:: ==========================================
:: БЛОК 1: СБОР СИСТЕМНОЙ ИНФОРМАЦИИ
:: ==========================================
call :log "Диагностика компьютера"
call :log "========================================"

:: --- Сведения об ОС ---
set "OS_CAPTION="
set "OS_VERSION="
for /f "usebackq tokens=*" %%A in (`powershell -Command "(Get-CimInstance Win32_OperatingSystem).Caption"`) do set "OS_CAPTION=%%A"
for /f "usebackq tokens=*" %%A in (`powershell -Command "(Get-CimInstance Win32_OperatingSystem).Version"`) do set "OS_VERSION=%%A"

if defined OS_CAPTION (
    call :log "Операционная система: !OS_CAPTION! (Версия: !OS_VERSION!)"
) else (
    call :log "Операционная система: Данные получить не удалось"
)

:: --- Сведения о процессоре ---
set "CPU_NAME="
for /f "usebackq tokens=*" %%A in (`powershell -Command "(Get-CimInstance Win32_Processor).Name"`) do set "CPU_NAME=%%A"

if defined CPU_NAME (
    call :log "Процессор: !CPU_NAME!"
) else (
    call :log "Процессор: Данные получить не удалось"
)

:: --- Сведения о памяти ---
set "TOTAL_RAM="
set "FREE_RAM="
for /f "usebackq tokens=*" %%A in (`powershell -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1048576)"`) do set "TOTAL_RAM=%%A"
for /f "usebackq tokens=*" %%A in (`powershell -Command "[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1048576)"`) do set "FREE_RAM=%%A"

if defined TOTAL_RAM (
    call :log "Оперативная память: Всего !TOTAL_RAM! ГБ, Свободно !FREE_RAM! ГБ"
) else (
    call :log "Оперативная память: Данные получить не удалось"
)

:: --- Сведения о диске C ---
set "TOTAL_DISK="
set "FREE_DISK="
for /f "usebackq tokens=*" %%A in (`powershell -Command "[math]::Round((Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'}).Size / 1073741824)"`) do set "TOTAL_DISK=%%A"
for /f "usebackq tokens=*" %%A in (`powershell -Command "[math]::Round((Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'}).FreeSpace / 1073741824)"`) do set "FREE_DISK=%%A"

if defined TOTAL_DISK (
    call :log "Диск C: Общий размер !TOTAL_DISK! ГБ, Свободно !FREE_DISK! ГБ"
) else (
    call :log "Диск C: Данные получить не удалось"
)

:: ==========================================
:: БЛОК 2: СБОР СПИСКА ПРОГРАММ
:: ==========================================
call :log "========================================"
call :log "Сбор списка установленных программ..."
echo Идет опрос реестра, это может занять пару минут...

break > "%TEMP_APPS%"
for /f "tokens=3*" %%A in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr "DisplayName"') do echo %%A %%B >> "%TEMP_APPS%"
for /f "tokens=3*" %%A in ('reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr "DisplayName"') do echo %%A %%B >> "%TEMP_APPS%"

sort "%TEMP_APPS%" /O "%TEMP_APPS%"
call :log "Список программ успешно собран."

:: ==========================================
:: БЛОК 3: АНАЛИЗ БАЗОВОГО ПО
:: ==========================================
call :log "========================================"
call :log "АНАЛИЗ БАЗОВОГО ПО (Рекомендации по установке)"
call :log "========================================"

set /a REC_COUNT=0
set /a CHECK_COUNT=0

:: 1. Офисный пакет
set /a CHECK_COUNT+=1
findstr /I /C:"Office" /C:"LibreOffice" /C:"OpenOffice" /C:"МойОфис" "%TEMP_APPS%" >nul
if errorlevel 1 (
    call :log "[-] Не обнаружен офисный пакет. Рекомендуется установить Microsoft Office, LibreOffice или МойОфис."
    set /a REC_COUNT+=1
) else (
    call :log "[+] Офисный пакет обнаружен."
)

:: 2. Браузер
set /a CHECK_COUNT+=1
findstr /I /C:"Chrome" /C:"Firefox" /C:"Яндекс" /C:"Edge" "%TEMP_APPS%" >nul
if errorlevel 1 (
    call :log "[-] Не обнаружен браузер. Рекомендуется установить Google Chrome или Яндекс.Браузер."
    set /a REC_COUNT+=1
) else (
    call :log "[+] Браузер обнаружен (Примечание: Edge является системным компонентом)."
)

:: 3. PDF-ридер
set /a CHECK_COUNT+=1
findstr /I /C:"Acrobat" /C:"Foxit" /C:"SumatraPDF" "%TEMP_APPS%" >nul
if errorlevel 1 (
    call :log "[-] Не обнаружена программа для чтения PDF. Рекомендуется установить Adobe Acrobat Reader."
    set /a REC_COUNT+=1
) else (
    call :log "[+] Программа для чтения PDF обнаружена."
)

:: 4. Архиватор
set /a CHECK_COUNT+=1
findstr /I /C:"7-Zip" /C:"WinRAR" /C:"WinZip" "%TEMP_APPS%" >nul
if errorlevel 1 (
    call :log "[-] Не обнаружен архиватор. Для работы с вложениями в почте рекомендуется установить 7-Zip или WinRAR."
    set /a REC_COUNT+=1
) else (
    call :log "[+] Архиватор обнаружен."
)

:: 5. Антивирус
set /a CHECK_COUNT+=1
findstr /I /C:"Defender" /C:"Kaspersky" /C:"ESET" /C:"Dr.Web" "%TEMP_APPS%" >nul
if errorlevel 1 (
    call :log "[-] Не обнаружен антивирус. Рекомендуется установить антивирусное ПО."
    set /a REC_COUNT+=1
) else (
    call :log "[+] Антивирус обнаружен."
)

:: ==========================================
:: БЛОК 4: АНАЛИЗ ИЗЛИШНЕГО ПО
:: ==========================================
call :log "========================================"
call :log "АНАЛИЗ ИЗЛИШНЕГО ПО (Рекомендации по проверке)"
call :log "========================================"
call :log "Внимание: список ниже является рекомендацией к проверке, а не указанием к удалению."

call :log "--- Игровое ПО ---"
findstr /I /C:"Steam" /C:"Epic Games" /C:"GOG" /C:"Origin" /C:"Ubisoft" /C:"Battle.net" /C:"Riot" /C:"game" "%TEMP_APPS%" > "%TEMP_APPS%_temp"
if errorlevel 1 (
    call :log "Игровое ПО не обнаружено."
) else (
    type "%TEMP_APPS%_temp"
    type "%TEMP_APPS%_temp" >> "%REPORT_FILE%"
    set /a REC_COUNT+=1
)

call :log "--- Торрент-клиенты ---"
findstr /I /C:"torrent" /C:"uTorrent" /C:"BitTorrent" /C:"qBittorrent" /C:"Vuze" "%TEMP_APPS%" > "%TEMP_APPS%_temp"
if errorlevel 1 (
    call :log "Торрент-клиенты не обнаружены."
) else (
    type "%TEMP_APPS%_temp"
    type "%TEMP_APPS%_temp" >> "%REPORT_FILE%"
    call :log "Внимание: торрент-клиенты создают нагрузку на сеть. Проверьте необходимость."
    set /a REC_COUNT+=1
)

call :log "--- Мессенджеры ---"
findstr /I /C:"Discord" /C:"Telegram" /C:"WhatsApp" /C:"Viber" /C:"Skype" "%TEMP_APPS%" > "%TEMP_APPS%_temp"
if errorlevel 1 (
    call :log "Сторонние мессенджеры не обнаружены."
) else (
    type "%TEMP_APPS%_temp"
    type "%TEMP_APPS%_temp" >> "%REPORT_FILE%"
    call :log "Внимание: данные мессенджеры могут не входить в корпоративный стандарт."
    set /a REC_COUNT+=1
)

call :log "--- Развлекательное ПО ---"
findstr /I /C:"Wallpaper Engine" /C:"OBS" /C:"Soundpad" "%TEMP_APPS%" > "%TEMP_APPS%_temp"
if errorlevel 1 (
    call :log "Развлекательное ПО не обнаружено."
) else (
    type "%TEMP_APPS%_temp"
    type "%TEMP_APPS%_temp" >> "%REPORT_FILE%"
    set /a REC_COUNT+=1
)

:: Удаляем временные файлы
if exist "%TEMP_APPS%" del "%TEMP_APPS%"
if exist "%TEMP_APPS%_temp" del "%TEMP_APPS%_temp"

:: ==========================================
:: БЛОК 5: ИТОГИ
:: ==========================================
call :log "========================================"
call :log "ИТОГИ:"
call :log "Проверено категорий базового ПО: !CHECK_COUNT!"
call :log "Выдано рекомендаций (всего): !REC_COUNT!"
call :log "Полный путь к отчету: %REPORT_FILE%"
call :log "Отчёт сохранён."
echo.
pause
exit /b

:: ==========================================
:: ПОДПРОГРАММА ВЫВОДА (ЛОГГЕР)
:: ==========================================
:log
set "log_text=%~1"
if "%log_text%"=="" (
    echo.
    echo. >> "%REPORT_FILE%"
) else (
    setlocal enabledelayedexpansion
    echo !log_text!
    echo !log_text! >> "%REPORT_FILE%"
    endlocal
)
exit /b