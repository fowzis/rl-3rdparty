#!/bin/bash
# Bash script to build 3rdparty dependencies for Robotics Library
# Usage: ./build-3rdparty.sh [--install-prefix <path>] [--build-type <Release|Debug>] [--skip-build] [--skip-install] [--jobs <N>]

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PREFIX="${SCRIPT_DIR}/install"
BUILD_TYPE="Release"
SKIP_BUILD=false
SKIP_INSTALL=false
PARALLEL_JOBS=$(nproc)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --install-prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --build-type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --jobs)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --install-prefix <path>  Installation prefix (default: \$SCRIPT_DIR/install)"
            echo "  --build-type <type>      Build type: Release, Debug, RelWithDebInfo, MinSizeRel (default: Release)"
            echo "  --skip-build             Skip building, only configure"
            echo "  --skip-install           Skip installation"
            echo "  --jobs <N>               Number of parallel jobs (default: all available cores)"
            echo "  -h, --help               Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "========================================"
echo "Robotics Library 3rdparty Build Script"
echo "========================================"
echo ""

# Check CMake version
echo "Checking CMake version..."
if ! command -v cmake &> /dev/null; then
    echo "ERROR: CMake not found. Please install CMake 3.24 or later."
    exit 1
fi

CMAKE_VERSION=$(cmake --version | head -n1)
echo "Found: $CMAKE_VERSION"

# Check CMake version >= 3.24
CMAKE_MAJOR=$(cmake --version | head -n1 | sed 's/.*version \([0-9]*\)\.\([0-9]*\).*/\1/')
CMAKE_MINOR=$(cmake --version | head -n1 | sed 's/.*version \([0-9]*\)\.\([0-9]*\).*/\2/')

if [ "$CMAKE_MAJOR" -lt 3 ] || ([ "$CMAKE_MAJOR" -eq 3 ] && [ "$CMAKE_MINOR" -lt 24 ]); then
    echo "ERROR: CMake 3.24 or later is required. Found version $CMAKE_MAJOR.$CMAKE_MINOR"
    exit 1
fi

echo ""
echo "Build Configuration:"
echo "  Build Type: $BUILD_TYPE"
echo "  Install Prefix: $INSTALL_PREFIX"
echo "  Parallel Jobs: $PARALLEL_JOBS"
echo ""

# Check for downloads directory
DOWNLOADS_DIR="${SCRIPT_DIR}/downloads"
if [ ! -d "$DOWNLOADS_DIR" ]; then
    echo "ERROR: Downloads directory not found: $DOWNLOADS_DIR"
    echo "Please run download-all-sources.sh first to download required source packages."
    exit 1
fi

# Verify required downloads exist
echo "Verifying required downloads..."
MISSING_FILES=0

REQUIRED_DOWNLOADS=(
    "ATI/atidaq-cmake-1.0.6.tar.gz"
    "boost/boost-1.88.0-cmake.7z"
    "bullet/bullet3-3.25.tar.gz"
    "coin/coin-4.0.3-src.tar.gz"
    "eigen/eigen-3.4.0.tar.gz"
    "fcl/fcl-0.7.0.tar.gz"
    "gperf/gperf-cmake-3.2.tar.gz"
    "libccd/libccd-2.1.tar.gz"
    "libiconv/libiconv-cmake-1.18.tar.gz"
    "libxml2/libxml2-v2.14.1.tar.gz"
    "libxslt/libxslt-v1.1.43.tar.gz"
    "nlopt/nlopt-2.10.0.tar.gz"
    "ode/ode-0.16.6.tar.gz"
    "pqp/PQP-713de5b70dd1849b915f6412330078a9814e01ab.tar.gz"
    "simage/simage-1.8.3-src.tar.gz"
    "solid/solid3-cbac1402da5df65e7239558a6c04feb736e54b27.zip"
    "soqt/soqt-1.6.3-src.tar.gz"
    "superglu/superglu-1.3.2-src.tar.gz"
)

for file in "${REQUIRED_DOWNLOADS[@]}"; do
    filepath="${DOWNLOADS_DIR}/${file}"
    if [ ! -f "$filepath" ]; then
        echo "  MISSING: $file" >&2
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    echo ""
    echo "ERROR: $MISSING_FILES required download(s) are missing!"
    echo "Please run download-all-sources.sh to download missing files."
    exit 1
fi

echo "  All required downloads found."
echo ""

# Create build directory
BUILD_DIR="${SCRIPT_DIR}/build"
if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
fi

cd "$BUILD_DIR"

# Configure CMake
echo "Configuring CMake..."
cmake .. \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.20

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed!"
    exit 1
fi

echo "Configuration successful!"
echo ""

# Build dependencies
if [ "$SKIP_BUILD" = false ]; then
    echo "Building dependencies (this may take 30-60 minutes)..."
    cmake --build . --parallel "$PARALLEL_JOBS"
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Build failed!"
        exit 1
    fi
    
    echo "Build successful!"
    echo ""
else
    echo "Skipping build (--skip-build specified)"
    echo ""
fi

# Install dependencies
if [ "$SKIP_INSTALL" = false ]; then
    echo "Installing dependencies..."
    cmake --build . --target install
    
    if [ $? -ne 0 ]; then
        echo "WARNING: Install failed, but build artifacts are in the build directory"
    else
        echo "Installation successful!"
        echo ""
        echo "Dependencies installed to: $INSTALL_PREFIX"
    fi
else
    echo "Skipping install (--skip-install specified)"
fi

echo ""
echo "========================================"
echo "Build Complete!"
echo "========================================"
echo ""
echo "To use these dependencies when building RL, set CMAKE_PREFIX_PATH:"
echo "  cmake .. -DCMAKE_PREFIX_PATH=\"$INSTALL_PREFIX\""
echo ""
