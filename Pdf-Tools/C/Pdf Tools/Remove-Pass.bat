@echo off
setlocal enabledelayedexpansion

title QPDF - Remove PDF Password

:: ==========================================
:: QPDF - Remove PDF Password (Clean UI)
:: ==========================================
echo ------------------------------------------
echo        QPDF - Remove PDF Password
echo ------------------------------------------
echo.

:: ===========================
:: CONFIGURATION
:: ===========================
set "AUTO_CLOSE=3"
set "qpdf=C:\Pdf Tools\qpdf\qpdf.exe"

:: ===========================
:: INPUT VALIDATION
:: ===========================
if "%~1"=="" (
    echo [!] No input file provided
    echo Usage: %~nx0 "file.pdf"
    echo.
    call :CloseExit 1
)

set "Input=%~1"
set "Dir=%~dp1"
set "Base=%~n1"
set "Unlocked=%Dir%%Base%_ID_%RANDOM%_Unlocked.pdf"

echo Input: "%Input%"
echo ------------------------------------------

call :CheckEncrypted

if "%IS_ENCRYPTED%"=="0" (
    echo PDF is not locked or only has owner restrictions
    echo No password needed. Nothing to remove.
    echo.
    call :CloseExit 0
)

echo PDF requires a password to open
echo You have three attempts.
echo Output file will be: "%Unlocked%"
echo ------------------------------------------
echo.

set /a ATTEMPTS=0

:PasswordLoop
set /a ATTEMPTS+=1

if !ATTEMPTS! GTR 3 (
    echo Too many attempts. Exiting.
    echo.
    call :CloseExit 1
)

echo Attempt !ATTEMPTS! of 3
set /p "PW=Enter password (Q to quit): "

if /i "!PW!"=="Q" (
    echo Operation cancelled by user.
    echo.
    call :CloseExit 1
)

"%qpdf%" --password="!PW!" --decrypt "%Input%" "%Unlocked%" >nul 2>&1

if "!errorlevel!"=="0" (
    echo Password accepted
    echo File decrypted:
    echo "%Unlocked%"
    echo.
    call :CloseExit 0
) else (
    if exist "%Unlocked%" del /f /q "%Unlocked%" >nul 2>&1
    echo Incorrect password, try again
    echo.
    goto :PasswordLoop
)

:: --------------------------------------------------
:: FUNCTIONS BELOW
:: --------------------------------------------------

:CheckEncrypted
echo Checking PDF encryption...
"%qpdf%" --decrypt "%Input%" "%Unlocked%" >nul 2>&1
if "%errorlevel%"=="0" (
    set "IS_ENCRYPTED=0"
    del /f /q "%Unlocked%" >nul 2>&1
) else (
    set "IS_ENCRYPTED=1"
)
goto :eof

:CloseExit
echo Closing in %AUTO_CLOSE% seconds...
timeout /t %AUTO_CLOSE% /nobreak >nul
exit