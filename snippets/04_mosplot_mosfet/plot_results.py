#!/usr/bin/env python3
"""
Simple visualization of MOSFET lookup table
"""

import numpy as np
import matplotlib.pyplot as plt
import sys
import os

# Check if results file exists
if not os.path.exists('nmos_lookup_table.npz'):
    print("Error: nmos_lookup_table.npz not found")
    print("Run 'make run' first to generate data")
    sys.exit(1)

# Load data
data = np.load('nmos_lookup_table.npz', allow_pickle=True)
lookup = data['lookup_table'].item()
nmos_data = lookup['sg13_lv_nmos']

# Extract arrays
id_array = nmos_data['id']      # Shape: (n_length, n_vbs, n_vgs, n_vds)
vgs = nmos_data['vgs']
vds = nmos_data['vds']
vbs = nmos_data['vbs']
lengths = nmos_data['length']

print(f"Data shape: {id_array.shape}")
print(f"Lengths: {lengths}")
print(f"VGS range: {vgs[0]} to {vgs[-1]} V")
print(f"VDS range: {vds[0]} to {vds[-1]} V")

# Plot: ID vs VDS for different VGS (first length, VBS=0)
fig, ax = plt.subplots(figsize=(10, 6))

# Find VBS=0 index
vbs_idx = np.argmin(np.abs(vbs - 0))
length_idx = 0  # First length

# Plot all available VGS values
for vgs_idx in range(len(vgs)):
    id_curve = id_array[length_idx, vbs_idx, vgs_idx, :] * 1e3  # Convert to mA
    ax.plot(vds, id_curve, label=f'VGS={vgs[vgs_idx]:.1f}V', marker='o', markersize=4)

ax.set_xlabel('VDS (V)')
ax.set_ylabel('ID (mA)')
ax.set_title(f'NMOS Output Characteristics\nL={lengths[length_idx]*1e9:.0f}nm, VBS={vbs[vbs_idx]:.1f}V, W=10µm')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
output_file = 'nmos_characteristics.png'
plt.savefig(output_file, dpi=150)
print(f"\n✓ Plot saved to: {output_file}")
plt.show()
