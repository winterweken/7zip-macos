#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}7-Zip macOS Build Script${NC}"
echo "========================="
echo ""

# Check if source exists
if [ ! -d "source/CPP" ]; then
    echo -e "${RED}Error: Source code not found!${NC}"
    echo "Please run './download-source.sh' first to download the source code."
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    echo -e "${BLUE}Detected architecture: Apple Silicon (ARM64)${NC}"
    ARCH_FLAG="-arch arm64"
    BUILD_ARCH="arm64"
elif [ "$ARCH" = "x86_64" ]; then
    echo -e "${BLUE}Detected architecture: Intel (x86_64)${NC}"
    ARCH_FLAG="-arch x86_64"
    BUILD_ARCH="x86_64"
else
    echo -e "${YELLOW}Warning: Unknown architecture: $ARCH${NC}"
    echo "Attempting to build for current architecture..."
    ARCH_FLAG=""
    BUILD_ARCH="$ARCH"
fi

# Check for Xcode Command Line Tools
if ! command -v clang &> /dev/null; then
    echo -e "${RED}Error: Xcode Command Line Tools not found!${NC}"
    echo "Please install them with: xcode-select --install"
    exit 1
fi

echo -e "${GREEN}Compiler found: $(clang --version | head -n 1)${NC}"
echo ""

# Build configuration
BUILD_DIR="build"
BIN_DIR="$BUILD_DIR/bin"
SOURCE_CPP="source/CPP"

# Create build directories
echo -e "${YELLOW}Creating build directories...${NC}"
mkdir -p "$BIN_DIR"

# Compiler settings
CC="clang"
CXX="clang++"
CFLAGS="-O2 -Wall $ARCH_FLAG -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -DNDEBUG"
CXXFLAGS="$CFLAGS -std=c++14"
LDFLAGS="$ARCH_FLAG"

echo -e "${YELLOW}Build configuration:${NC}"
echo "  CC:       $CC"
echo "  CXX:      $CXX"
echo "  CFLAGS:   $CFLAGS"
echo "  CXXFLAGS: $CXXFLAGS"
echo "  LDFLAGS:  $LDFLAGS"
echo ""

# Function to build a specific variant
build_variant() {
    local variant=$1
    local output_name=$2
    
    echo -e "${GREEN}Building $variant...${NC}"
    echo "================================"
    
    cd "$SOURCE_CPP/7zip/Bundles/$variant"
    
    # Determine the makefile to use based on architecture
    local makefile_path="../../cmpl_mac_${BUILD_ARCH}.mak"
    
    if [ ! -f "$makefile_path" ]; then
        echo -e "${RED}Error: Makefile not found: $makefile_path${NC}"
        cd - > /dev/null
        return 1
    fi
    
    echo "Using makefile: $makefile_path"
    
    # Clean previous build
    make -f "$makefile_path" clean 2>/dev/null || true
    
    # Build with parallel jobs
    if make -j$(sysctl -n hw.ncpu) -f "$makefile_path"; then
        echo -e "${GREEN}✓ Build successful${NC}"
    else
        echo -e "${RED}✗ Build failed${NC}"
        cd - > /dev/null
        return 1
    fi
    
    # Find and copy the binary
    if [ -f "b/m_${BUILD_ARCH}/$output_name" ]; then
        cp "b/m_${BUILD_ARCH}/$output_name" "../../../../../$BIN_DIR/"
        echo -e "${GREEN}✓ $output_name installed to $BIN_DIR${NC}"
    else
        echo -e "${YELLOW}Warning: Binary not found at expected location: b/m_${BUILD_ARCH}/$output_name${NC}"
        echo "Searching for binary..."
        if find . -name "$output_name" -type f -exec cp {} "../../../../../$BIN_DIR/" \; 2>/dev/null; then
            echo -e "${GREEN}✓ Found and copied $output_name${NC}"
        else
            echo -e "${RED}✗ Could not find $output_name${NC}"
            cd - > /dev/null
            return 1
        fi
    fi
    
    cd - > /dev/null
    echo ""
    return 0
}

# Build all variants
echo -e "${BLUE}Starting build process...${NC}"
echo ""

# Build 7zz (standalone console version - most important)
if [ -d "$SOURCE_CPP/7zip/Bundles/Alone2" ]; then
    build_variant "Alone2" "7zz" || echo -e "${YELLOW}Warning: Alone2 build failed${NC}"
fi

# Build 7zr (minimal version)
if [ -d "$SOURCE_CPP/7zip/Bundles/Alone7z" ]; then
    build_variant "Alone7z" "7zr" || echo -e "${YELLOW}Warning: Alone7z build failed${NC}"
fi

# Build 7za (standalone version)
if [ -d "$SOURCE_CPP/7zip/Bundles/Alone" ]; then
    build_variant "Alone" "7za" || echo -e "${YELLOW}Warning: Alone build failed${NC}"
fi

echo -e "${GREEN}Build complete!${NC}"
echo ""
echo -e "${BLUE}Built binaries:${NC}"
ls -lh "$BIN_DIR"
echo ""

# Verify binaries
echo -e "${YELLOW}Verifying binaries...${NC}"
for binary in "$BIN_DIR"/*; do
    if [ -f "$binary" ]; then
        chmod +x "$binary"
        binary_name=$(basename "$binary")
        echo -n "  $binary_name: "
        if "$binary" --help > /dev/null 2>&1 || "$binary" 2>&1 | grep -q "7-Zip"; then
            echo -e "${GREEN}✓ Working${NC}"
        else
            echo -e "${YELLOW}? Unable to verify${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}Build successful!${NC}"
echo ""
echo "Binaries are located in: $BIN_DIR"
echo ""
echo "To install system-wide, run: sudo ./install.sh"
echo "To test the build, run: ./test.sh"
