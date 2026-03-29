# NMOS Parameter Extraction - IHP SG13G2
# Uses mosplot for MOSFET characterization

PYTHON = python3
VENV = $(ASIC_DESIGN_ROOT)/outils/venv_ihp

.PHONY: run clean plot help

help:
	@echo "NMOS Parameter Extraction Snippet"
	@echo ""
	@echo "Targets:"
	@echo "  make run    - Extract MOSFET parameters"
	@echo "  make plot   - Visualize results (requires matplotlib)"
	@echo "  make clean  - Remove generated files"

run:
	@echo "Activating venv and running extraction..."
	@mkdir -p tmp
	@bash -c "source $(ASIC_DESIGN_ROOT)/projets/env/zshrc_elec && \
	          source $(VENV)/bin/activate && \
	          TMPDIR='$(PWD)/tmp' $(PYTHON) extract_nmos.py"

plot: nmos_lookup_table.npz
	@echo "Plotting results..."
	@bash -c "source $(VENV)/bin/activate && $(PYTHON) plot_results.py"

clean:
	@rm -rf tmp tmp*.sp *.npz *.png *.log
	@echo "Cleaned"
