#!/usr/bin/env python3
from multiprocessing import freeze_support
"""
NMOS Parameter Extraction using mosplot
IHP SG13G2 - MOSFET characterization

Quick extraction for basic output characteristics
"""

import os
import tempfile

# Force tmp directory to current working directory (visible to Docker)
tempfile.tempdir = os.path.join(os.getcwd(), 'tmp')
os.makedirs(tempfile.tempdir, exist_ok=True)

from mosplot.lookup_table_generator.simulators import NgspiceSimulator
from mosplot.lookup_table_generator import LookupTableGenerator, TransistorSweep

# Environment variables
PDK_ROOT = os.environ.get("PDK_ROOT")
PDK = os.environ.get("PDK")

if not PDK_ROOT or not PDK:
    print("Error: PDK_ROOT and PDK environment variables must be set")
    exit(1)

# Model library path
model_path = os.path.join(PDK_ROOT, PDK, "libs.tech/ngspice/models/cornerMOSlv.lib")

# Configure ngspice simulator
ngspice = NgspiceSimulator(
    simulator_path="ngspice-docker-python",
    temperature=27,
    lib_mappings=[
        (model_path, "mos_tt")
    ],
    mos_spice_symbols=("XM1", "n.xm1.nsg13_lv_nmos"),
    device_parameters={
        'w': 1e-5,
    },
    parameters_to_save=[
        'id', 'vth', 'gm', 'gds'
    ]
)

# Define sweep parameters (simplified for quick test)
sweep = TransistorSweep(
    mos_type='nmos',
    vgs=(0.3, 1.2, 0.3),    # 4 points: 0.3, 0.6, 0.9, 1.2V
    vds=(0, 1.2, 0.05),     # 25 points for smooth curves  
    vbs=(0, 0, 1),          # Only VBS=0
    length=[130e-9],        # Single length for quick test
)

if __name__ == '__main__':
    freeze_support()
    
    print("Generating NMOS lookup table...")
    print(f"Type: {sweep.mos_type}")
    print(f"Lengths: {sweep.length}")
    print("")
    
    generator = LookupTableGenerator(
        description="IHP SG13G2 NMOS - Quick Test",
        simulator=ngspice,
        model_sweeps={
            "sg13_lv_nmos": sweep  
        },
        n_process=1
    )
    
    output_file = "nmos_lookup_table"
    generator.build(output_file)

    print("")
    print(f"✓ Lookup table saved to: {output_file}.npz")
    print("")
    print("Run 'make plot' to visualize results")
