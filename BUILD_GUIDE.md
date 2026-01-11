# Robotics Library (RL) Build Guide

## Overview

The Robotics Library (RL) is a self-contained C++ library for robot kinematics, visualization, motion planning, and control. This guide provides detailed instructions on how to build the project and generate all required libraries.

## Library Structure

The RL project consists of the following core libraries:

### Core Libraries

1. **rlplan** (`rlplan.dll` / `librlplan.so`) - Path planning component
   - Depends on: kin, math, mdl, sg, util, xml
   - Source: `src/rl/plan/`

2. **rlkin** (`rlkin.dll` / `librlkin.so`) - Denavit-Hartenberg kinematics component
   - Depends on: math, xml
   - Source: `src/rl/kin/`

3. **rlsg** (`rlsg.dll` / `librlsg.so`) - Scene graph abstraction component
   - Depends on: math, util, xml
   - Optional collision detection backends: Bullet, CCD+FCL, ODE, PQP, SOLID3
   - Source: `src/rl/sg/`

4. **rlmdl** (`rlmdl.dll` / `librlmdl.so`) - Rigid body kinematics and dynamics component
   - Depends on: math, xml
   - Optional: NLopt (for inverse kinematics)
   - Source: `src/rl/mdl/`

5. **rlmath** (`rlmath.dll` / `librlmath.so`) - Mathematics component (header-only/interface library)
   - Depends on: Boost, Eigen3
   - Source: `src/rl/math/`

6. **rlutil** (`rlutil.dll` / `librlutil.so`) - Utility component (header-only/interface library)
   - Depends on: Threads
   - Optional: RTAI, Xenomai
   - Source: `src/rl/util/`

7. **rlxml** (`rlxml.dll` / `librlxml.so`) - XML abstraction layer component (header-only/interface library)
   - Depends on: Boost, libxml2, libxslt
   - Optional: libiconv, zlib
   - Source: `src/rl/xml/`

8. **rlhal** (`rlhal.dll` / `librlhal.so`) - Hardware abstraction layer component
   - Depends on: math, util
   - Optional: ATIDAQ, cifX, Comedi, libdc1394
   - Source: `src/rl/hal/`

## Dependency Installation Guide

**IMPORTANT:** The Robotics Library build system supports two dependency strategies:

1. **System Packages** (Recommended for Linux/WSL 2): Use pre-installed system packages
2. **Bundled Dependencies** (Default for Windows): Automatically download and build dependencies from source

The build system will automatically detect available dependencies and use bundled ones if system packages are not found. Choose your platform below for detailed installation instructions.

---

## Windows Dependency Installation (Visual Studio 2022)

### Overview

On Windows, dependencies are **automatically built from source** during the CMake configuration step. The `3rdparty/` directory contains ExternalProject configurations that download and compile all required dependencies.

### Required Tools

1. **Visual Studio 2022** (or Visual Studio Build Tools 2022)
   - **Installation:** Download from [Visual Studio Downloads](https://visualstudio.microsoft.com/downloads/)
   - **Required Workloads:**
     - ✅ Desktop development with C++
     - ✅ CMake tools for Windows (optional but recommended)
   - **Required Components:**
     - MSVC v143 - VS 2022 C++ x64/x86 build tools
     - Windows 10/11 SDK (latest version)
     - CMake tools for Visual Studio

2. **CMake** (3.0+ recommended)
   - **Download:** [CMake Downloads](https://cmake.org/download/)
   - **Installation:** Use the Windows installer and select "Add CMake to system PATH"
   - **Verify:** Open PowerShell and run `cmake --version`

3. **Git** (for cloning repository if needed)
   - **Download:** [Git for Windows](https://git-scm.com/download/win)
   - **Installation:** Use default settings, ensure "Git Bash Here" is enabled

### Dependency Strategy for Windows

**Windows uses bundled dependencies by default.** When you run CMake, it will:

1. Check for system-installed dependencies (uncommon on Windows)
2. If not found, automatically download and build from `3rdparty/` directory:
   - Boost (headers only, downloaded from bintray)
   - Bullet Physics (downloaded from source)
   - Coin3D (downloaded from Bitbucket)
   - Eigen3 (downloaded from source)
   - libiconv (built from source)
   - libxml2 (built from source)
   - libxslt (built from source)
   - NLopt (built from source)
   - ODE (built from source)
   - PQP (built from source)
   - simage (built from source)
   - SOLID3 (built from source)
   - SoQt (downloaded from Bitbucket)
   - zlib (built from source)

### Optional: Pre-building Dependencies (Advanced)

If you want to build dependencies separately before building the main project:

```powershell
# Navigate to 3rdparty directory
cd C:\Tools\RoboticLibrary\rl-0.7.0\3rdparty

# Create build directory
mkdir build
cd build

# Configure (this will download dependencies)
cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_POLICY_VERSION_MINIMUM="3.20" -DCMAKE_INSTALL_PREFIX="C:/Tools/RoboticLibrary/3rdparty/install"

# Build all dependencies (this may take 30-60 minutes)
cmake --build . --config Release --parallel

# Install dependencies (optional)
cmake --build . --config Release --target install
```

**Note:** This is usually not necessary as dependencies are built automatically during the main project configuration.

### Qt5 Installation (Required for Demos)

For building GUI demos like `rlPlanDemo`, you need Qt5:

1. **Download Qt5:**
   - Visit [Qt Downloads](https://www.qt.io/download-open-source)
   - Download Qt Online Installer for Windows
   - **Required Components:**
     - Qt 5.15.x or Qt 6.x (latest stable)
     - MSVC 2019 64-bit (for VS 2022 compatibility)
     - Qt Creator (optional but recommended)

2. **Set Qt5_DIR:**
   ```powershell
   # Example: If Qt is installed to C:\Qt\5.15.2\msvc2019_64
   $env:Qt5_DIR = "C:\Qt\5.15.2\msvc2019_64\lib\cmake\Qt5"
   ```

3. **Verify Qt Installation:**
   ```powershell
   cmake --find-package -DNAME=Qt5 -DCOMPILER_ID=MSVC -DLANGUAGE=CXX -DMODE=COMPILE
   ```

---

## Native Linux Dependency Installation

### Overview

On native Linux, **system packages are preferred** and should be installed before building. The build system will use bundled dependencies only if system packages are not found.

### Step 1: Install Build Tools

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  git \
  pkg-config
```

**Fedora/RHEL/CentOS:**
```bash
sudo dnf install -y \
  gcc-c++ \
  cmake \
  git \
  pkgconfig
```

**Arch Linux:**
```bash
sudo pacman -S \
  base-devel \
  cmake \
  git \
  pkgconf
```

### Step 2: Install Required Dependencies

**Ubuntu/Debian (Ubuntu 20.04+ / Debian 11+):**
```bash
sudo apt-get install -y \
  libboost-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libboost-filesystem-dev \
  libeigen3-dev \
  libxml2-dev \
  libxslt1-dev \
  libcoin80-dev \
  libsoqt80-dev \
  qtbase5-dev \
  libqt5opengl5-dev \
  libgl1-mesa-dev \
  xorg-dev
```

**Ubuntu 18.04 (older versions):**
```bash
sudo apt-get install -y \
  libboost-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libboost-filesystem-dev \
  libeigen3-dev \
  libxml2-dev \
  libxslt1-dev \
  libcoin80-dev \
  libsoqt80-dev \
  qtbase5-dev \
  libqt5opengl5-dev \
  libgl1-mesa-dev \
  xorg-dev
```

**Fedora/RHEL/CentOS:**
```bash
sudo dnf install -y \
  boost-devel \
  eigen3-devel \
  libxml2-devel \
  libxslt-devel \
  Coin3-devel \
  SoQt-devel \
  qt5-qtbase-devel \
  qt5-qtbase-opengl \
  mesa-libGL-devel \
  libX11-devel
```

**Arch Linux:**
```bash
sudo pacman -S \
  boost \
  eigen \
  libxml2 \
  libxslt \
  coin \
  soqt \
  qt5-base \
  qt5-base-devel \
  mesa \
  libx11
```

### Step 3: Install Optional Dependencies

**For collision detection backends (optional):**

**Ubuntu/Debian:**
```bash
sudo apt-get install -y \
  libbullet-dev \
  libfcl-dev \
  libccd-dev \
  libode-dev \
  libnlopt-dev
```

**Fedora/RHEL:**
```bash
sudo dnf install -y \
  bullet-devel \
  fcl-devel \
  libccd-devel \
  ode-devel \
  nlopt-devel
```

**Arch Linux:**
```bash
sudo pacman -S \
  bullet \
  fcl \
  ccd \
  ode \
  nlopt
```

### Step 4: Verify Dependencies

Verify all dependencies are installed:

```bash
# Check CMake
cmake --version

# Check compiler
g++ --version

# Check Boost
pkg-config --modversion boost

# Check Eigen3
pkg-config --modversion eigen3

# Check Qt5
qmake --version

# Check Coin3D
pkg-config --modversion coin
```

### Step 5: Using Bundled Dependencies (Fallback)

If system packages are not available or you prefer bundled dependencies:

```bash
# Build bundled dependencies first
cd 3rdparty
mkdir build
cd build
cmake ..
cmake --build . --parallel $(nproc)

# Then configure main project to use bundled dependencies
cd ../../build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON
```

---

## WSL 2 Dependency Installation

### Overview

WSL 2 uses the **same dependency installation as native Linux**, but with some important considerations.

### Step 1: Verify WSL 2 Setup

**In Windows PowerShell (as Administrator):**
```powershell
# Check WSL version
wsl --list --verbose

# Ensure WSL 2 is default
wsl --set-default-version 2

# If needed, convert existing distro to WSL 2
wsl --set-version Ubuntu 2
```

### Step 2: Update WSL 2 System

**In WSL 2 terminal:**
```bash
# Update package lists
sudo apt-get update
sudo apt-get upgrade -y
```

### Step 3: Install Build Tools

**Same as Native Linux (Ubuntu/Debian):**
```bash
sudo apt-get install -y \
  build-essential \
  cmake \
  git \
  pkg-config
```

### Step 4: Install Required Dependencies

**Same as Native Linux (Ubuntu/Debian):**
```bash
sudo apt-get install -y \
  libboost-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libboost-filesystem-dev \
  libeigen3-dev \
  libxml2-dev \
  libxslt1-dev \
  libcoin80-dev \
  libsoqt80-dev \
  qtbase5-dev \
  libqt5opengl5-dev \
  libgl1-mesa-dev \
  xorg-dev
```

### Step 5: WSL 2 Specific Considerations

**GUI Support (Windows 11 with WSLg):**
- WSLg is automatically enabled on Windows 11
- No additional configuration needed
- Test with: `xeyes` or `xclock` (install with `sudo apt-get install x11-apps`)

**GUI Support (Windows 10 without WSLg):**
- Install X11 server on Windows: [VcXsrv](https://sourceforge.net/projects/vcxsrv/) or [X410](https://www.microsoft.com/store/p/x410/9nlp712zmn9q)
- Set DISPLAY variable in WSL 2:
  ```bash
  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
  ```
- Add to `~/.bashrc` or `~/.zshrc` to make it permanent:
  ```bash
  echo 'export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '\''{print $2}'\''):0.0' >> ~/.bashrc
  ```

**Performance Optimization:**
- **IMPORTANT:** Build on Linux filesystem (`~/`) not Windows filesystem (`/mnt/c/`)
- Copy project to Linux filesystem for faster builds:
  ```bash
  cp -r /mnt/c/Tools/RoboticLibrary/rl-0.7.0 ~/rl-0.7.0
  cd ~/rl-0.7.0
  ```

### Step 6: Verify Dependencies (Same as Native Linux)

```bash
# Check all dependencies
cmake --version
g++ --version
pkg-config --modversion boost
pkg-config --modversion eigen3
qmake --version
```

---

## Dependency Summary Table

| Dependency | Windows | Native Linux | WSL 2 | Notes |
|------------|---------|--------------|-------|-------|
| **CMake** | Manual install | Package manager | Package manager | >= 2.8.11, 3.0+ recommended |
| **Compiler** | VS 2022 included | g++/clang | g++/clang | C++11 support required |
| **Boost** | Auto-built | `libboost-dev` | `libboost-dev` | >= 1.46, headers+regex+system+thread |
| **Eigen3** | Auto-built | `libeigen3-dev` | `libeigen3-dev` | Required for math component |
| **libxml2** | Auto-built | `libxml2-dev` | `libxml2-dev` | Required for XML component |
| **libxslt** | Auto-built | `libxslt1-dev` | `libxslt1-dev` | Required for XML component |
| **Coin3D** | Auto-built | `libcoin80-dev` | `libcoin80-dev` | Required for scene graph |
| **SoQt** | Auto-built | `libsoqt80-dev` | `libsoqt80-dev` | Coin3D Qt integration |
| **Qt5** | Manual install | `qtbase5-dev` | `qtbase5-dev` | Required for GUI demos |
| **OpenGL** | VS included | `libgl1-mesa-dev` | `libgl1-mesa-dev` | For visualization |
| **Bullet** | Auto-built | `libbullet-dev` | `libbullet-dev` | Optional collision backend |
| **NLopt** | Auto-built | `libnlopt-dev` | `libnlopt-dev` | Optional for inverse kinematics |

---

## Troubleshooting Dependency Issues

### Windows

1. **CMake can't find Visual Studio:**
   ```powershell
   # List available generators
   cmake --help
   
   # Use specific generator
   cmake .. -G "Visual Studio 17 2022" -A x64
   ```

2. **Dependencies fail to download:**
   - Check internet connection
   - Some URLs may be outdated; check `3rdparty/*/CMakeLists.txt` for updated URLs
   - Consider using system-installed dependencies if available

3. **Qt5 not found:**
   - Install Qt5 manually and set `Qt5_DIR` environment variable
   - Or disable demos: `-DBUILD_DEMOS=OFF`

### Linux/WSL 2

1. **Package not found:**
   ```bash
   # Update package lists
   sudo apt-get update  # Ubuntu/Debian
   sudo dnf check-update  # Fedora/RHEL
   ```

2. **Version conflicts:**
   - Use bundled dependencies: Build from `3rdparty/` directory
   - Or specify custom paths: `-DBoost_ROOT=/path/to/boost`

3. **Permission errors:**
   - Use `sudo` for system-wide installation
   - Or install to user directory: `-DCMAKE_INSTALL_PREFIX=~/local`

4. **Missing development packages:**
   - Ensure `-dev` or `-devel` packages are installed (not just runtime)
   - Example: `libxml2-dev` not just `libxml2`

## Build Configuration Options

### Main CMake Options

| Option | Default | Description |
|--------|---------|-------------|
| `BUILD_SHARED_LIBS` | ON (Linux), OFF (Windows) | Build shared libraries (.dll/.so) vs static libraries (.lib/.a) |
| `BUILD_DEMOS` | ON | Build demo applications |
| `BUILD_TESTS` | ON | Build test programs |
| `BUILD_EXTRAS` | ON | Build extra utilities |
| `BUILD_DOCUMENTATION` | OFF | Build documentation (Doxygen) |
| `USE_QT5` | ON | Prefer Qt5 over Qt4 |

### Component Options

| Option | Default | Description |
|--------|---------|-------------|
| `BUILD_RL_MATH` | ON | Build mathematics component |
| `BUILD_RL_UTIL` | ON | Build utility component |
| `BUILD_RL_XML` | ON | Build XML abstraction layer |
| `BUILD_RL_KIN` | ON | Build kinematics component (requires: math, xml) |
| `BUILD_RL_MDL` | ON | Build rigid body dynamics component (requires: math, xml) |
| `BUILD_RL_HAL` | ON | Build hardware abstraction layer (requires: math, util) |
| `BUILD_RL_SG` | ON | Build scene graph component (requires: math, util, xml) |
| `BUILD_RL_PLAN` | ON | Build path planning component (requires: kin, math, mdl, sg, util, xml) |

## Build Instructions

### Windows (MSVC) - Visual Studio 2022

#### Prerequisites

**Before building, ensure you have completed the [Windows Dependency Installation](#windows-dependency-installation-visual-studio-2022) section above.**

1. ✅ **Visual Studio 2022** installed with C++ workload
2. ✅ **CMake** (3.0+) installed and in PATH
3. ✅ **Git** installed (if cloning repository)
4. ✅ **Qt5** installed (if building demos)

#### Step-by-Step Build

1. **Open Developer Command Prompt for VS 2022:**
   - Press `Win + R`, type `cmd`, press Enter
   - Or open "x64 Native Tools Command Prompt for VS 2022" from Start Menu
   - Or use PowerShell and run: `& "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"`

2. **Navigate to project directory:**
   ```powershell
   cd C:\Tools\RoboticLibrary\rl-0.7.0
   ```

3. **Create build directory:**
   ```powershell
   mkdir build
   cd build
   ```

4. **Configure with CMake (Visual Studio 2022):**
   ```powershell
   cmake .. -G "Visual Studio 17 2022" -A x64 `
     -DBUILD_SHARED_LIBS=ON `
     -DCMAKE_INSTALL_PREFIX=C:\RL\install
   ```
   
   **For Visual Studio 2022, use:** `-G "Visual Studio 17 2022"`
   
   **For other Visual Studio versions:**
   - VS 2015: `-G "Visual Studio 14 2015"`
   - VS 2017: `-G "Visual Studio 15 2017"`
   - VS 2019: `-G "Visual Studio 16 2019"`
   - VS 2026 (Insider): `-G "Visual Studio 19 2026"` (verify with `cmake --help`)
   
   **For 32-bit builds:** Use `-A Win32` instead of `-A x64`
   
   **Note:** During configuration, CMake will automatically download and build dependencies from the `3rdparty/` directory. This may take 30-60 minutes on first run. Subsequent builds will be faster.

5. **Build the project:**
   ```powershell
   cmake --build . --config Release --parallel
   ```
   
   Or open the generated `rl.sln` file in Visual Studio 2022 and build from there.
   
   **Build time:** Expect 10-30 minutes depending on your system.

6. **Install libraries:**
   ```powershell
   cmake --build . --config Release --target install
   ```

4. **Build the project:**
   ```powershell
   cmake --build . --config Release --parallel
   ```
   
   Or open the generated `.sln` file in Visual Studio and build from there.

5. **Install libraries:**
   ```powershell
   cmake --build . --config Release --target install
   ```

#### Output Locations (Windows)

When `BUILD_SHARED_LIBS=ON`:
- **Debug libraries:** `build/src/rl/<component>/Debug/rl<component>d.dll`
- **Release libraries:** `build/src/rl/<component>/Release/rl<component>.dll`
- **Import libraries:** `build/src/rl/<component>/Release/rl<component>.lib`

When `BUILD_SHARED_LIBS=OFF`:
- **Debug libraries:** `build/src/rl/<component>/Debug/rl<component>sd.lib`
- **Release libraries:** `build/src/rl/<component>/Release/rl<component>s.lib`

After install:
- **DLLs:** `<install_prefix>/bin/rl<component>.dll`
- **LIBs:** `<install_prefix>/lib/rl<component>.lib`
- **Headers:** `<install_prefix>/include/rl-0.7.0/rl/<component>/`

### Linux

The Linux build process differs significantly between **Native Linux** and **WSL 2 (Windows Subsystem for Linux)**. Choose the appropriate section below based on your environment.

---

## Native Linux Build

**Use this section if you are building on a native Linux installation (not WSL 2).**

### Prerequisites

**Before building, ensure you have completed the [Native Linux Dependency Installation](#native-linux-dependency-installation) section above.**

Install required system packages (if not already installed):

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  libboost-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libeigen3-dev \
  libxml2-dev \
  libxslt1-dev \
  libcoin80-dev \
  libsoqt80-dev \
  qtbase5-dev \
  libqt5opengl5-dev \
  xorg-dev
```

**Fedora/RHEL:**
```bash
sudo dnf install -y \
  gcc-c++ \
  cmake \
  boost-devel \
  eigen3-devel \
  libxml2-devel \
  libxslt-devel \
  Coin3-devel \
  SoQt-devel \
  qt5-qtbase-devel \
  qt5-qtbase-opengl \
  libX11-devel
```

### Step-by-Step Build

1. **Create build directory:**
   ```bash
   cd /path/to/rl-0.7.0
   mkdir build
   cd build
   ```

2. **Configure with CMake:**
   ```bash
   cmake .. \
     -DCMAKE_BUILD_TYPE=Release \
     -DBUILD_SHARED_LIBS=ON \
     -DCMAKE_INSTALL_PREFIX=/usr/local
   ```

3. **Build the project:**
   ```bash
   cmake --build . --parallel $(nproc)
   ```

4. **Run tests (optional):**
   ```bash
   ctest --output-on-failure
   ```

5. **Install libraries:**
   ```bash
   sudo cmake --build . --target install
   ```

### Output Locations (Native Linux)

When `BUILD_SHARED_LIBS=ON`:
- **Libraries:** `build/src/rl/<component>/librl<component>.so.0.7.0`
- **Symlinks:** `build/src/rl/<component>/librl<component>.so` (versioned)

After install:
- **Libraries:** `<install_prefix>/lib/librl<component>.so.0.7.0`
- **Headers:** `<install_prefix>/include/rl-0.7.0/rl/<component>/`

---

## WSL 2 Build

**Use this section if you are building on Windows Subsystem for Linux 2 (WSL 2).**

### Prerequisites

**Before building, ensure you have completed the [WSL 2 Dependency Installation](#wsl-2-dependency-installation) section above.**

### ⚠️ Important Differences from Native Linux

**Key differences when building in WSL 2:**

1. **File System Access:**
   - Windows drives are mounted at `/mnt/c/`, `/mnt/d/`, etc.
   - Use Linux-style paths (`/mnt/c/Tools/...`) instead of Windows paths
   - **Performance:** Building on the Windows filesystem (`/mnt/c/`) is slower. Consider copying the project to the Linux filesystem (`~/` or `/home/`) for better performance.

2. **GUI Applications:**
   - Requires **WSLg** (Windows 11) or **X11 forwarding** (Windows 10)
   - Qt-based demos (like `rlPlanDemo`) need proper display configuration
   - OpenGL applications may have limited support depending on GPU passthrough

3. **Hardware Access:**
   - Some hardware abstraction features (HAL) may not work in WSL 2
   - USB device access requires additional configuration

4. **Performance:**
   - Build times may be slower than native Linux
   - I/O operations on Windows filesystem are slower

**Note:** Dependencies should already be installed from the [WSL 2 Dependency Installation](#wsl-2-dependency-installation) section. If not, refer to that section for installation commands.

### Step-by-Step Build (WSL 2)

**Option A: Build on Linux Filesystem (Recommended for Performance)**

1. **Copy project to Linux filesystem (if needed):**
   ```bash
   # If project is on Windows drive, copy to Linux filesystem
   cp -r /mnt/c/Tools/RoboticLibrary/rl-0.7.0 ~/rl-0.7.0
   cd ~/rl-0.7.0
   ```

2. **Create build directory:**
   ```bash
   mkdir build
   cd build
   ```

3. **Configure with CMake:**
   ```bash
   cmake .. \
     -DCMAKE_BUILD_TYPE=Release \
     -DBUILD_SHARED_LIBS=ON \
     -DCMAKE_INSTALL_PREFIX=/usr/local
   ```

4. **Build the project:**
   ```bash
   cmake --build . --parallel $(nproc)
   ```

5. **Install libraries:**
   ```bash
   sudo cmake --build . --target install
   ```

**Option B: Build on Windows Filesystem (Slower but Convenient)**

1. **Navigate to Windows filesystem:**
   ```bash
   cd /mnt/c/Tools/RoboticLibrary/rl-0.7.0
   mkdir build
   cd build
   ```

2. **Configure with CMake:**
   ```bash
   cmake .. \
     -DCMAKE_BUILD_TYPE=Release \
     -DBUILD_SHARED_LIBS=ON \
     -DCMAKE_INSTALL_PREFIX=/usr/local
   ```

3. **Build the project:**
   ```bash
   cmake --build . --parallel $(nproc)
   ```

   **Note:** Building on `/mnt/c/` will be significantly slower. Consider Option A for better performance.

### GUI Applications in WSL 2

**For Windows 11 with WSLg:**
- GUI applications should work automatically
- No additional configuration needed
- Test with: `xeyes` or `xclock` (if installed)

**For Windows 10 (without WSLg):**
- Install an X11 server on Windows (e.g., VcXsrv, X410)
- Set DISPLAY variable:
  ```bash
  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
  ```
- Start X11 server on Windows before running GUI applications

### Output Locations (WSL 2)

**When building on Linux filesystem (`~/rl-0.7.0`):**
- **Libraries:** `~/rl-0.7.0/build/src/rl/<component>/librl<component>.so.0.7.0`
- Same as native Linux

**When building on Windows filesystem (`/mnt/c/...`):**
- **Libraries:** `/mnt/c/Tools/RoboticLibrary/rl-0.7.0/build/src/rl/<component>/librl<component>.so.0.7.0`
- Accessible from both Windows and WSL 2

**After install:**
- **Libraries:** `/usr/local/lib/librl<component>.so.0.7.0` (WSL 2 filesystem)
- **Headers:** `/usr/local/include/rl-0.7.0/rl/<component>/`

### WSL 2 Specific Troubleshooting

1. **Slow build times:**
   - Move project to Linux filesystem (`~/` instead of `/mnt/c/`)
   - Use `--parallel $(nproc)` to utilize all CPU cores

2. **GUI applications don't display:**
   - Check WSLg status: `echo $DISPLAY` (should be set automatically on Windows 11)
   - For Windows 10, ensure X11 server is running and DISPLAY is set correctly

3. **Permission errors:**
   - Avoid building in `/mnt/c/` root directories
   - Use user's home directory or `/tmp/` for builds

4. **Library not found at runtime:**
   - Ensure libraries are in `/usr/local/lib` or set `LD_LIBRARY_PATH`
   - Run `ldconfig` after installing: `sudo ldconfig`

---

### Summary: Native Linux vs WSL 2

| Aspect | Native Linux | WSL 2 |
|--------|--------------|-------|
| **File System** | Native Linux filesystem | Windows filesystem (`/mnt/c/`) or Linux filesystem (`~/`) |
| **Performance** | Optimal | Slower, especially on Windows filesystem |
| **GUI Support** | Native X11/Wayland | WSLg (Win11) or X11 forwarding (Win10) |
| **Hardware Access** | Full access | Limited (USB requires extra config) |
| **Build Location** | Anywhere | Prefer Linux filesystem for speed |
| **Path Format** | `/path/to/project` | `/mnt/c/path/to/project` or `~/path/to/project` |

## Library Naming Conventions

### Windows

**Shared Libraries (BUILD_SHARED_LIBS=ON):**
- Release: `rl<component>.dll`, `rl<component>.lib`
- Debug: `rl<component>d.dll`, `rl<component>d.lib`

**Static Libraries (BUILD_SHARED_LIBS=OFF):**
- Release: `rl<component>s.lib`
- Debug: `rl<component>sd.lib`
- MinSizeRel: `rl<component>s.lib`
- RelWithDebInfo: `rl<component>s.lib`

### Linux

**Shared Libraries:**
- `librl<component>.so.0.7.0` (full version)
- `librl<component>.so.0` (major version symlink)
- `librl<component>.so` (unversioned symlink)

**Static Libraries:**
- `librl<component>.a`

## Building Third-Party Dependencies Separately

**Note:** This section is usually not needed. Dependencies are automatically built during the main project configuration. Only use this if you want to pre-build dependencies or troubleshoot dependency issues.

### Windows

```powershell
cd C:\Tools\RoboticLibrary\rl-0.7.0\3rdparty
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release --parallel
```

### Linux/WSL 2

```bash
cd /path/to/rl-0.7.0/3rdparty
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel $(nproc)
```

This will download and build all third-party dependencies automatically. After building, configure the main project to use these pre-built dependencies.

## Advanced Configuration

### Custom Dependency Paths

If dependencies are installed in non-standard locations:

```bash
cmake .. \
  -DBoost_ROOT=/path/to/boost \
  -DEigen3_DIR=/path/to/eigen3/share/eigen3/cmake \
  -DCoin_DIR=/path/to/coin/lib/cmake/Coin \
  -DLIBXML2_ROOT=/path/to/libxml2
```

### Disabling Components

To disable specific components:

```bash
cmake .. \
  -DBUILD_RL_HAL=OFF \
  -DBUILD_RL_PLAN=OFF \
  -DBUILD_DEMOS=OFF
```

### Building Only Specific Libraries

You can build individual targets:

```bash
# Windows
cmake --build . --config Release --target rlplan rlkin rlsg

# Linux
cmake --build . --target rlplan rlkin rlsg
```

## Verification

After building, verify the libraries were created:

**Windows:**
```powershell
dir build\src\rl\*\*\*.dll
dir build\src\rl\*\*\*.lib
```

**Linux:**
```bash
find build/src/rl -name "*.so*" -o -name "*.a"
```

## Troubleshooting

### Common Issues

1. **CMake can't find dependencies:**
   - Use `-D<Package>_ROOT` or `-D<Package>_DIR` to specify paths
   - Check that `CMAKE_PREFIX_PATH` includes dependency locations

2. **Link errors on Windows:**
   - Ensure all DLLs are in PATH or same directory as executable
   - Check that import libraries (.lib) are linked correctly

3. **Missing symbols on Linux:**
   - Ensure all required libraries are linked
   - Check library order in `target_link_libraries()`

4. **Qt/SoQt not found:**
   - Install Qt development packages
   - Set `Qt5_DIR` or `Qt4_DIR` if installed in custom location

## Package Generation

The project supports CPack for creating installers:

**Windows (NSIS installer):**
```powershell
cmake --build . --config Release --target package
```

**Linux (DEB/RPM):**
```bash
cmake --build . --target package
```

This creates installers in the `build/` directory.

## Summary

The Robotics Library build system uses CMake and supports:
- **Windows:** MSVC 2015+ (including Visual Studio 2026 Insider Preview) with shared or static libraries
- **Native Linux:** GCC/Clang with shared or static libraries
- **WSL 2:** Full Linux compatibility with some performance and GUI considerations
- **Modular components:** Build only what you need
- **Flexible dependencies:** Use system packages or bundled versions
- **Cross-platform:** Same CMake configuration works on both platforms

All libraries follow consistent naming: `rl<component>` on Windows and `librl<component>` on Linux.

### Quick Platform Selection Guide

- **Building on Windows:** Use the Windows (MSVC) section
- **Building on native Linux:** Use the Native Linux Build section
- **Building in WSL 2:** Use the WSL 2 Build section and note the important differences
