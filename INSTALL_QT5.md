# Installing Qt5 for Robotics Library Build

## Option 1: Pre-built Binaries (Recommended - Fastest)

### Steps

1. **Download Qt Online Installer:**
   - Visit: <https://www.qt.io/download-open-source>
   - Download "Qt Online Installer for Windows"
   - Run the installer

2. **Install Required Components:**
   - **Qt Version:** Qt 5.15.2 (or latest 5.15.x)
   - **Compiler:** MSVC 2019 64-bit (compatible with VS 2022)
   - **Components:**
     - Qt 5.15.2 → MSVC 2019 64-bit
     - Qt 5.15.2 → Qt Charts (optional)
     - Qt 5.15.2 → Qt Data Visualization (optional)
   - **Installation Path:** Default is `C:\Qt\5.15.2\msvc2019_64`

3. **Set Environment Variable:**

   ```powershell
   # Set Qt5_DIR to point to the CMake config directory
   $env:Qt5_DIR = "C:\Qt\5.15.2\msvc2019_64\lib\cmake\Qt5"
   
   # Make it persistent (optional)
   [System.Environment]::SetEnvironmentVariable("Qt5_DIR", "C:\Qt\5.15.2\msvc2019_64\lib\cmake\Qt5", "User")
   ```

4. **Verify Installation:**

   ```powershell
   cmake --find-package -DNAME=Qt5 -DCOMPILER_ID=MSVC -DLANGUAGE=CXX -DMODE=COMPILE
   ```

5. **Rebuild rl-3rdparty:**

   ```powershell
   cd C:\Tools\RoboticLibrary\GitHub\rl-3rdparty
   .\build-3rdparty.ps1
   ```

---

## Option 2: Build from Source (Advanced)

### Prerequisites

- **Perl** (required for Qt build system)
  - Download: <https://strawberryperl.com/> (recommended)
  - Or: <https://www.activestate.com/products/perl/> (ActivePerl)
- **Python 3.x** (usually already installed)
- **Visual Studio 2022** with C++ tools
- **Time:** 1-2 hours for build

### Build Steps

1. **Extract qtbase-everywhere-src-5.15.2.zip:**

   ```powershell
   # Extract to a location like C:\Qt\5.15.2-src
   Expand-Archive -Path "qtbase-everywhere-src-5.15.2.zip" -DestinationPath "C:\Qt\5.15.2-src"
   ```

2. **Open "x64 Native Tools Command Prompt for VS 2022"** (not regular PowerShell)
   - Search for "x64 Native Tools Command Prompt" in Start menu
   - This sets up the MSVC environment correctly

3. **Configure Qt:**

   ```cmd
   cd C:\Qt\5.15.2-src\qtbase-everywhere-src-5.15.2
   
   # Configure for MSVC 2019 64-bit (compatible with VS 2022)
   configure.bat -prefix C:\Qt\5.15.2\msvc2019_64 -opensource -confirm-license -release -opengl desktop -no-feature-assistant -no-feature-designer -skip qtwebengine -skip qtwebview -skip qtscript -skip qtserialport -skip qtsensors -skip qtserialbus -skip qtpurchasing -skip qtlocation -skip qtscxml -skip qtvirtualkeyboard -skip qtgamepad -skip qtspeech -skip qtnetworkauth -skip qtdoc -skip qttools -skip qttranslations -skip qtsvg -skip qtquickcontrols2 -skip qtquickcontrols -skip qtquick -skip qtgraphicaleffects -skip qtdeclarative -skip qtscript -skip qtserialport -skip qtsensors -skip qtserialbus -skip qtpurchasing -skip qtlocation -skip qtscxml -skip qtvirtualkeyboard -skip qtgamepad -skip qtspeech -skip qtnetworkauth -skip qtdoc -skip qttools -skip qttranslations -skip qtsvg -skip qtquickcontrols2 -skip qtquickcontrols -skip qtquick -skip qtgraphicaleffects -skip qtdeclarative
   ```

   **Simpler configuration (recommended):**

   ```cmd
   configure.bat -prefix C:\Qt\5.15.2\msvc2019_64 -opensource -confirm-license -release -opengl desktop -nomake examples -nomake tests
   ```

4. **Build Qt:**

   ```cmd
   nmake
   # This will take 1-2 hours
   ```

5. **Install Qt:**

   ```cmd
   nmake install
   ```

6. **Set Environment Variable:**

   ```powershell
   $env:Qt5_DIR = "C:\Qt\5.15.2\msvc2019_64\lib\cmake\Qt5"
   ```

7. **Rebuild rl-3rdparty:**

   ```powershell
   cd C:\Tools\RoboticLibrary\GitHub\rl-3rdparty
   .\build-3rdparty.ps1
   ```

---

## Verification After Installation

After installing Qt (either method), verify it works:

```powershell
# Check if CMake can find Qt5
cmake --find-package -DNAME=Qt5 -DCOMPILER_ID=MSVC -DLANGUAGE=CXX -DMODE=COMPILE

# Or test with a simple CMakeLists.txt
cmake -S . -B test-qt -DCMAKE_PREFIX_PATH="C:\Qt\5.15.2\msvc2019_64" -G "Visual Studio 17 2022" -A x64
```

---

## Troubleshooting

### CMake can't find Qt5

- Ensure `Qt5_DIR` is set correctly
- Path should be: `C:\Qt\5.15.2\msvc2019_64\lib\cmake\Qt5`
- Verify the directory contains `Qt5Config.cmake`

### SoQt still not found after Qt installation

- Rebuild rl-3rdparty after installing Qt
- Ensure Qt5_DIR is set before running build-3rdparty.ps1
- Check that Qt5 was found during rl-3rdparty configuration

### Build errors during Qt compilation

- Ensure you're using "x64 Native Tools Command Prompt" (not regular PowerShell)
- Verify Perl is installed and in PATH
- Check that Visual Studio 2022 C++ tools are installed
