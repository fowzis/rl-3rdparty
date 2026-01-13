# Wrapper script to handle logging and pass arguments to build-3rdparty.ps1
# First argument is the log directory, remaining arguments are passed to build-3rdparty.ps1

$ErrorActionPreference = "Continue"

# First argument is the log directory
$logDir = $args[0]

# Setup batch-specific logging
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $logDir "build-3rdparty-batch-$timestamp.log"
Write-Host "Batch log: $logFile"

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path $scriptDir "build-3rdparty.ps1"

# Get all remaining arguments (skip the first one which is the log directory)
$scriptArgs = @()
if ($args.Count -gt 1) {
    $scriptArgs = $args[1..($args.Count - 1)]
}

# Call the main script with all arguments and log output
if ($scriptArgs.Count -gt 0) {
    & $scriptPath @scriptArgs *>&1 | Tee-Object -FilePath $logFile
} else {
    & $scriptPath *>&1 | Tee-Object -FilePath $logFile
}

$exitCode = $LASTEXITCODE
exit $exitCode
