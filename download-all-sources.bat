@echo off
REM Batch file wrapper to run download-all-sources.ps1 with execution policy bypass
REM Downloads ALL dependencies including Windows and Linux versions

set SCRIPT_DIR=%~dp0
PowerShell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%download-all-sources.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Script failed with error code %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

pause
