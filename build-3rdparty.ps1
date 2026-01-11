# PowerShell script to build 3rdparty dependencies for Robotics Library
# Usage: .\build-3rdparty.ps1 [-InstallPrefix <path>] [-VisualStudioVersion <version>] [-Architecture <x64|x86>] [-Config <Release|Debug>]

param(
    [string]$InstallPrefix = "$PSScriptRoot\install",
    [string]$VisualStudioVersion = "17",  # Visual Studio 2022
    [ValidateSet("x64", "x86")]
    [string]$Architecture = "x64",
    [ValidateSet("Release", "Debug", "RelWithDebInfo", "MinSizeRel")]
    [string]$Config = "Release",
    [switch]$SkipBuild,
    [switch]$SkipInstall,
    [int]$ParallelJobs = 0  # 0 = use all available cores
)

$ErrorActionPreference = "Stop"

# Setup logging
$logDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $logDir "build-3rdparty-$timestamp.log"

# Start transcript to capture all output
Start-Transcript -Path $logFile -Append | Out-Null
Write-Host "Logging output to: $logFile" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Robotics Library 3rdparty Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check CMake version
Write-Host "Checking CMake version..." -ForegroundColor Yellow
$cmakeVersion = & cmake --version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: CMake not found. Please install CMake 3.24 or later." -ForegroundColor Red
    exit 1
}
Write-Host "Found: $cmakeVersion" -ForegroundColor Green

# Extract CMake version number
$cmakeVersionMatch = $cmakeVersion -match "version (\d+)\.(\d+)"
if ($cmakeVersionMatch) {
    $majorVersion = [int]$matches[1]
    $minorVersion = [int]$matches[2]
    if ($majorVersion -lt 3 -or ($majorVersion -eq 3 -and $minorVersion -lt 24)) {
        Write-Host "ERROR: CMake 3.24 or later is required. Found version $majorVersion.$minorVersion" -ForegroundColor Red
        exit 1
    }
}

# Determine Visual Studio generator
$generator = "Visual Studio $VisualStudioVersion 2022"
if ($VisualStudioVersion -eq "16") {
    $generator = "Visual Studio 16 2019"
} elseif ($VisualStudioVersion -eq "15") {
    $generator = "Visual Studio 15 2017"
}

Write-Host ""
Write-Host "Build Configuration:" -ForegroundColor Cyan
Write-Host "  Generator: $generator" -ForegroundColor White
Write-Host "  Architecture: $Architecture" -ForegroundColor White
Write-Host "  Configuration: $Config" -ForegroundColor White
Write-Host "  Install Prefix: $InstallPrefix" -ForegroundColor White
Write-Host "  Parallel Jobs: $(if ($ParallelJobs -eq 0) { 'All available' } else { $ParallelJobs })" -ForegroundColor White
Write-Host ""

# Check for downloads directory
$downloadsDir = Join-Path $PSScriptRoot "downloads"
if (-not (Test-Path $downloadsDir)) {
    Write-Host "ERROR: Downloads directory not found: $downloadsDir" -ForegroundColor Red
    Write-Host "Please run download-all-sources.ps1 first to download required source packages." -ForegroundColor Yellow
    exit 1
}

# Verify required downloads exist
Write-Host "Verifying required downloads..." -ForegroundColor Yellow
$requiredDownloads = @(
    "ATI\atidaq-cmake-1.0.6.tar.gz",
    "boost\boost-1.88.0-cmake.7z",
    "bullet\bullet3-3.25.tar.gz",
    "coin\coin-4.0.3-src.tar.gz",
    "eigen\eigen-3.4.0.tar.gz",
    "fcl\fcl-0.7.0.tar.gz",
    "gperf\gperf-cmake-3.2.tar.gz",
    "libccd\libccd-2.1.tar.gz",
    "libiconv\libiconv-cmake-1.18.tar.gz",
    "libxml2\libxml2-v2.14.1.tar.gz",
    "libxslt\libxslt-v1.1.43.tar.gz",
    "nlopt\nlopt-2.10.0.tar.gz",
    "ode\ode-0.16.6.tar.gz",
    "pqp\PQP-713de5b70dd1849b915f6412330078a9814e01ab.tar.gz",
    "simage\simage-1.8.3-src.tar.gz",
    "solid\solid3-cbac1402da5df65e7239558a6c04feb736e54b27.zip",
    "soqt\soqt-1.6.3-src.tar.gz",
    "superglu\superglu-1.3.2-src.tar.gz"
)

$missingFiles = 0
foreach ($file in $requiredDownloads) {
    $filePath = Join-Path $downloadsDir $file
    if (-not (Test-Path $filePath)) {
        Write-Host "  MISSING: $file" -ForegroundColor Red
        $missingFiles++
    }
}

if ($missingFiles -gt 0) {
    Write-Host ""
    Write-Host "ERROR: $missingFiles required download(s) are missing!" -ForegroundColor Red
    Write-Host "Please run download-all-sources.ps1 to download missing files." -ForegroundColor Yellow
    exit 1
}

Write-Host "  All required downloads found." -ForegroundColor Green
Write-Host ""

# Create build directory
$buildDir = Join-Path $PSScriptRoot "build"
if (-not (Test-Path $buildDir)) {
    Write-Host "Creating build directory: $buildDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

Push-Location $buildDir

try {
    # Configure CMake
    Write-Host "Configuring CMake..." -ForegroundColor Yellow
    $cmakeArgs = @(
        ".."
        "-G", "`"$generator`""
        "-A", $Architecture
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.20"
        "-DCMAKE_INSTALL_PREFIX=`"$InstallPrefix`""
        "-DCMAKE_BUILD_TYPE=$Config"
    )
    
    Write-Host "Running: cmake $($cmakeArgs -join ' ')" -ForegroundColor Gray
    & cmake @cmakeArgs 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: CMake configuration failed!" -ForegroundColor Red
        Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Configuration successful!" -ForegroundColor Green
    Write-Host ""
    
    if (-not $SkipBuild) {
        # Build dependencies
        Write-Host "Building dependencies (this may take 30-60 minutes)..." -ForegroundColor Yellow
        $buildArgs = @(
            "--build", "."
            "--config", $Config
        )
        
        if ($ParallelJobs -gt 0) {
            $buildArgs += "--parallel", $ParallelJobs
        } else {
            $buildArgs += "--parallel"
        }
        
        Write-Host "Running: cmake $($buildArgs -join ' ')" -ForegroundColor Gray
        & cmake @buildArgs 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed!" -ForegroundColor Red
            Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "Build successful!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "Skipping build (--SkipBuild specified)" -ForegroundColor Yellow
        Write-Host ""
    }
    
    if (-not $SkipInstall) {
        # Install dependencies
        Write-Host "Installing dependencies..." -ForegroundColor Yellow
        $installArgs = @(
            "--build", "."
            "--config", $Config
            "--target", "install"
        )
        
        Write-Host "Running: cmake $($installArgs -join ' ')" -ForegroundColor Gray
        & cmake @installArgs 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "WARNING: Install failed, but build artifacts are in the build directory" -ForegroundColor Yellow
            Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
        } else {
            Write-Host "Installation successful!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Dependencies installed to: $InstallPrefix" -ForegroundColor Green
        }
    } else {
        Write-Host "Skipping install (--SkipInstall specified)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Build Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To use these dependencies when building RL, set CMAKE_PREFIX_PATH:" -ForegroundColor Yellow
    Write-Host "  cmake .. -DCMAKE_PREFIX_PATH=`"$InstallPrefix`"" -ForegroundColor White
    Write-Host ""
    Write-Host "Build log saved to: $logFile" -ForegroundColor Gray
    Write-Host ""
    
} finally {
    Pop-Location
    Stop-Transcript | Out-Null
}
