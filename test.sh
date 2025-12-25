#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}7-Zip Test Suite${NC}"
echo "================="
echo ""

# Check if binaries exist
if [ ! -d "build/bin" ] || [ -z "$(ls -A build/bin)" ]; then
    echo -e "${RED}Error: No binaries found in build/bin${NC}"
    echo "Please run './build.sh' first to compile 7-Zip."
    exit 1
fi

# Find the main binary (prefer 7zz, then 7za, then 7z)
SEVEN_ZIP=""
for candidate in "7zz" "7za" "7z"; do
    if [ -f "build/bin/$candidate" ]; then
        SEVEN_ZIP="./build/bin/$candidate"
        break
    fi
done

if [ -z "$SEVEN_ZIP" ]; then
    echo -e "${RED}Error: No 7-Zip binary found!${NC}"
    exit 1
fi

echo -e "${BLUE}Using binary: $SEVEN_ZIP${NC}"
echo ""

# Create test directory
TEST_DIR="test_temp"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -n "Testing $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Create test files
echo "Creating test files..."
echo "Hello, 7-Zip!" > test1.txt
echo "This is a test file for compression." > test2.txt
dd if=/dev/urandom of=binary.dat bs=1024 count=100 2>/dev/null
mkdir -p subdir
echo "File in subdirectory" > subdir/test3.txt

echo ""
echo -e "${BLUE}Running tests...${NC}"
echo ""

# Test 1: Basic compression (7z format)
run_test "7z compression" "../$SEVEN_ZIP a test.7z test1.txt test2.txt"

# Test 2: List archive contents
run_test "List archive" "../$SEVEN_ZIP l test.7z"

# Test 3: Extract archive
run_test "Extract archive" "mkdir extract1 && cd extract1 && ../../$SEVEN_ZIP x ../test.7z && cd .."

# Test 4: Verify extracted files
run_test "Verify extraction" "diff test1.txt extract1/test1.txt && diff test2.txt extract1/test2.txt"

# Test 5: ZIP format support
run_test "ZIP compression" "../$SEVEN_ZIP a test.zip test1.txt"

# Test 6: GZIP format support
run_test "GZIP compression" "../$SEVEN_ZIP a test.gz test1.txt"

# Test 7: TAR format support
run_test "TAR compression" "../$SEVEN_ZIP a test.tar test1.txt test2.txt"

# Test 8: Directory compression
run_test "Directory compression" "../$SEVEN_ZIP a dir.7z subdir/"

# Test 9: Compression levels
run_test "Compression level 0" "../$SEVEN_ZIP a -mx=0 fast.7z test1.txt"
run_test "Compression level 9" "../$SEVEN_ZIP a -mx=9 ultra.7z test1.txt"

# Test 10: Password protection
run_test "Password protection" "../$SEVEN_ZIP a -pSecretPass encrypted.7z test1.txt"
run_test "Password extraction" "mkdir extract2 && cd extract2 && ../../$SEVEN_ZIP x -pSecretPass ../encrypted.7z && cd .."

# Test 11: Binary file compression
run_test "Binary file compression" "../$SEVEN_ZIP a binary.7z binary.dat"

# Test 12: Update archive
run_test "Update archive" "echo 'Updated content' > test1.txt && ../$SEVEN_ZIP u test.7z test1.txt"

# Test 13: Test archive integrity
run_test "Test archive integrity" "../$SEVEN_ZIP t test.7z"

# Test 14: Multi-threading (if supported)
run_test "Multi-threading" "../$SEVEN_ZIP a -mmt=on threaded.7z test1.txt test2.txt"

echo ""
echo -e "${BLUE}Test Results:${NC}"
echo "=============="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

# Cleanup
cd ..
rm -rf "$TEST_DIR"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    echo ""
    echo "Your 7-Zip build is working correctly."
    exit 0
else
    echo -e "${YELLOW}Some tests failed.${NC}"
    echo ""
    echo "The build may have limited functionality."
    exit 1
fi
