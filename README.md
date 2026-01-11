# 3rdparty Dependencies Build Guide

This directory contains CMake scripts to build all third-party dependencies required by the Robotics Library (RL).

## Overview

The `3rdparty` directory uses CMake's `ExternalProject` module to automatically download, configure, build, and install the following dependencies:

### Core Dependencies
- **Boost** (headers only) - C++ libraries
- **Eigen3** - Linear algebra library
- **libiconv** - Character encoding conversion
- **libxml2** - XML parsing library
- **libxslt** - XSLT transformation library
- **zlib** - Compression library

### Collision Detection Libraries
- **Bullet Physics** - Physics simulation and collision detection
- **Coin3D** - 3D graphics library (Open Inventor)
- **SoQt** - Qt integration for Coin3D
- **simage** - Image loading library (for Coin3D)
- **ODE** - Open Dynamics Engine
- **PQP** - Proximity Query Package
- **SOLID3** - Collision detection library

### Optional Dependencies
- **NLopt** - Nonlinear optimization library
- **ATIDAQ** - Force/torque sensor library

### Windows-Specific
- **patch.exe** - GNU patch utility (required for applying patches during build)

## Quick Start

### Option 1: Automatic Build (Recommended)

Dependencies are **automatically built** when you configure the main RL project. No separate build step is needed!

```powershell
# Windows
cd C:\Tools\RoboticLibrary\rl-0.7.0
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
```

```bash
# Linux/WSL
cd /path/to/rl-0.7.0
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel
```

### Option 2: Pre-build Dependencies Separately

If you want to build dependencies separately (useful for troubleshooting or reusing builds):

#### Windows (PowerShell)

```powershell
cd C:\Tools\RoboticLibrary\rl-0.7.0\3rdparty

# Use the provided script
.\build-3rdparty.ps1

# Or manually:
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_INSTALL_PREFIX="C:/Tools/RoboticLibrary/3rdparty/install"
cmake --build . --config Release --parallel
cmake --build . --config Release --target install
```

#### Linux/WSL (Bash)

```bash
cd /path/to/rl-0.7.0/3rdparty

# Make script executable (first time only)
chmod +x build-3rdparty.sh

# Use the provided script
./build-3rdparty.sh

# Or manually:
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PWD/../install"
cmake --build . --parallel $(nproc)
cmake --build . --target install
```

## Build Script Options

### Windows (`build-3rdparty.ps1`)

```powershell
.\build-3rdparty.ps1 `
  -InstallPrefix "C:/path/to/install" `
  -VisualStudioVersion "17" `
  -Architecture "x64" `
  -Config "Release" `
  -ParallelJobs 8 `
  -SkipBuild `
  -SkipInstall
```

**Parameters:**
- `-InstallPrefix`: Installation directory (default: `.\install`)
- `-VisualStudioVersion`: VS version - "17" (2022), "16" (2019), "15" (2017)
- `-Architecture`: "x64" or "x86" (default: "x64")
- `-Config`: Build configuration - "Release", "Debug", "RelWithDebInfo", "MinSizeRel"
- `-ParallelJobs`: Number of parallel build jobs (0 = all cores, default: 0)
- `-SkipBuild`: Only configure, don't build
- `-SkipInstall`: Build but don't install

### Linux (`build-3rdparty.sh`)

```bash
./build-3rdparty.sh \
  --install-prefix /path/to/install \
  --build-type Release \
  --jobs 8 \
  --skip-build \
  --skip-install
```

**Options:**
- `--install-prefix`: Installation directory (default: `./install`)
- `--build-type`: Build type - "Release", "Debug", "RelWithDebInfo", "MinSizeRel"
- `--jobs`: Number of parallel build jobs (default: all available cores)
- `--skip-build`: Only configure, don't build
- `--skip-install`: Build but don't install

## Using Pre-built Dependencies

After building dependencies separately, configure the main RL project to use them:

### Windows

```powershell
cd C:\Tools\RoboticLibrary\rl-0.7.0
mkdir build
cd build

# Set CMAKE_PREFIX_PATH to point to your install directory
cmake .. -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_PREFIX_PATH="C:/Tools/RoboticLibrary/rl-0.7.0/3rdparty/install"
```

### Linux

```bash
cd /path/to/rl-0.7.0
mkdir build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="/path/to/rl-0.7.0/3rdparty/install"
```

## Build Output Locations

### Windows

- **Build artifacts**: `3rdparty/build/<dependency>/<dependency>-prefix/src/<dependency>-build/`
- **Installed files**: `3rdparty/install/` (or your custom install prefix)
  - Headers: `install/include/`
  - Libraries: `install/lib/`
  - Binaries: `install/bin/`

### Linux

- **Build artifacts**: `3rdparty/build/<dependency>/<dependency>-prefix/src/<dependency>-build/`
- **Installed files**: `3rdparty/install/` (or your custom install prefix)
  - Headers: `install/include/`
  - Libraries: `install/lib/`
  - Binaries: `install/bin/`

## Requirements

- **CMake**: Version 3.24 or later (required for CMP0135 policy)
- **C++ Compiler**: 
  - Windows: Visual Studio 2017 or later (MSVC)
  - Linux: GCC 4.8+ or Clang 3.3+
- **Build Tools**:
  - Windows: Visual Studio with C++ workload
  - Linux: `build-essential` package (GCC, make, etc.)
- **Internet Connection**: Required for downloading source packages
- **Disk Space**: ~2-3 GB for all dependencies

## Build Time

Expect **30-60 minutes** for a full build of all dependencies, depending on:
- CPU speed and number of cores
- Disk I/O speed
- Internet connection speed (for downloads)

## Troubleshooting

### CMake Version Error

If you see: `CMake 3.24 or later is required`

**Solution**: Upgrade CMake to version 3.24 or later.

### Download Failures

If downloads fail, check:
1. Internet connection
2. Firewall/proxy settings
3. SourceForge/GitHub availability

Some dependencies can use local archives if placed in `3rdparty/downloads/`.

### Build Failures

1. **Check compiler**: Ensure your compiler is properly installed and in PATH
2. **Check dependencies**: Some dependencies require others to be built first
3. **Clean build**: Try deleting the `build` directory and rebuilding
4. **Check logs**: Look in `build/<dependency>/<dependency>-prefix/src/<dependency>-stamp/` for error logs

### Windows: patch.exe Manifest

The `patch.exe.manifest` file is automatically copied to the build directory to set the execution level. If you see manifest-related errors, ensure the manifest file exists in the source directory.

## Advanced Usage

### Building Specific Dependencies

You can build individual dependencies:

```powershell
# Windows
cmake --build . --config Release --target bullet

# Linux
cmake --build . --target bullet
```

### Custom CMake Options

You can pass custom CMake options to individual dependencies by modifying their `CMakeLists.txt` files in the respective subdirectories.

### Packaging Dependencies

The `3rdparty/CMakeLists.txt` includes CPack configuration for creating installers:

```powershell
# Windows
cmake --build . --config Release --target package

# Linux
cmake --build . --target package
```

This creates platform-specific packages (NSIS installer on Windows, DEB/RPM on Linux).

## Integration with Main RL Build

The main RL project automatically detects and uses dependencies from:
1. System-installed packages (Linux)
2. `CMAKE_PREFIX_PATH` directories
3. Standard installation locations
4. The `3rdparty` build directory (if built as part of main project)

The Find modules in `cmake/` directory handle dependency detection automatically.

## See Also

- Main RL Build Guide: `../.cursor/BUILD_GUIDE.md`
- Individual dependency build instructions in subdirectories (e.g., `bullet/build_instruction.md`)
