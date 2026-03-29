#!/bin/bash
# ==============================================================================
# diagnose_ngspice.sh - Diagnose ngspice installations
# Part of ihp-macos-toolkit
#
# Usage:
#   ./diagnose_ngspice.sh
#   ./diagnose_ngspice.sh --capability osdi    # check specific capability
#   ./diagnose_ngspice.sh --fast               # skip slow system-wide find
# ==============================================================================

# Capabilities to check in spinit
CAPABILITIES=("osdi" "osdi_enabled" "verilog" "cider" "xspice")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
FAST=0
EXTRA_CAP=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --fast)       FAST=1 ;;
        --capability) EXTRA_CAP="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Add extra capability if provided
if [ -n "$EXTRA_CAP" ]; then
    CAPABILITIES+=("$EXTRA_CAP")
fi

# Search paths
if [ "$FAST" -eq 1 ]; then
    SEARCH_PATHS="/usr/local /opt/local /opt/homebrew $HOME"
else
    SEARCH_PATHS="/"
fi

echo "=========================================="
echo "  ngspice Installation Diagnostic"
echo "  ihp-macos-toolkit"
echo "=========================================="
echo ""
echo "Searching for ngspice executables..."
if [ "$FAST" -eq 1 ]; then
    echo "(fast mode: searching $SEARCH_PATHS)"
fi
echo ""

# Find all ngspice executables
EXECUTABLES=$(find $SEARCH_PATHS -name "ngspice" ! -type d -perm +111 2>/dev/null | sort -u)

if [ -z "$EXECUTABLES" ]; then
    echo -e "${RED}❌ No ngspice executable found${NC}"
    exit 1
fi

COUNT=$(echo "$EXECUTABLES" | wc -l | tr -d ' ')
echo "Found $COUNT ngspice executable(s)"
echo ""

# Analyse each executable
echo "$EXECUTABLES" | while read exec; do

    echo "──────────────────────────────────────────"
    echo -e "${BLUE}Executable${NC} : $exec"

    # Version
    version=$($exec -v 2>&1 | grep -iE "ngspice-[0-9]|version [0-9]" | head -1 | sed 's/^[ \t]*//')
    if [ -n "$version" ]; then
        # Extract version number
        ver_num=$(echo "$version" | grep -oE "[0-9]+\.[0-9]+|[0-9]+" | head -1)
        if [ -n "$ver_num" ] && [ "${ver_num%%.*}" -ge 39 ] 2>/dev/null; then
            echo -e "${GREEN}Version${NC}    : $version (>= 39, OSDI potentially supported)"
        else
            echo -e "${YELLOW}Version${NC}    : $version (< 39, OSDI NOT supported)"
        fi
    else
        echo -e "${YELLOW}Version${NC}    : unknown"
    fi

    # Find spinit - look relative to executable first, then system paths
    exec_base=$(dirname $(dirname "$exec"))
    spinit=""

    # Search relative to executable
    spinit=$(find "$exec_base" -name "spinit" -type f 2>/dev/null | head -1)

    # Fallback to common system paths
    if [ -z "$spinit" ]; then
        for path in \
            "/usr/local/share/ngspice/scripts/spinit" \
            "/opt/local/share/ngspice/scripts/spinit" \
            "/opt/homebrew/share/ngspice/scripts/spinit" \
            "$HOME/.ngspice/spinit"; do
            if [ -f "$path" ]; then
                spinit="$path"
                break
            fi
        done
    fi

    if [ -n "$spinit" ]; then
        echo -e "${GREEN}Spinit${NC}     : $spinit"

        # Check each capability
        echo "Capabilities:"
        for cap in "${CAPABILITIES[@]}"; do
            # Get all matching lines
            matches=$(grep -in "$cap" "$spinit" 2>/dev/null)

            if [ -n "$matches" ]; then
                # Check if active (not commented out with * or ;)
                active=$(echo "$matches" | grep -vE "^\s*[*;]" | head -1)
                commented=$(echo "$matches" | grep -E "^\s*[*;]" | head -1)

                if [ -n "$active" ]; then
                    echo -e "  ${GREEN}✅ $cap${NC} : active"
                    echo "      → $(echo $active | sed 's/^[ \t]*//')"
                elif [ -n "$commented" ]; then
                    echo -e "  ${YELLOW}⚠️  $cap${NC} : present but commented out"
                    echo "      → $(echo $commented | sed 's/^[ \t]*//')"
                fi
            else
                echo -e "  ${RED}❌ $cap${NC} : not found in spinit"
            fi
        done
    else
        echo -e "${RED}Spinit${NC}     : ❌ not found"
        echo "  Cannot check capabilities without spinit"
    fi

    echo ""
done

echo "=========================================="
echo "Diagnostic complete"
echo ""
echo "For OSDI/Verilog-A support you need:"
echo "  - ngspice >= 39"
echo "  - osdi_enabled set (not commented) in spinit"
echo "=========================================="
