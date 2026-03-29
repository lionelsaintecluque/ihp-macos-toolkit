# MOSFET Parameter Extraction with mosplot

Extract key MOSFET parameters for circuit design using mosplot (via gmid package).

## What it does

Performs comprehensive characterization of IHP SG13G2 NMOS transistors:

- **Sweeps**: VDS, VGS, VBS across multiple channel lengths
- **Extracts**: 
  - ID (drain current)
  - gm (transconductance)
  - gds (output conductance) 
  - Vth (threshold voltage)
  - Vdsat (saturation voltage)
- **Outputs**: Lookup table (CSV) for design optimization

## Prerequisites

- IHP SG13G2 environment configured (see `docs/02_installation.md`)
- Python venv with gmid installed
- `ngspice-docker-python` in PATH
- TMPDIR set in project directory

## Usage

```bash
# Set up temporary directory
mkdir -p tmp
export TMPDIR="$PWD/tmp"

# Run extraction
make run

# Visualize results (optional)
make plot

# Clean up
make clean
```

## Expected Output

### Terminal Output
```
Generating NMOS lookup table...
Model: sg13_lv_nmos
Lengths: [1.3e-07, 2e-07, 5e-07, 1e-06]

[Simulation progress...]

✓ Lookup table saved to: nmos_lookup_table.csv
  Total data points: 2000+

Key parameters extracted:
  - id:    Drain current
  - gm:    Transconductance
  - gds:   Output conductance
  - vth:   Threshold voltage
  - vdsat: Saturation voltage
```

### Generated Files

- `nmos_lookup_table.csv` - Complete parameter database
- `nmos_characteristics.png` - Visualization plots (if `make plot` run)
- `tmp/` - Temporary simulation files

## Understanding the Data

### Lookup Table Columns

| Column | Description | Typical Range |
|--------|-------------|---------------|
| `vgs` | Gate-source voltage | 0 - 1.2 V |
| `vds` | Drain-source voltage | 0 - 1.2 V |
| `vbs` | Bulk-source voltage | -0.6 - 0 V |
| `l` | Channel length | 130nm - 1µm |
| `id` | Drain current | µA - mA range |
| `gm` | Transconductance | mS range |
| `gds` | Output conductance | µS range |
| `vth` | Threshold voltage | ~0.4 V |
| `vdsat` | Saturation voltage | V range |

### Key Design Metrics

**gm/ID ratio**: Efficiency factor
- High gm/ID: Weak inversion, low power
- Low gm/ID: Strong inversion, high speed

**fT (transit frequency)**: gm/(2π·Cgs)
- Indicator of high-frequency performance
- Critical for RF and high-speed analog

## Using Results for Design

### 1. Circuit Sizing

Find optimal W/L for given specs:
```python
import pandas as pd

df = pd.read_csv('nmos_lookup_table.csv')

# Example: Find dimensions for target gm
target_gm = 1e-3  # 1 mS
candidates = df[abs(df['gm'] - target_gm) < 0.1e-3]
print(candidates[['l', 'vgs', 'vds', 'gm', 'id']])
```

### 2. Operating Point Selection

Trade-off gm/ID vs speed:
```python
# Moderate inversion: good balance
df['gm_id'] = df['gm'] / df['id']
sweet_spot = df[(df['gm_id'] > 10) & (df['gm_id'] < 20)]
```

### 3. Corner Analysis

Run extraction for FF, SS corners:
```python
# Modify model_path in extract_nmos.py:
# "mos_ff": path_to_ff_corner
# "mos_ss": path_to_ss_corner
```

## Customization

Edit `extract_nmos.py` to modify:

```python
# Sweep ranges
vds_max=1.2,      # Reduce for low-voltage designs
vgs_max=1.2,

# Lengths to characterize
lengths=[130e-9, 500e-9, 1e-6],

# Temperature
temperature=27,   # Try -40, 27, 85 for corners
```

## Performance

**Typical run time**: 5-15 minutes
- Depends on: number of sweep points, channel lengths
- Runs in Docker, so some overhead

**Data size**: ~2000-5000 points typical
- CSV file: few hundred KB

## Troubleshooting

### Error: "mosplot not found"

```bash
# Install gmid in venv
source $ASIC_DESIGN_ROOT/outils/venv_ihp/bin/activate
pip install git+https://github.com/medwatt/gmid.git
```

### Error: "ngspice-docker-python: command not found"

```bash
# Check PATH
which ngspice-docker-python

# Should be in $TOOLKIT_ROOT/scripts/
# If not, reload environment
source ~/projets/env/zshrc_elec
```

### Error: "log.txt not found"

```bash
# Set TMPDIR in project directory
mkdir -p tmp
export TMPDIR="$PWD/tmp"
```

### Simulation hangs or errors

- Check Docker is running
- Verify PDK_ROOT and PDK are set
- Ensure OSDI models are compiled

## Next Steps

- Try different corners (FF, SS)
- Characterize PMOS (`sg13_lv_pmos`)
- Extract at different temperatures
- Use lookup tables for circuit optimization

## References

- **mosplot**: https://github.com/medwatt/gmid
- **IHP-AnalogAcademy**: Module 0 tutorials
- **IHP SG13G2 Docs**: https://ihp-open-pdk-docs.readthedocs.io/
