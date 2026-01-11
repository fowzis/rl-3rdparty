@echo off
REM Batch file wrapper to run build-3rdparty.ps1 with execution policy bypass
REM Builds ALL dependencies including Windows and Linux versions

set SCRIPT_DIR=%~dp0
set LOG_DIR=%SCRIPT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Redirect output to log file while also displaying on console using PowerShell Tee-Object
REM Generate timestamp and log file path entirely within PowerShell for reliability
REM Use default install prefix (script directory\install) unless overridden
PowerShell -ExecutionPolicy Bypass -Command "& { $ErrorActionPreference='Continue'; $logDir = '%LOG_DIR%'; $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'; $logFile = Join-Path $logDir \"build-3rdparty-batch-$timestamp.log\"; Write-Host \"Batch log: $logFile\"; & '%SCRIPT_DIR%build-3rdparty.ps1' *>&1 | Tee-Object -FilePath $logFile; $exitCode = $LASTEXITCODE; exit $exitCode }"

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
