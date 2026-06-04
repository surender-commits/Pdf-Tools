@echo off
setlocal enabledelayedexpansion

title PDF Compressor - Basic Mode

:: ============================================
:: === USER CONFIGURATION VARIABLES ============
:: ============================================
set "AUTO_CLOSE=3"           :: Seconds before auto-close
set "PDF_RESOLUTION=200"     :: Resolution for mutool (dpi)
set "IMG_DENSITY=200"        :: Density for magick when rebuilding PDF
set "IMG_RESIZE=75%%"        :: Resize percentage for magick (e.g., 75%%)
set "IMG_QUALITY=85"         :: JPEG quality (0-100)
:: ============================================

set "mutool=C:\Pdf Tools\mutool\mutool.exe"
set "magick=C:\Pdf Tools\ImageMagick\magick.exe"

cls
echo ============================================================
echo                    PDF Compressor - Basic
echo ============================================================
echo.

if "%~1"=="" (
    echo ------------------------------------------------------------
    echo [!] No input file provided!
    echo ------------------------------------------------------------    
    echo Closing in %AUTO_CLOSE% seconds...
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)

echo Input file detected:
echo ------------------------------------------------------------
echo     File Name : %~nx1
echo     File Path : %~dp1
echo ------------------------------------------------------------
echo.

:: === FILE SIZE CHECK (Skip if < 1024 KB) ===
for %%I in ("%~1") do set "FileSizeBytes=%%~zI"
set /a "FileSizeKB=FileSizeBytes/1024"

echo ------------------------------------------------------------
echo [INFO] File size detected: !FileSizeKB! KB
echo ------------------------------------------------------------

if !FileSizeKB! lss 500 (
    echo     File size is below 500 KB.
    echo     Skipping compression to avoid overcompression.
    echo ------------------------------------------------------------
    echo Closing in %AUTO_CLOSE% seconds...
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)

echo [1/6] Checking PDF encryption status...
"%mutool%" info "%~1" 2>&1 | findstr /i /c:"encrypted" /c:"password" >nul
if %errorlevel%==0 (
    echo ------------------------------------------------------------
    echo ERROR: The provided PDF is password protected.
    echo Please remove the password before compressing.
    echo ------------------------------------------------------------
    echo Closing in %AUTO_CLOSE% seconds...
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)

echo     PDF is not Encrypted.
echo ------------------------------------------------------------
echo [2/6] Preparing workspace...
cd /d "%~dp1"
set "Work_Dir=Work_Dir_ID_%RANDOM%"
set "Input=%~1"
set "Final_Pdf=%~dp1%~n1_Compressed_Basic.pdf"
md "%Work_Dir%" >nul 2>&1
echo     Working folder created: "%Work_Dir%"
echo ------------------------------------------------------------

echo [3/6] Converting PDF pages to images...
echo     Resolution: %PDF_RESOLUTION% DPI
echo ------------------------------------------------------------
"%mutool%" draw -r %PDF_RESOLUTION% -o "%Work_Dir%\page_%%03d.jpg" "%Input%" >nul 2>&1

if %errorlevel% neq 0 (
    echo [!] ERROR: Failed to extract images from PDF.
    echo     Make sure the input file is valid.
    echo Closing in %AUTO_CLOSE% seconds...
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)
echo     Conversion completed successfully.
echo ------------------------------------------------------------

echo [4/6] Optimizing extracted images...
echo     This may take a few moments depending on file size.
echo ------------------------------------------------------------
for %%A in ("%Work_Dir%\*.jpg") do (
    "%magick%" "%%~A" -strip -interlace Plane "%%~A" >nul 2>&1
)
echo     Image optimization complete.
echo ------------------------------------------------------------

echo [5/6] Rebuilding compressed PDF...
echo     Density : %IMG_DENSITY%
echo     Resize  : %IMG_RESIZE%
echo     Quality : %IMG_QUALITY%
echo ------------------------------------------------------------
"%magick%" "%Work_Dir%\page_*.jpg" -density %IMG_DENSITY% -resize %IMG_RESIZE% -quality %IMG_QUALITY% -compress jpeg "%Final_Pdf%" >nul 2>&1

if %errorlevel% neq 0 (
    echo [!] ERROR: Failed to rebuild compressed PDF.
    echo     Check if ImageMagick is properly installed.
    echo Closing in %AUTO_CLOSE% seconds...
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)
echo     Rebuild complete.
echo ------------------------------------------------------------

echo [6/6] Cleaning up temporary files...
rd /s /q "%Work_Dir%" >nul 2>&1
echo     Temporary files deleted.
echo ------------------------------------------------------------
echo.
echo ============================================================
echo                   COMPRESSION COMPLETE
echo ============================================================
echo Output saved as:
echo "%Final_Pdf%"
echo ============================================================
echo.

endlocal

echo Closing in %AUTO_CLOSE% seconds...
timeout /t %AUTO_CLOSE% /nobreak >nul
exit