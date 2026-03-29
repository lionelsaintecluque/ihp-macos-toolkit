# PSP103 MOSFET Test

Minimal test netlist verifying Verilog-A/OSDI functionality with IHP SG13G2 PDK.

## What it does

Simulates a simple NMOS transistor (PSP103 model) using:
- Verilog-A model compiled to OSDI
- ngspice running in Docker
- IHP SG13G2 process parameters

## Prerequisites

- Docker installed and running
- `PDK_ROOT` environment variable set
- IHP-Open-PDK installed

## Usage

```bash
# Set PDK location
export PDK_ROOT=/path/to/IHP-Open-PDK

# Run simulation
make run

# Clean results
make clean
```

## Files

- `test_psp103.sp` - SPICE netlist
- `ngspice-docker` - Wrapper script for Docker-based ngspice
- `Makefile` - Automation
- `results.txt` - Simulation output (generated)

## What to expect

The simulation:
1. Loads PSP103 Verilog-A model via OSDI
2. Sweeps VDS from 0 to 1.2V (VGS=0.9V)
3. Plots Ids-Vds curve in ASCII
4. Saves results to `results.txt`

Expected output: ~430µA drain current at VDS=1.2V, VGS=0.9V

## Troubleshooting

**Error: PDK_ROOT not set**
```bash
export PDK_ROOT=/your/path/to/IHP-Open-PDK
```

**Error: Docker not running**
- Launch Docker Desktop
- Wait for icon to stabilize

**Error: OSDI library not found**
- Verify PDK installation
- Check OSDI file exists: `$PDK_ROOT/ihp-sg13g2/libs.tech/verilog-a/psp103/psp103_nqs.osdi`

## Notes

- This uses Docker for reproducibility across macOS versions
- The PDK is mounted at `/pdk` inside the container
- Native macOS OSDI support requires complex OpenVAF compilation
