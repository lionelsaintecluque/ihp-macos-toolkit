# IHP macOS Toolkit - License

This project uses dual licensing:

## Code - MIT License

All executable code, scripts, and build files are licensed under MIT:
- Scripts in `scripts/`
- Python code and Makefiles in `snippets/`
- Configuration files
- m4 macros and SPICE templates
- Everything that is obviously code

**"Obviously code"** means: files written to be processed by software (compiled, executed, simulated, etc.) and files called by that software.

See [LICENSE-MIT](LICENSE-MIT.txt) for the full license text.

## Documentation - CC BY 4.0

All documentation and educational content are licensed under Creative Commons Attribution 4.0:
- All `.md` files (README, docs/, snippets/*/README.md)
- Manpages in `man/`
- Comments and explanatory content
- All files that are not obviously code

**Example**: Even though Markdown is processed by software, it is primarily written to be read by humans who can understand it perfectly with just `cat xxx.md`. Markdown is not "obviously code."

See [LICENSE-CC-BY-4.0](LICENSE-CC-BY-4.0.txt) for the full license text.

## Third-Party Components

This project integrates with many third-party components by design. Each retains its original license. Please refer to individual projects for their licensing terms.

**Examples include** (but are not limited to):
- IHP SG13G2 PDK
- Docker images (hpretl/iic-osic-tools)
- ngspice
- Python libraries (NumPy, matplotlib, pandas, etc.)
