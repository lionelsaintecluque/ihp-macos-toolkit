#!/bin/bash
# Install OpenVAF via Docker for macOS
# Part of ihp-macos-toolkit
# Tested on: Intel Mac (x86_64)

set -e

echo "=========================================="
echo "OpenVAF Installation (Docker-based)"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo ""
    echo "Please install Docker Desktop from:"
    echo "https://www.docker.com/products/docker-desktop"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Docker found${NC}"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker daemon is not running${NC}"
    echo ""
    echo "Please:"
    echo "1. Launch Docker Desktop from Applications"
    echo "2. Wait for the Docker icon to be stable in the menu bar"
    echo "3. Run this script again"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Docker daemon is running${NC}"
echo ""

# Pull the IIC-OSIC-TOOLS image
echo "📥 Downloading IIC-OSIC-TOOLS Docker image..."
echo "This may take 5-10 minutes depending on your connection"
echo ""

if docker pull hpretl/iic-osic-tools:latest; then
    echo ""
    echo -e "${GREEN}✅ Docker image downloaded successfully${NC}"
else
    echo ""
    echo -e "${RED}❌ Failed to download Docker image${NC}"
    exit 1
fi

echo ""
echo "📝 Configuring OpenVAF shell function..."

# Check which shell is being used
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo -e "${YELLOW}⚠️  No .zshrc or .bashrc found${NC}"
    echo "Creating .zshrc..."
    touch "$HOME/.zshrc"
    SHELL_RC="$HOME/.zshrc"
fi

# Check if OpenVAF function already exists
if grep -q "openvaf()" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  OpenVAF function already exists in $SHELL_RC${NC}"
    echo "Skipping configuration (already installed)"
else
    # Add OpenVAF function to shell RC
    cat >> "$SHELL_RC" << 'EOF'

# ===================================
# OpenVAF via Docker (ihp-macos-toolkit)
# ===================================
openvaf() {
    docker run --rm -v "$(pwd)":/work -w /work \
        hpretl/iic-osic-tools:latest --skip openvaf "$@"
}

EOF
    echo -e "${GREEN}✅ OpenVAF function added to $SHELL_RC${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ OpenVAF installation complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Reload your shell: source $SHELL_RC"
echo "   Or restart your terminal"
echo ""
echo "2. Test OpenVAF:"
echo "   openvaf --version"
echo ""
echo "3. Compile a Verilog-A model:"
echo "   openvaf model.va -o model.osdi"
echo ""
echo "Documentation: https://openvaf.semimod.de/docs/"
echo "=========================================="
