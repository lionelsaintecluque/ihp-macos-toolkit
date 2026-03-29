# PSP103 MOSFET Test - IHP SG13G2
# Minimal Verilog-A/OSDI verification

NGSPICE = ngspice-docker

.PHONY: run clean

run:
	which $(NGSPICE)
	@$(NGSPICE) test_psp103.sp

clean:
	@rm -f results.txt *.raw *.log
