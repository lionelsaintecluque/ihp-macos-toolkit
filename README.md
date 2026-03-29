# IHP SG13G2 macOS Toolkit

Analog IC design with IHP SG13G2 BiCMOS PDK on macOS Intel.

## What It Does

- Clear path through installation for mac users (like me)
- Code snippets for easy testing, and inspiring simple and advanced usage
- SPICE simulation with Verilog-A/OSDI support (via Docker)
- MOSFET parameter extraction for lookup tables (mosplot)
- Amplifier characterization (AC, noise, bandwidth)
- More coming...

## Prerequisites

- macOS 10.15+ (Intel x86_64)
- Docker Desktop
- 20+ GB disk space

## Installation

Full guide: [docs/00_installation.md](docs/00_installation.md)
            [docs/01_environment-setup.md](docs/01_environment-setup.md)

**Quick version:**

1. Clone toolkit and IHP PDK
2. Install Docker Desktop
3. Pull `hpretl/iic-osic-tools:latest` image
4. Configure environment (see installation guide)
5. Run test: `cd snippets/03_psp103_mos && make run`

## Structure

```
ihp-macos-toolkit/
├── scripts/          # Wrapper scripts (ngspice-docker, etc.)
├── snippets/         # Working examples
├── cheats/           # Tool's cheat sheets
├── docs/             # Installation and configuration guides
└── man/              # Manpages for all scripts
```

## Scripts

- **ngspice-docker** - SPICE with OSDI support
- **ngspice-docker-python** - Python/mosplot integration
- **diagnose_ngspice.sh** - Installation diagnostic
- **compile-va-models.sh** - Verilog-A to OSDI compilation

All documented: `man ngspice-docker`

## Snippets

- **03_psp103_mos/** - Basic MOSFET simulation
- **04_mosplot_mosfet/** - Parameter extraction
- Others, ongoing... 

Each includes README, netlist, Makefile.

## Documentation

- [Installation](docs/00_installation.md) - Step-by-step setup
- [Environment](docs/01_environment-setup.md) - Shell configuration
- [More on snippets](snippets/snippets_TOC.md) -  Snippets list and description
- Manpages - `man <script-name>`

## Why Docker?

Native OpenVAF compilation on macOS is problematic (dependency conflicts, build fragility). Docker provides a reliable, reproducible environment at the cost of some overhead.

## Limitations

- Intel macOS only (untested on Apple Silicon)
- Python/SPICE communication via files (Docker constraint)
- ~10-20% performance overhead vs native

## License

Mostly 
- **Code**: MIT Licence
- **Documentation**: CC BY 4.0

## Links

- IHP SG13G2 PDK: https://github.com/IHP-GmbH/IHP-Open-PDK
- IIC-OSIC-TOOLS: https://github.com/iic-jku/IIC-OSIC-TOOLS
- mosplot/gmid: https://github.com/medwatt/gmid
