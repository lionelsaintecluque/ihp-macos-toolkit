# Installation Guide

Complete installation guide for the IHP SG13G2 macOS Toolkit.

---

*Note to the reader : This installation guide was written by a folk (myself) and a Machine (Claude). 
The machine might write mistakes that the folk missed to correct. 
Moreover, we all have different setups and needs, so please don't stick to the verbatim.
Adapt it to fit your needs, and let me know where the machine was wrong.* 

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [System Preparation](#system-preparation)
3. [Docker Installation](#docker-installation)
4. [PDK Installation](#pdk-installation)
5. [Toolkit Installation](#toolkit-installation)
6. [Environment Configuration](#environment-configuration)
7. [Verification](#verification)
8. [Optional Native Tools](#optional-native-tools)
9. [Use Cases](#use-cases)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

This guide is for **macOS users with Intel processors** (x86_64).

**Recommended**: 
 - Some tools recommend using macOS 10.15 (Catalina) or later.
 - I personally used 15.7 (Sequoia) when writing this document. 

**Requirements**:
- Electronic design know-how
- Command-line fluency
- 20+ GB free disk space (says the machine, I did not check)
- Active internet connection

**Apple Silicon (M1/M2/M3)**: This toolkit is untested on ARM processors. If you successfully use it, please contribute your findings.

---

## System Preparation

### Check Your System

```bash
# Check macOS version
sw_vers

# Verify Intel processor
uname -m
# Should display: x86_64

# Check available disk space
df -h ~
```

### Create Directory Structure

Choose a root directory for all ASIC design work. We'll call this `ASIC_DESIGN_ROOT`.

**Example structure**:
```
~/Electronics/              # or ~/Work/ASIC/ or ~/Projects/Chips/
├── outils/                 # Tools and toolkits
├── projets/                # Your design projects
│   └── env/                # Environment configuration
└── docs/                   # Documentation (optional)
```

**Set up the root directory**:

```bash
# Define your ASIC design root
export ASIC_DESIGN_ROOT="$HOME/Electronics"  # Adjust to your preference

# Create directory structure
mkdir -p $ASIC_DESIGN_ROOT/{outils,projets/env,docs}
```

**Add to ~/.zshrc**:

```bash
# Add this line to your ~/.zshrc
echo 'export ASIC_DESIGN_ROOT="$HOME/Electronics"' >> ~/.zshrc
source ~/.zshrc
```

Verify:
```bash
ls $ASIC_DESIGN_ROOT
# Should list: outils  projets  docs
```

---

## Docker Installation

### Why Docker?

**Simple answer**: There is no simple alternative for running ngspice with OSDI/Verilog-A support on macOS.

**Why not compile natively on macOS?**

*In this section "We" means Claude and I. The starting point of all this ihp-macosx-toolkit" is I was that 
upset upset and lost when trying to install open-vaf, that I requested the help of the machine.* 

*We* attempted native compilation of OpenVAF and OpenVAF-Reloaded. The results:
- Multiple incompatible library versions (Rust, LLVM, system dependencies)
- Different issues on different macOS versions
- Hours of debugging for version-specific configurations
- Solutions that work today break with the next macOS/Xcode update
- Even when successful, setups are fragile and non-portable

The effort to maintain native compilation scripts exceeds Docker integration effort. More importantly:
- Docker solutions are **durable** - they keep working across macOS updates
- Docker is **reproducible** - same environment for everyone
- Docker is **maintainable** - one Dockerfile vs. dozens of version-specific workarounds

### Install Docker Desktop

1. **Download**: https://www.docker.com/products/docker-desktop

2. **Install**: 
   - Open the downloaded `.dmg` file
   - Drag Docker to Applications
   - Launch Docker Desktop from Applications

3. **Wait for startup**:
   - Docker icon appears in menu bar (whale)
   - Wait until icon is stable (not animated)

4. **Verify**:
```bash
docker --version
# Should output: Docker version 24.x.x or later

docker info
# Should display Docker system info without errors
```

### Pull IIC-OSIC-TOOLS Image

**About IIC-OSIC-TOOLS**:
- **Origin**: Developed by IIC (Institute for Integrated Circuits) at Johannes Kepler University Linz, Austria
- **Project start**: 2020
- **Maturity**: Stable and actively maintained
- **Purpose**: Complete open-source EDA environment in a Docker container
- **Repository**: https://github.com/iic-jku/IIC-OSIC-TOOLS

```bash
# Download the image (~3-5 GB, may take 5-15 minutes)
docker pull hpretl/iic-osic-tools:latest
```

**What's in this image?**
- ngspice with OSDI support (Verilog-A models)
- OpenVAF for compiling Verilog-A to OSDI
- KLayout, Magic, Xschem (if needed via Docker)
- Pre-configured and tested environment

**Note**: While IIC-OSIC-TOOLS provides many tools, you may prefer to install some **natively** for better performance and integration (see [Optional Native Tools](#optional-native-tools)).

---

## PDK Installation

The Process Design Kit (PDK) contains device models, design rules, and technology files for the IHP SG13G2 130nm BiCMOS process.

### Download IHP-Open-PDK

**Using Git** (recommended):

```bash
cd $ASIC_DESIGN_ROOT/outils
git clone https://github.com/IHP-GmbH/IHP-Open-PDK.git
```

**Or download archive**:
1. Visit: https://github.com/IHP-GmbH/IHP-Open-PDK
2. Click "Code" → "Download ZIP"
3. Extract to `$ASIC_DESIGN_ROOT/outils/IHP-Open-PDK/`

### Verify PDK Structure

```bash
ls $ASIC_DESIGN_ROOT/outils/IHP-Open-PDK/ihp-sg13g2/libs.tech/

# You should see:
# klayout/  magic/  ngspice/  verilog-a/  xschem/
```

---

## Toolkit Installation

### Download ihp-macos-toolkit

**Using Git**:

```bash
cd $ASIC_DESIGN_ROOT/outils
git clone https://github.com/YOUR-USERNAME/ihp-macos-toolkit.git
```

**Or download archive** and extract to `$ASIC_DESIGN_ROOT/outils/ihp-macos-toolkit/`

### Make Scripts Executable

```bash
cd $ASIC_DESIGN_ROOT/outils/ihp-macos-toolkit
chmod +x scripts/*
```

---

## Environment Configuration

### Create Environment Configuration File

Create `$ASIC_DESIGN_ROOT/projets/env/zshrc_elec`:

```bash
cat > $ASIC_DESIGN_ROOT/projets/env/zshrc_elec << 'EOF'
#!/bin/zsh
# IHP SG13G2 Electronics Design Environment
# Edit paths below to match your system

# ASIC design root (adjust if needed)
export ASIC_DESIGN_ROOT="$HOME/Electronics"

# Toolkit location
export TOOLKIT_ROOT="$ASIC_DESIGN_ROOT/outils/ihp-macos-toolkit"

# PDK location  
export PDK_ROOT="$ASIC_DESIGN_ROOT/outils/IHP-Open-PDK"
export PDK="ihp-sg13g2"

# Add toolkit scripts to PATH
export PATH="$TOOLKIT_ROOT/scripts:$PATH"

# Load aliases
if [ -f "$TOOLKIT_ROOT/config/aliases.sh" ]; then
    source "$TOOLKIT_ROOT/config/aliases.sh"
fi

echo "✓ IHP SG13G2 environment loaded"
echo "  TOOLKIT_ROOT: $TOOLKIT_ROOT"
echo "  PDK_ROOT: $PDK_ROOT"
EOF
```

### Edit the Configuration File

**IMPORTANT**: Edit `zshrc_elec` to match your actual paths:

```bash
# Open for editing
nano $ASIC_DESIGN_ROOT/projets/env/zshrc_elec

# Verify and adjust the ASIC_DESIGN_ROOT path if different
# Save: Ctrl+O, Enter
# Exit: Ctrl+X
```

### Make Executable

```bash
chmod +x $ASIC_DESIGN_ROOT/projets/env/zshrc_elec
```

### Add to Your .zshrc

Add this to your `~/.zshrc`:

```bash
# IHP electronics environment
source $ASIC_DESIGN_ROOT/projets/env/zshrc_elec
```

Or use an alias for on-demand loading:

```bash
# IHP electronics environment (on-demand)
alias elec='source $ASIC_DESIGN_ROOT/projets/env/zshrc_elec'
```

### Reload Configuration

```bash
source ~/.zshrc

# Or if using alias
elec
```

### Verify Environment Variables

```bash
echo $TOOLKIT_ROOT
# Should display: /path/to/your/outils/ihp-macos-toolkit

echo $PDK_ROOT
# Should display: /path/to/your/outils/IHP-Open-PDK

echo $PDK
# Should display: ihp-sg13g2
```

**Troubleshooting**: If variables are not set:
1. Check that paths in `zshrc_elec` match your actual directory structure
2. Verify `source` command in `.zshrc` is correct
3. Reload: `source ~/.zshrc`
4. Check for syntax errors: `zsh -n $ASIC_DESIGN_ROOT/projets/env/zshrc_elec`

---

## Optional Native Tools

While Docker provides all necessary tools, you may prefer native installations for:
- Better performance
- Tighter OS integration
- Standalone usage outside Docker

### KLayout (Layout Viewer/Editor)

```bash
brew install klayout
```

Configure for IHP PDK:
```bash
# Add to zshrc_elec if not already present
export KLAYOUT_PATH="$HOME/.klayout:$PDK_ROOT/$PDK/libs.tech/klayout"
```

### ngspice (Native - without OSDI)

For quick simulations with classic SPICE models:

```bash
brew install ngspice
```
Some other day I will add a documentation about compiling ngspice for macosx. 
**Note**: Native macOS ngspice does NOT support OSDI/Verilog-A. Use `ngspice-docker` for Verilog-A models.

### Python Environment

For IHP-AnalogAcademy and mosplot:

```bash
# Install Python if needed
brew install python@3.9

# Create virtual environment
python3 -m venv $ASIC_DESIGN_ROOT/outils/venv_ihp
source $ASIC_DESIGN_ROOT/outils/venv_ihp/bin/activate

# Install packages
pip install mosplot matplotlib numpy scipy jupyter
```

---

## Verification

### 1. Check Scripts in PATH

```bash
which ngspice-docker
# Should show: .../ihp-macos-toolkit/scripts/ngspice-docker

which ngspice-docker-python
# Should show: .../ihp-macos-toolkit/scripts/ngspice-docker-python
```

### 2. Run Diagnostics

```bash
diagnose_ngspice.sh
# Should find Docker-based ngspice and report OSDI support
```

### 3. Test Basic Simulation - PSP103 MOSFET

```bash
cd $TOOLKIT_ROOT/snippets/03_psp103_mos
make run

# Should:
# - Load PSP103 OSDI model
# - Run DC sweep simulation  
# - Display ASCII plots
# - Create results.txt
```

**Success indicators**:
- ✅ ASCII plots displayed in terminal
- ✅ `results.txt` file created
- ✅ No error messages

**If this works**: Your environment is correctly configured for analog simulation!

### 4. Test Command-Line Python for Advanced Simulation - mosplot_mosfet

```bash
cd $TOOLKIT_ROOT/snippets/04_mosplot_mosfet

# Activate Python virtual environment
source $ASIC_DESIGN_ROOT/outils/venv_ihp/bin/activate

# Run mosplot extraction
make run
make plot
```

**Success indicators**:
- ✅ You get a lookup table with make run : nmos_lookup_table.npz
- ✅ You get a very pretty plot with make plot 
- ✅ No error messages

**If this works**: Your environment is correctly configured to unleash the power of the Python. 

### 5. Jupyter Python 
TBD

---

## Use Cases

This toolkit supports multiple IC design workflows. Each has specific tool requirements and verification snippets.

### 1. Analog Simulation

**Tools required**:
-  Docker (IIC-OSIC-TOOLS)
-  ngspice-docker / ngspice-docker-python
-  ihp-macos-toolkit
-  Optional: Jupyter, IHP-AnalogAcademy

**Verification snippets** (in order):
1. `snippets/03_psp103_mos/` - Basic MOSFET simulation (ngspice-docker, command line)
2. `snippets/04_mosplot_mosfet/` - Parameter extraction with mosplot (python intergration, command line)
3. ``snippets/06_bias_sweep_notebook/` - Quite interactive sweet pot finding (Jupyter & venved python kernel) (ongoing)
4. Schematic entry tools (future)
5. Layout and parameter extraction (future)

**Status**: ✅ Ready for use

### 2. ASIC and Digital Design

**Tools required**:
- LibreLane (via Nix)
- IHP SG13G2 standard cell library
- Digital verification tools

**Status**: 🔜 Future release

See: `docs/digital-flow.md` (coming soon)

### 3. VHDL/Verilog Design

**Tools required**:
- HDL simulators
- Synthesis tools
- LibreLane integration

**Status**: 🔜 Work in progress

---

## Troubleshooting

### Docker Issues

**Problem**: `Cannot connect to the Docker daemon`

**Solution**:
1. Launch Docker Desktop from Applications
2. Wait for Docker icon to stabilize in menu bar
3. Verify: `docker info`

---

**Problem**: `docker: command not found`

**Solution**:
1. Reinstall Docker Desktop
2. Verify `/usr/local/bin` is in PATH
3. Restart terminal

---

### Environment Variable Issues

**Problem**: `echo $TOOLKIT_ROOT` returns nothing

**Solutions**:
1. Check `zshrc_elec` paths match your actual directories:
   ```bash
   cat $ASIC_DESIGN_ROOT/projets/env/zshrc_elec
   ```

2. Verify file is sourced in `.zshrc`:
   ```bash
   grep "zshrc_elec" ~/.zshrc
   ```

3. Check for syntax errors:
   ```bash
   zsh -n $ASIC_DESIGN_ROOT/projets/env/zshrc_elec
   ```

4. Reload configuration:
   ```bash
   source ~/.zshrc
   ```

---

### PDK Issues

**Problem**: Models not found during simulation

**Solution**:
```bash
# Verify PDK structure
ls $PDK_ROOT/$PDK/libs.tech/verilog-a/

# Check for .osdi files
find $PDK_ROOT -name "*.osdi"

# If missing, compile models:
compile-va-models.sh
```

---

### Simulation Issues

**Problem**: OSDI library cannot be loaded

**Verify**:
1. Docker is running
2. OSDI file exists:
   ```bash
   ls $PDK_ROOT/$PDK/libs.tech/verilog-a/psp103/*.osdi
   ```
3. Using correct wrapper (`ngspice-docker` or `ngspice-docker-python`)

---

## What's Next?

After successful installation:

1. **Complete verification**: Run all test snippets in order
   - `03_psp103_mos` - Basic functionality
   - Additional snippets as they become available...

2. **Explore IHP-AnalogAcademy**: 
   - Clone: https://github.com/IHP-GmbH/IHP-AnalogAcademy
   - Module 0: Environment and basic characterization
   - Use `ngspice-docker-python` as simulator

3. **Start designing**:
   - Create project in `$ASIC_DESIGN_ROOT/projets/`
   - Follow workflow examples (coming soon)

---

## Getting Help

### Documentation

- **Environment Setup**: `docs/03_environment-setup.md` - Detailed configuration
- **Troubleshooting**: `docs/05_troubleshooting.md` - Common issues
- **Workflows**: `docs/04_workflows.md` - Design examples (coming soon)

### Diagnostic Tools

```bash
# Check ngspice installations
diagnose_ngspice.sh

# Verify environment
echo $TOOLKIT_ROOT
echo $PDK_ROOT
which ngspice-docker
```

### Community

- **IHP PDK**: https://github.com/IHP-GmbH/IHP-Open-PDK/issues
- **Toolkit**: https://github.com/YOUR-USERNAME/ihp-macos-toolkit/issues
- **FOSSi**: https://fossi-foundation.org/

---

## Summary

After following this guide, you should have:

✅ Docker Desktop installed and running  
✅ IHP-Open-PDK downloaded and configured  
✅ ihp-macos-toolkit installed with scripts in PATH  
✅ Environment variables correctly set  
✅ Basic analog simulation verified working

**Next steps**: Explore snippets, run IHP-AnalogAcademy tutorials, start your designs!

**Stay updated**: Watch this repository on GitHub (Watch → Custom → Releases) to get notified of fresh macOS tool integrations and hot snippets.


---

**Installation complete. Ready for IC design with IHP SG13G2.** 🚀
