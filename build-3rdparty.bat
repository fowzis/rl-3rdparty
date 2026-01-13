@echo off
REM Batch file wrapper to run build-3rdparty.ps1 with execution policy bypass
REM Builds ALL dependencies including Windows and Linux versions
REM 
REM Usage: build-3rdparty.bat [parameters]
REM Examples:
REM   build-3rdparty.bat                    - Build shared libraries
REM   build-3rdparty.bat -Clean             - Clean previous build and build shared libraries
REM   build-3rdparty.bat -Config Debug -Architecture x64

set SCRIPT_DIR=%~dp0
set LOG_DIR=%SCRIPT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Redirect output to log file while also displaying on console using PowerShell Tee-Object
REM Generate timestamp and log file path entirely within PowerShell for reliability
REM Pass all command-line arguments to the PowerShell script via wrapper
PowerShell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%build-3rdparty-wrapper.ps1" "%LOG_DIR%" %*

set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% NEQ 0 (
    echo.
    echo Script failed with error code %EXIT_CODE%
    echo PowerShell script also creates its own log in: %LOG_DIR%
    pause
    exit /b %EXIT_CODE%
)

echo.
echo PowerShell script also creates its own log in: %LOG_DIR%
pause
