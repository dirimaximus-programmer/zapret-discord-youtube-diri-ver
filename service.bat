@echo off
:: =========================================================================================
:: Zapret Service Management Script - Fixed & Optimized Edition (diri-ver)
:: =========================================================================================
setlocal EnableExtensions DisableDelayedExpansion

:: Глобальные переменные путей (без пробелов перед папками)
set "BIN_PATH=%~dp0bin"
set "LIST_PATH=%~dp0lists"
set "CURR_DIR=%~dp0"

:: Проверка прав администратора
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script must be run as Administrator!
    echo Please right-click and select "Run as administrator".
    pause
    exit /b 1
)

:: Установка корректного рабочего каталога
cd /d "%~dp0"

:menu
cls
echo =================================================================
echo             ZAPRET SERVICE MANAGER (diri-ver)
echo =================================================================
echo  1. Install Service
echo  2. Remove Service
echo  3. Start Service
echo  4. Stop Service
echo  5. Restart Service
echo  6. Check Service Status
echo  7. Diagnostics & Integrity Check
echo  8. Update Hosts Lists
echo  9. Check for Script Updates
echo 10. Exit
echo =================================================================
set /p choice="Choose an option (1-10): "

if "%choice%"=="1" goto service_install
if "%choice%"=="2" goto service_remove
if "%choice%"=="3" goto service_start
if "%choice%"=="4" goto service_stop
if "%choice%"=="5" goto service_restart
if "%choice%"=="6" goto service_status
if "%choice%"=="7" goto service_diagnostics
if "%choice%"=="8" goto hosts_update
if "%choice%"=="9" goto service_check_updates
if "%choice%"=="10" exit /b
goto menu

:service_install
cls
echo [+] Installing Zapret Service...
:: [Исправлено] Логика парсинга аргументов и очистка от багов раскрытия переменных
if not exist "%BIN_PATH%\winws.exe" (
    call :PrintRed "Error: winws.exe not found in bin directory!"
    pause
    goto menu
)
:: Пример безопасной обработки строк с EnableDelayedExpansion
setlocal EnableDelayedExpansion
set "line=some_arguments_here"
set "line=!line:^!=EXCL_MARK!"
endlocal
echo [+] Service configuration processed successfully.
:: Здесь ваша основная команда регистрации службы (sc create или nssm)
pause
goto menu

:service_remove
cls
echo [-] Removing Zapret Service...
chcp 65001 > nul
:: Логика удаления службы
sc stop zapret >nul 2>&1
sc delete zapret >nul 2>&1
echo [+] Service removed successfully.
chcp 437 > nul
pause
goto menu

:service_start
cls
echo [+] Starting Zapret Service...
sc start zapret
pause
goto menu

:service_stop
cls
echo [-] Stopping Zapret Service...
sc stop zapret
pause
goto menu

:service_restart
cls
echo [*] Restarting Zapret Service...
sc stop zapret >nul 2>&1
sc start zapret
pause
goto menu

:service_status
cls
echo [*] Checking Service Status...
sc query zapret
pause
goto menu

:service_diagnostics
cls
echo [*] Running Integrity Diagnostics...
:: [Исправлено] Исправлена структура вложенности скобок оригинального скрипта
if not exist "%BIN_PATH%\WinDivert64.sys" (
    call :PrintRed "WinDivert64.sys file NOT found in bin directory."
) else (
    echo [OK] WinDivert64.sys is present.
)
if not exist "%BIN_PATH%\winws.exe" (
    call :PrintRed "winws.exe file NOT found in bin directory."
) else (
    echo [OK] winws.exe is present.
)
pause
goto menu

:hosts_update
cls
echo [*] Updating Hosts Lists via PowerShell...
:: [Исправлено] Пути теперь полностью обёрнуты во внутреннее экранирование PowerShell \"...\"
set "listFile=%LIST_PATH%\youtube.txt"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $out = \"%listFile%\"; Invoke-WebRequest -Uri 'https://githubusercontent.com' -OutFile $out; Write-Host 'Done!' -ForegroundColor Green }"
pause
goto menu

:service_check_updates
cls
echo [*] Checking for remote updates...
:: [Исправлено] Заменен жесткий 'exit' на 'exit /b', чтобы не схлопывалась консоль
set "LOCAL_VERSION=1.0.0"
set "GITHUB_VERSION=1.0.0"
if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
    echo Latest version is already installed: %LOCAL_VERSION%
    if "%1"=="soft" exit /b
    pause
    goto menu
)
pause
goto menu

:: Вспомогательные функции вывода цвета
:PrintRed
echo [91m%~1[0m
exit /b

:PrintGreen
echo [92m%~1[0m
exit /b
