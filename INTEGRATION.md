# Integrating Pre-built 3rdparty Dependencies with RL

This guide explains how to use pre-built 3rdparty dependencies when building the main Robotics Library project.

## Quick Integration

### Step 1: Build 3rdparty Dependencies

```powershell
# Windows
cd C:\Tools\RoboticLibrary\rl-0.7.0\3rdparty
.\build-3rdparty.ps1 -InstallPrefix "C:\Tools\RoboticLibrary\3rdparty-install"
```

```bash
# Linux
cd /path/to/rl-0.7.0/3rdparty
./build-3rdparty.sh --install-prefix /path/to/3rdparty-install
```

### Step 2: Configure Main RL Project

```powershell
# Windows
cd C:\Tools\RoboticLibrary\rl-0.7.0
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_PREFIX_PATH="C:\Tools\RoboticLibrary\3rdparty-install"
```

```bash
# Linux
cd /path/to/rl-0.7.0
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="/path/to/3rdparty-install"
```

## How It Works

The RL build system uses CMake's `find_package()` mechanism with custom Find modules located in `cmake/`. These modules search for dependencies in the following order:

1. **CMAKE_PREFIX_PATH** - Your pre-built dependencies (highest priority)
2. **System packages** - System-installed libraries (Linux)
3. **Standard locations** - `/usr/local`, `/opt/local`, etc.
4. **3rdparty subdirectory** - If dependencies are built as part of main project

## Setting CMAKE_PREFIX_PATH

### Method 1: Command Line (Recommended)

```powershell
# Windows - Single path
cmake .. -DCMAKE_PREFIX_PATH="C:\path\to\install"

# Windows - Multiple paths
cmake .. -DCMAKE_PREFIX_PATH="C:\path1;C:\path2"
```

```bash
# Linux - Single path
cmake .. -DCMAKE_PREFIX_PATH="/path/to/install"

# Linux - Multiple paths
cmake .. -DCMAKE_PREFIX_PATH="/path1:/path2"
```

### Method 2: Environment Variable

```powershell
# Windows PowerShell
$env:CMAKE_PREFIX_PATH = "C:\path\to\install"
cmake ..
```

```bash
# Linux Bash
export CMAKE_PREFIX_PATH="/path/to/install"
cmake ..
```

### Method 3: CMakeCache.txt

After first configuration, you can edit `build/CMakeCache.txt`:

```
CMAKE_PREFIX_PATH:PATH=C:/path/to/install
```

Then reconfigure:

```powershell
cmake .
```

## Verifying Dependency Detection

After configuring, check the CMake output for dependency detection:

```
-- Found Boost: ...
-- Found Bullet: ...
-- Found Coin: ...
-- Found Eigen3: ...
-- Found libxml2: ...
```

If a dependency is not found, CMake will attempt to build it from the `3rdparty/` directory automatically.

## Dependency-Specific Variables

Some dependencies can be configured with specific variables:

```powershell
cmake .. `
  -DCMAKE_PREFIX_PATH="C:\path\to\install" `
  -DBoost_ROOT="C:\path\to\boost" `
  -DEigen3_DIR="C:\path\to\eigen3\share\eigen3\cmake" `
  -DCoin_DIR="C:\path\to\coin\lib\cmake\Coin" `
  -DBullet_ROOT="C:\path\to\bullet"
```

## Common Issues

### Dependencies Not Found

**Problem**: CMake can't find pre-built dependencies.

**Solutions**:
1. Verify `CMAKE_PREFIX_PATH` points to the correct install directory
2. Check that dependencies were actually installed (look for `include/` and `lib/` directories)
3. Ensure the install directory structure matches what Find modules expect:
   ```
   install/
   ├── include/
   │   ├── bullet/
   │   ├── Coin/
   │   └── ...
   ├── lib/
   │   ├── libBullet*.lib (Windows) or libBullet*.so (Linux)
   │   └── ...
   └── bin/ (Windows)
   ```

### Mixed Dependency Sources

**Problem**: Some dependencies found from system, others from 3rdparty.

**Solution**: This is usually fine, but if you want consistency, set `CMAKE_PREFIX_PATH` to include only your 3rdparty install directory and ensure system packages are not in standard locations.

### Version Conflicts

**Problem**: Different versions of dependencies cause conflicts.

**Solution**: Use a consistent set of dependencies. Pre-building all dependencies from `3rdparty/` ensures version compatibility.

## Example: Complete Build Workflow

### Windows

```powershell
# 1. Build 3rdparty dependencies
cd C:\Tools\RoboticLibrary\rl-0.7.0\3rdparty
.\build-3rdparty.ps1 -InstallPrefix "C:\RL\3rdparty-install"

# 2. Configure main RL project
cd C:\Tools\RoboticLibrary\rl-0.7.0
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_PREFIX_PATH="C:\RL\3rdparty-install" `
  -DBUILD_DEMOS=ON

# 3. Build RL
cmake --build . --config Release --parallel

# 4. Install (optional)
cmake --build . --config Release --target install
```

### Linux

```bash
# 1. Build 3rdparty dependencies
cd /path/to/rl-0.7.0/3rdparty
./build-3rdparty.sh --install-prefix /opt/rl/3rdparty-install

# 2. Configure main RL project
cd /path/to/rl-0.7.0
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="/opt/rl/3rdparty-install" \
  -DBUILD_DEMOS=ON

# 3. Build RL
cmake --build . --parallel $(nproc)

# 4. Install (optional)
cmake --build . --target install
```

## Tips

1. **Reuse builds**: Once built, you can reuse the same 3rdparty install directory for multiple RL builds
2. **Version consistency**: Keep track of which versions of dependencies you built
3. **Clean builds**: If switching between system and 3rdparty dependencies, clean your build directory
4. **Documentation**: Document your `CMAKE_PREFIX_PATH` settings for team members

## See Also

- [3rdparty README](README.md) - Building dependencies
- [Main Build Guide](../.cursor/BUILD_GUIDE.md) - Complete RL build instructions
