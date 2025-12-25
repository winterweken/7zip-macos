#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SEVEN_ZIP_VERSION="2409"
SEVEN_ZIP_FULL_VERSION="24.09"
SOURCE_URL="https://www.7-zip.org/a/7z${SEVEN_ZIP_VERSION}-src.tar.xz"
SOURCE_DIR="source"
DOWNLOAD_FILE="7z${SEVEN_ZIP_VERSION}-src.tar.xz"

echo -e "${GREEN}7-Zip Source Download Script${NC}"
echo "================================"
echo "Version: ${SEVEN_ZIP_FULL_VERSION}"
echo ""

# Create source directory if it doesn't exist
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${YELLOW}Creating source directory...${NC}"
    mkdir -p "$SOURCE_DIR"
fi

# Check if source already exists
if [ -d "$SOURCE_DIR/CPP" ]; then
    echo -e "${YELLOW}Source code already exists in $SOURCE_DIR${NC}"
    read -p "Do you want to re-download? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Using existing source code.${NC}"
        exit 0
    fi
    echo -e "${YELLOW}Cleaning existing source...${NC}"
    rm -rf "$SOURCE_DIR"/*
fi

# Download source code
echo -e "${YELLOW}Downloading 7-Zip ${SEVEN_ZIP_FULL_VERSION} source code...${NC}"
if command -v curl &> /dev/null; then
    curl -L -o "$DOWNLOAD_FILE" "$SOURCE_URL"
elif command -v wget &> /dev/null; then
    wget -O "$DOWNLOAD_FILE" "$SOURCE_URL"
else
    echo -e "${RED}Error: Neither curl nor wget found. Please install one of them.${NC}"
    exit 1
fi

# Verify download
if [ ! -f "$DOWNLOAD_FILE" ]; then
    echo -e "${RED}Error: Download failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Download complete!${NC}"
echo -e "${YELLOW}Extracting source code...${NC}"

# Extract source code
tar -xf "$DOWNLOAD_FILE" -C "$SOURCE_DIR"

# Clean up downloaded archive
rm "$DOWNLOAD_FILE"

echo -e "${GREEN}Source code extracted successfully!${NC}"
echo ""

# Apply fixes
echo -e "${YELLOW}Applying build fixes...${NC}"
if [ -f "$SOURCE_DIR/CPP/7zip/warn_clang_mac.mak" ]; then
    sed -i.bak 's/-Wno-poison-system-directories/-Wno-poison-system-directories -Wno-switch-default/' "$SOURCE_DIR/CPP/7zip/warn_clang_mac.mak"
    rm -f "$SOURCE_DIR/CPP/7zip/warn_clang_mac.mak.bak"
    echo -e "${GREEN}Fix applied: suppressed -Wswitch-default in warn_clang_mac.mak${NC}"
else
    echo -e "${RED}Warning: warn_clang_mac.mak not found, skipping fix${NC}"
fi
echo ""

echo "Source location: $SOURCE_DIR"
echo ""

# Display source structure
if [ -d "$SOURCE_DIR/CPP" ]; then
    echo -e "${GREEN}Source structure:${NC}"
    ls -la "$SOURCE_DIR"
    echo ""
    echo -e "${GREEN}Ready to build!${NC}"
    echo "Run './build.sh' to compile 7-Zip for macOS"
else
    echo -e "${RED}Warning: Expected source structure not found!${NC}"
    echo "Please check the extracted files in $SOURCE_DIR"
fi
