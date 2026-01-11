# PowerShell script to download ALL 3rdparty source packages (Windows and Linux versions)
# Usage: .\download-all-sources.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DownloadsDir = Join-Path $ScriptDir "downloads"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Downloading ALL 3rdparty Sources" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create download directories
$Dirs = @(
    "ATI",
    "boost",
    "bullet",
    "coin",
    "eigen",
    "fcl",
    "gperf",
    "libccd",
    "libiconv",
    "libxml2",
    "libxslt",
    "nlopt",
    "ode",
    "pqp",
    "simage",
    "solid",
    "soqt",
    "superglu"
)

foreach ($dir in $Dirs) {
    $dirPath = Join-Path $DownloadsDir $dir
    if (-not (Test-Path $dirPath)) {
        Write-Host "Creating directory: $dirPath" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
    }
}

# All downloads - URLs from CMakeLists.txt files
$Downloads = @(
    # atidaq
    @{
        Name = "ATI"
        File = "atidaq-cmake-1.0.6.tar.gz"
        URL = "https://github.com/roboticslibrary/atidaq/archive/cmake-1.0.6.tar.gz"
        Description = "ATIDAQ C Library"
        Platform = "Both"
    },
    
    # boost
    @{
        Name = "boost"
        File = "boost-1.88.0-cmake.7z"
        URL = "https://github.com/boostorg/boost/releases/download/boost-1.88.0/boost-1.88.0-cmake.7z"
        Description = "Boost 1.88.0"
        Platform = "Both"
    },
    
    # bullet3
    @{
        Name = "bullet"
        File = "bullet3-3.25.tar.gz"
        URL = "https://github.com/bulletphysics/bullet3/archive/refs/tags/3.25.tar.gz"
        Description = "Bullet Physics 3.25"
        Platform = "Both"
    },
    
    # coin
    @{
        Name = "coin"
        File = "coin-4.0.3-src.tar.gz"
        URL = "https://github.com/coin3d/coin/releases/download/v4.0.3/coin-4.0.3-src.tar.gz"
        Description = "Coin3D Coin-4.0.3"
        Platform = "Both"
    },
    
    # eigen3
    @{
        Name = "eigen"
        File = "eigen-3.4.0.tar.gz"
        URL = "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz"
        Description = "Eigen 3.4.0"
        Platform = "Both"
    },
    
    # fcl
    @{
        Name = "fcl"
        File = "fcl-0.7.0.tar.gz"
        URL = "https://github.com/flexible-collision-library/fcl/archive/refs/tags/0.7.0.tar.gz"
        Description = "FCL (Flexible Collision Library) 0.7.0"
        Platform = "Both"
    },
    
    # gperf
    @{
        Name = "gperf"
        File = "gperf-cmake-3.2.tar.gz"
        URL = "https://github.com/roboticslibrary/gperf/archive/cmake-3.2.tar.gz"
        Description = "GNU gperf (RoboticsLibrary fork)"
        Platform = "Both"
    },
    
    # libccd
    @{
        Name = "libccd"
        File = "libccd-2.1.tar.gz"
        URL = "https://github.com/danfis/libccd/archive/v2.1.tar.gz"
        Description = "libccd 2.1"
        Platform = "Both"
    },
    
    # libiconv
    @{
        Name = "libiconv"
        File = "libiconv-cmake-1.18.tar.gz"
        URL = "https://github.com/roboticslibrary/libiconv/archive/cmake-1.18.tar.gz"
        Description = "GNU libiconv (RoboticsLibrary fork)"
        Platform = "Both"
    },
    
    # libxml2
    @{
        Name = "libxml2"
        File = "libxml2-v2.14.1.tar.gz"
        URL = "https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.14.1/libxml2-v2.14.1.tar.gz"
        Description = "libxml2 v2.14.1"
        Platform = "Both"
    },
    
    # libxslt
    @{
        Name = "libxslt"
        File = "libxslt-v1.1.43.tar.gz"
        URL = "https://gitlab.gnome.org/GNOME/libxslt/-/archive/v1.1.43/libxslt-v1.1.43.tar.gz"
        Description = "libxslt v1.1.43"
        Platform = "Both"
    },
    
    # nlopt
    @{
        Name = "nlopt"
        File = "nlopt-2.10.0.tar.gz"
        URL = "https://github.com/stevengj/nlopt/archive/v2.10.0.tar.gz"
        Description = "NLopt 2.10.0"
        Platform = "Both"
    },
    
    # ode
    @{
        Name = "ode"
        File = "ode-0.16.6.tar.gz"
        URL = "https://bitbucket.org/odedevs/ode/downloads/ode-0.16.6.tar.gz"
        Description = "ODE (Open Dynamics Engine) 0.16.6"
        Platform = "Both"
    },
    
    # pqp
    @{
        Name = "pqp"
        File = "PQP-713de5b70dd1849b915f6412330078a9814e01ab.tar.gz"
        URL = "https://github.com/GammaUNC/PQP/archive/713de5b70dd1849b915f6412330078a9814e01ab.tar.gz"
        Description = "PQP"
        Platform = "Both"
    },
    
    # simage
    @{
        Name = "simage"
        File = "simage-1.8.3-src.tar.gz"
        URL = "https://github.com/coin3d/simage/releases/download/v1.8.3/simage-1.8.3-src.tar.gz"
        Description = "simage 1.8.3"
        Platform = "Both"
    },
    
    # solid3
    @{
        Name = "solid"
        File = "solid3-cbac1402da5df65e7239558a6c04feb736e54b27.zip"
        URL = "https://github.com/dtecta/solid3/archive/cbac1402da5df65e7239558a6c04feb736e54b27.zip"
        Description = "SOLID3"
        Platform = "Both"
    },
    
    # soqt
    @{
        Name = "soqt"
        File = "soqt-1.6.3-src.tar.gz"
        URL = "https://github.com/coin3d/soqt/releases/download/v1.6.3/soqt-1.6.3-src.tar.gz"
        Description = "SoQt 1.6.3"
        Platform = "Both"
    },
    
    # superglu
    @{
        Name = "superglu"
        File = "superglu-1.3.2-src.tar.gz"
        URL = "https://github.com/coin3d/superglu/releases/download/v1.3.2/superglu-1.3.2-src.tar.gz"
        Description = "SuperGLU 1.3.2"
        Platform = "Both"
    }
)

$SuccessCount = 0
$FailedCount = 0
$DownloadedCount = 0

foreach ($item in $Downloads) {
    $filePath = Join-Path (Join-Path $DownloadsDir $item.Name) $item.File
    
    # Always download - remove skip logic
    Write-Host "[DOWNLOAD] $($item.Description) ($($item.Platform))..." -ForegroundColor Cyan
    Write-Host "  URL: $($item.URL)" -ForegroundColor Gray
    Write-Host "  File: $($item.File)" -ForegroundColor Gray
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $item.URL -OutFile $filePath -ErrorAction Stop
        
        if (Test-Path $filePath) {
            $fileSize = (Get-Item $filePath).Length / 1MB
            $fileSizeMB = [math]::Round($fileSize, 2)
            Write-Host "  [OK] Downloaded: $($item.File) ($fileSizeMB MB)" -ForegroundColor Green
            $SuccessCount++
            $DownloadedCount++
        } else {
            throw "File not found after download"
        }
    } catch {
        Write-Host "  [FAILED] $($_.Exception.Message)" -ForegroundColor Red
        $FailedCount++
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Download Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Downloaded: $DownloadedCount" -ForegroundColor Green
Write-Host "  Success: $SuccessCount" -ForegroundColor Green
Write-Host "  Failed:  $FailedCount" -ForegroundColor $(if ($FailedCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($FailedCount -gt 0) {
    Write-Host "NOTE: Some downloads failed. URLs are sourced from CMakeLists.txt files." -ForegroundColor Yellow
    Write-Host "      Please verify the URLs are accessible and check your network connection." -ForegroundColor Yellow
    exit 1
}

Write-Host 'All downloads completed successfully!' -ForegroundColor Green
