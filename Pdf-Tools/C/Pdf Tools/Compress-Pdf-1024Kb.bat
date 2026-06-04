@echo off
setlocal enabledelayedexpansion

title PDF Compressor - Auto Adaptive

:: ============================================
:: === USER CONFIGURATION VARIABLES ===========
:: ============================================

set "AUTO_CLOSE=3"               :: Seconds before auto-close
set "PDF_RESOLUTION=150"         :: Resolution for mutool (dpi)
set "IMG_DENSITY=150"            :: Density for magick

set "IMG_RESIZE_MIN=40"          :: Minimum resize percentage
set "IMG_QUALITY_MIN=50"         :: Minimum JPEG quality

set "IMG_RESIZE_START=75"        :: Starting resize percentage
set "IMG_QUALITY_START=85"       :: Starting JPEG quality

set "TARGET_MB=0.8"                :: Target max file size (MB)

set "STEP=5"                     :: Reduce quality & resize by this step per iteration
:: ============================================

set "mutool=C:\Pdf Tools\mutool\mutool.exe"
set "magick=C:\Pdf Tools\ImageMagick\magick.exe"

cls

echo ============================================================
echo              PDF Compressor - Auto Adaptive
echo ============================================================
echo.

if "%~1"=="" (
    echo [!] No input file provided!
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

:: === FILE SIZE CHECK (Skip if < TARGET_MB) ===
for %%I in ("%~1") do set "FileSize=%%~zI"
set /a "FileSizeKB=FileSize/1024"
set /a "FileSizeMB=FileSizeKB/1024"

echo [INFO] File size detected: !FileSizeMB! MB
echo ------------------------------------------------------------

if !FileSizeMB! lss %TARGET_MB% (
    echo     File size is already below %TARGET_MB% MB.
    echo     Skipping compression.
    echo ------------------------------------------------------------
    echo Closing in %AUTO_CLOSE% seconds...
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)

echo [1/7] Checking PDF encryption status...
"%mutool%" info "%~1" 2>&1 | findstr /i "encrypted password" >nul
if %errorlevel%==0 (
    echo [ERROR] The provided PDF is password protected.
    echo Remove the password before compressing.
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)

echo     PDF is not Encrypted.
echo ------------------------------------------------------------
set "Input=%~1"
cd /d "%~dp1"
set "BaseName=%~n1"
set "Work_Dir=Work_%RANDOM%"
md "%Work_Dir%" >nul 2>&1

echo [2/7] Extracting PDF pages to images...
"%mutool%" draw -r %PDF_RESOLUTION% -o "%Work_Dir%\page_%%03d.jpg" "%Input%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to extract images from PDF.
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)
echo     Extraction complete.
echo ------------------------------------------------------------

:: === Start iterative compression loop ===
set /a Resize=%IMG_RESIZE_START%
set /a Quality=%IMG_QUALITY_START%
set "Final_Pdf=%~dp1%BaseName%_Compressed_Below_1MB.pdf"

:CompressLoop
echo [3/7] Rebuilding PDF at %Resize%%% resize and %Quality%%% quality...
"%magick%" "%Work_Dir%\page_*.jpg" -density %IMG_DENSITY% -resize %Resize%%% -quality %Quality% -compress jpeg "%Final_Pdf%" >nul 2>&1

for %%I in ("%Final_Pdf%") do set "NowSize=%%~zI"
set /a "NowKB=NowSize/1024"
set /a "NowMB=NowKB/1024"
echo     Result size: !NowMB! MB

if !NowMB! lss %TARGET_MB% (
    echo ------------------------------------------------------------
    echo Compression successful! Below %TARGET_MB% MB.
    echo Final size: !NowMB! MB
    goto :Cleanup
)

if !Resize! leq %IMG_RESIZE_MIN% if !Quality! leq %IMG_QUALITY_MIN% (
    echo ------------------------------------------------------------
    echo Reached minimum compression thresholds.
    echo Could not reduce below %TARGET_MB% MB safely.
    
    rd /s /q "%Work_Dir%" >nul 2>&1
    if exist "%Final_Pdf%" del /f /q "%Final_Pdf%" >nul 2>&1

    echo Closing in %AUTO_CLOSE% seconds...
    timeout /t %AUTO_CLOSE% /nobreak >nul
    exit
)

echo Still above target size (%TARGET_MB% MB)...
set /a Resize-=STEP
set /a Quality-=STEP

if !Resize! lss %IMG_RESIZE_MIN% set /a Resize=%IMG_RESIZE_MIN%
if !Quality! lss %IMG_QUALITY_MIN% set /a Quality=%IMG_QUALITY_MIN%

echo Retrying with resize=!Resize!%% and quality=!Quality!%% ...
echo ------------------------------------------------------------
goto :CompressLoop

:Cleanup
echo [7/7] Cleaning temporary files...
rd /s /q "%Work_Dir%" >nul 2>&1
echo Done.
echo ------------------------------------------------------------
echo Output saved as:
echo "%Final_Pdf%"
echo ------------------------------------------------------------
echo.
echo Compression finished.
echo Closing in %AUTO_CLOSE% seconds...
timeout /t %AUTO_CLOSE% /nobreak >nul
exit