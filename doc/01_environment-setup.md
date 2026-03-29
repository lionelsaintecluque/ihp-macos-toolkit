# Environment Setup Guide

Complete guide for configuring your shell environment to use the IHP macOS Toolkit.

## Overview

The toolkit requires several environment variables and PATH modifications to work correctly. 
This guide complements 00_installation.md and shows you how to configure your `.zshrc` for optimal workflow.

---

## Prerequisites

- macOS (Intel tested, Apple Silicon untested)
- Zsh shell (default on macOS)
- IHP-Open-PDK installed
- Docker Desktop installed and running

---

## Directory Structure

Example of directory structure :

```
~/ACME/OPENHW/
├── outils/
│   └── ihp-macos-toolkit/      # Stable toolkit (production use)
├── projets/
│   ├── ihp-macos-toolkit/      # Development toolkit (optional)
│   ├── env/
│   │   └── zshrc_elec          # Electronics environment config
│   └── LNA/                     # Your design projects
└── sandbox/                     # Temporary experiments
```

**Note**: Adjust paths according to your setup 
I changed the name of my company to ACME, for privacy (Reference to Looney Tunes).
I changed my user name to Bug's Bunny's. 
OPENHW the directory for community related stuff. 
As you can see I use French words. The only important thing is consistency in environment variables.

---

## Step-by-Step Configuration

### Step 1: Define Core Variables

Add these to your `~/.zshrc`:

```bash
# ==============================================================================
# IHP SG13G2 Toolkit Environment
# ==============================================================================

# Toolkit location (stable version)
export TOOLKIT_ROOT="$HOME/ACME/OPENHW/outils/ihp-macos-toolkit"

# PDK location
export PDK_ROOT="$HOME/ACME/OPENHW/IHP-Open-PDK"
export PDK="ihp-sg13g2"

# Add toolkit scripts to PATH
export PATH="$TOOLKIT_ROOT/scripts:$PATH"
```

**Important**: Use `$HOME` instead of hardcoded paths like `/Users/yourname/` for portability.

### Step 2: Source Aliases (Optional but Recommended)

```bash
# Load toolkit aliases (spice, etc.)
if [ -f "$TOOLKIT_ROOT/config/aliases.sh" ]; then
    source "$TOOLKIT_ROOT/config/aliases.sh"
fi
```

### Step 3: Configure TMPDIR for Docker Integration

When using Python scripts (like IHP-AnalogAcademy), temporary files need to be in a location accessible to Docker.

**Important**: Set TMPDIR in your **project directory**, not globally in `.zshrc`.

```bash
# In your project directory, before running Python simulation scripts
cd ~/your/project/directory
mkdir -p tmp
export TMPDIR="$PWD/tmp"

# Then run your simulation
python3 simulation_script.py
```

The `tmp/` directory location is up to you. Common approaches:
- `~/your/project/tmp/` - One temp dir per project
- `~/your/project/simulations/tmp/` - Organized under simulations
- Any location you prefer, as long as it's in your project tree

### Step 4: Optional - Development Environment

For development work on the toolkit itself:

```bash
# Temporarily override TOOLKIT_ROOT for development
# Run this in your terminal when developing, not in .zshrc
export PATH="$HOME/ACME/OPENHW/projets/ihp-macos-toolkit/scripts:$PATH"
```

---

## Complete .zshrc Example

Here's a complete example of the relevant section in your `.zshrc`:

```bash
# ==============================================================================
# IHP SG13G2 BiCMOS Design Environment
# ==============================================================================

# Toolkit paths
export TOOLKIT_ROOT="$HOME/ACME/OPENHW/outils/ihp-macos-toolkit"
export PDK_ROOT="$HOME/ACME/OPENHW/IHP-Open-PDK"
export PDK="ihp-sg13g2"

# KLayout configuration
export KLAYOUT_PATH="$HOME/.klayout:$PDK_ROOT/$PDK/libs.tech/klayout"

# LLVM (for native tool compilation if needed)
export LLVM_CONFIG="/usr/local/opt/llvm/bin/llvm-config"
export PATH="/usr/local/opt/llvm/bin:$PATH"

# Add toolkit scripts to PATH
export PATH="$TOOLKIT_ROOT/scripts:$PATH"

# Load aliases
if [ -f "$TOOLKIT_ROOT/config/aliases.sh" ]; then
    source "$TOOLKIT_ROOT/config/aliases.sh"
fi

# ==============================================================================
# End IHP Environment
# ==============================================================================
```

---

## Alternative: Modular Configuration

For a cleaner `.zshrc`, create a dedicated config file:

### Create `~/ACME/OPENHW/projets/env/zshrc_elec`:

```bash
#!/bin/zsh
# Electronics design environment configuration
# Source this file: source ~/ACME/OPENHW/projets/env/zshrc_elec

# Toolkit paths
export TOOLKIT_ROOT="$HOME/ACME/OPENHW/outils/ihp-macos-toolkit"
export PDK_ROOT="$HOME/ACME/OPENHW/IHP-Open-PDK"
export PDK="ihp-sg13g2"

# KLayout
export KLAYOUT_PATH="$HOME/.klayout:$PDK_ROOT/$PDK/libs.tech/klayout"

# Add toolkit to PATH
export PATH="$TOOLKIT_ROOT/scripts:$PATH"

# Load aliases
if [ -f "$TOOLKIT_ROOT/config/aliases.sh" ]; then
    source "$TOOLKIT_ROOT/config/aliases.sh"
fi

echo "✓ IHP SG13G2 environment loaded"
echo "  TOOLKIT_ROOT: $TOOLKIT_ROOT"
echo "  PDK_ROOT: $PDK_ROOT"
```

### Then in your `~/.zshrc`, just add:

```bash
# IHP electronics environment
alias elec='source $HOME/ACME/OPENHW/projets/env/zshrc_elec'
```

**Usage**:
```bash
elec  # Activate electronics environment
```

---

## Verification

After configuring, verify your setup:

### 1. Check Variables

```bash
echo $TOOLKIT_ROOT
echo $PDK_ROOT
echo $PDK
```

All should display correct paths.

### 2. Check PATH

```bash
which ngspice-docker
which ngspice-docker-python
```

Both should point to `$TOOLKIT_ROOT/scripts/...`

### 3. Check Aliases (if configured)

```bash
alias spice
```

Should show: `spice='ngspice-docker'`

### 4. Run Diagnostics

```bash
diagnose_ngspice.sh
```

Should find ngspice installations and report their capabilities.

---

## Switching Between Stable and Development

### Using Stable Version (Daily Work)

Default configuration in `.zshrc` points to stable:

```bash
export TOOLKIT_ROOT="$HOME/ACME/OPENHW/outils/ihp-macos-toolkit"
```

### Testing Development Version (Terminal Session Only)

In a specific terminal where you want to test changes:

```bash
# Override PATH for this session only
export PATH="$HOME/ACME/OPENHW/projets/ihp-macos-toolkit/scripts:$PATH"

# Verify
which ngspice-docker
# Should now point to projets/ instead of outils/
```

**Important**: This override only affects the current terminal session. New terminals will use the stable version from `.zshrc`.

---

## Common Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `TOOLKIT_ROOT` | Location of ihp-macos-toolkit | `$HOME/ACME/OPENHW/outils/ihp-macos-toolkit` |
| `PDK_ROOT` | Location of IHP-Open-PDK | `$HOME/ACME/OPENHW/IHP-Open-PDK` |
| `PDK` | PDK variant name | `ihp-sg13g2` |
| `KLAYOUT_PATH` | KLayout technology files | `$HOME/.klayout:$PDK_ROOT/$PDK/libs.tech/klayout` |
| `TMPDIR` | Temporary directory (project-specific) | `$PWD/tmp` |

---

## Troubleshooting

### Variables Not Set

**Symptom**: `echo $TOOLKIT_ROOT` shows nothing

**Solution**: 
1. Check `.zshrc` syntax (no typos)
2. Reload: `source ~/.zshrc`
3. Verify file is being read: `echo $SHELL` (should be `/bin/zsh`)

### Scripts Not Found

**Symptom**: `command not found: ngspice-docker`

**Solutions**:
1. Check PATH: `echo $PATH | grep toolkit`
2. Verify scripts exist: `ls $TOOLKIT_ROOT/scripts/`
3. Check execute permissions: `ls -l $TOOLKIT_ROOT/scripts/ngspice-docker`
4. Reload: `source ~/.zshrc`

### Wrong Version Being Used

**Symptom**: Testing dev changes but stable version runs

**Solution**:
```bash
# Check which is being used
which ngspice-docker

# If it's the wrong one, prepend dev path
export PATH="$HOME/ACME/OPENHW/projets/ihp-macos-toolkit/scripts:$PATH"

# Verify
which ngspice-docker
```

### Environment Persists After Closing Terminal

**Symptom**: Dev PATH override persists to new terminals

**Issue**: You likely added the override to `.zshrc` instead of running it in the terminal

**Solution**: Remove the dev PATH from `.zshrc`, keep only stable configuration there

---

## Best Practices

### ✅ Do

- Use `$HOME` instead of absolute paths
- Keep stable config in `.zshrc`
- Use session-only overrides for development
- Document any custom modifications
- Test in a new terminal after editing `.zshrc`

### ❌ Don't

- Hardcode usernames in paths (`/Users/bugs/...`)
- Add development paths to `.zshrc` permanently
- Mix toolkit versions in the same PATH
- Forget to reload after editing (`.zshrc` changes need `source ~/.zshrc`)

---

## Intel vs Apple Silicon

This toolkit is currently **tested on Intel Mac (x86_64)** only.

**If you're on Apple Silicon (M1/M2/M3)**:
- Most scripts should work
- Homebrew prefix may differ: `/opt/homebrew` instead of `/usr/local`
- LLVM paths may need adjustment
- Please report success/issues to help improve compatibility

**To check your architecture**:
```bash
uname -m
# x86_64 = Intel
# arm64 = Apple Silicon
```

---

## Next Steps

After configuring your environment:

1. **Verify Installation**: Run `diagnose_ngspice.sh`
2. **Test Basic Simulation**: Try the PSP103 snippet
3. **Compile VA Models**: Run `compile-va-models.sh`
4. **Read Workflow Guide**: See `docs/workflows.md`

---

## Getting Help

- Check `docs/troubleshooting.md` for common issues
- Run `diagnose_ngspice.sh` to identify problems
- Review script output carefully for error messages
- Verify all environment variables are set correctly

---

**Remember**: Environment configuration is the foundation. Take time to set it up correctly once, and everything else becomes easier.
