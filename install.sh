#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}7-Zip Installation Script${NC}"
echo "=========================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Check if binaries exist
if [ ! -d "build/bin" ] || [ -z "$(ls -A build/bin)" ]; then
    echo -e "${RED}Error: No binaries found in build/bin${NC}"
    echo "Please run './build.sh' first to compile 7-Zip."
    exit 1
fi

# Installation directory
INSTALL_DIR="/usr/local/bin"

echo -e "${YELLOW}Installing 7-Zip binaries to $INSTALL_DIR${NC}"
echo ""

# Copy binaries
for binary in build/bin/*; do
    if [ -f "$binary" ]; then
        binary_name=$(basename "$binary")
        echo -n "Installing $binary_name... "
        cp "$binary" "$INSTALL_DIR/"
        chmod 755 "$INSTALL_DIR/$binary_name"
        echo -e "${GREEN}✓${NC}"
    fi
done

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""

# Verify installation
echo -e "${YELLOW}Verifying installation...${NC}"
for binary in build/bin/*; do
    binary_name=$(basename "$binary")
    if command -v "$binary_name" &> /dev/null; then
        version=$("$binary_name" 2>&1 | grep -i "7-Zip" | head -n 1 || echo "installed")
        echo -e "  ${GREEN}✓${NC} $binary_name: $version"
    else
        echo -e "  ${RED}✗${NC} $binary_name: Not found in PATH"
    fi
done

echo ""
echo -e "${GREEN}7-Zip has been installed successfully!${NC}"
echo ""
echo "Usage examples:"
echo "  7zz a archive.7z file.txt          # Create archive"
echo "  7zz x archive.7z                   # Extract archive"
echo "  7zz l archive.7z                   # List contents"
echo "  7zz --help                         # Show help"
