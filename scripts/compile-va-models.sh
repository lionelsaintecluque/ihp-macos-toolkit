#!/bin/bash
# Compile all Verilog-A models in IHP SG13G2 PDK
# Part of ihp-macos-toolkit
# Tested on: Intel Mac (x86_64)

set -e

echo "=========================================="
echo "IHP SG13G2 Verilog-A Model Compilation"
echo "=========================================="
echo ""

# Check if PDK_ROOT is set
if [ -z "$PDK_ROOT" ]; then
    echo "❌ Error: PDK_ROOT is not set"
    echo ""
    echo "Please set PDK_ROOT environment variable:"
    echo "export PDK_ROOT=\$HOME/microelectronics/PDK/IHP/IHP-Open-PDK"
    echo ""
    exit 1
fi

# Check if PDK exists
if [ -z "$PDK" ]; then
    echo "❌ Error: PDK is not set"
    echo ""
    echo "Please set PDK environment variable:"
    echo "export PDK=ihp-sg13g2"
    echo ""
    exit 1
fi

LIBTECH_DIR="$PDK_ROOT/$PDK/libs.tech"

if [ ! -d "$LIBTECH_DIR" ]; then
    echo "❌ Error: Directory not found: $LIBTECH_DIR"
    echo ""
    echo "Please install the IHP PDK first using:"
    echo "./scripts/install-pdk-ihp.sh"
    echo ""
    exit 1
fi

echo "✅ PDK found at: $PDK_ROOT/$PDK"
echo ""

# Change to libtech directory
cd "$LIBTECH_DIR"

echo "📋 Searching for Verilog-A models..."
echo ""

# Find all .va files
VA_FILES=$(find . -name "*.va" -type f)

if [ -z "$VA_FILES" ]; then
    echo "❌ No Verilog-A files found in $LIBTECH_DIR"
    exit 1
fi

echo "Found models:"
echo "$VA_FILES"
echo ""
echo "=========================================="
echo ""

# Compile each model
SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_MODELS=""

for va_file in $VA_FILES; do
    dir=$(dirname "$va_file")
    base=$(basename "$va_file" .va)
    osdi_file="${dir}/${base}.osdi"
    
    echo "Compiling: $va_file"
    
    # Use Docker to run OpenVAF (works in scripts)
    if docker run --rm -v "$(pwd)":/work -w /work \
        hpretl/iic-osic-tools:latest --skip openvaf \
        "$va_file" -o "$osdi_file" 2>&1 | grep -v "INFO\|ERROR.*Unexpected"; then
        
        if [ -f "$osdi_file" ]; then
            echo "✅ Success: $osdi_file"
            ((SUCCESS_COUNT++))
        else
            echo "❌ Failed: $osdi_file not created"
            FAILED_MODELS="$FAILED_MODELS\n  - $va_file"
            ((FAIL_COUNT++))
        fi
    else
        echo "❌ Compilation failed: $va_file"
        FAILED_MODELS="$FAILED_MODELS\n  - $va_file"
        ((FAIL_COUNT++))
    fi
    
    echo ""
done

echo "=========================================="
echo "Compilation Summary"
echo "=========================================="
echo "✅ Successful: $SUCCESS_COUNT"
echo "❌ Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -gt 0 ]; then
    echo ""
    echo "Failed models:"
    echo -e "$FAILED_MODELS"
fi

echo ""
echo "Compiled models:"
find . -name "*.osdi" -type f -exec ls -lh {} \;
echo ""
echo "=========================================="

if [ $FAIL_COUNT -eq 0 ]; then
    echo "🎉 All models compiled successfully!"
    exit 0
else
    echo "⚠️  Some models failed to compile"
    exit 1
fi
