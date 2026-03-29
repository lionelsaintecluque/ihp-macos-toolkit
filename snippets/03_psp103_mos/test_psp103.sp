* ==============================================================================
* PSP103 MOSFET Test - IHP SG13G2
* Minimal Verilog-A OSDI verification netlist
* ==============================================================================

* Test circuit - simple DC sweep
VGS G 0 DC 0.9
VDS D 0 DC 1.2

* MOSFET model (loaded from OSDI)
.model nmos PSPNQS103VA type=1

* Device instance - NMOS transistor
* N<name> <drain> <gate> <source> <bulk> <model> W=<width> L=<length>
N1 D G 0 0 nmos W=1u L=0.13u

* Simulation
.control
pre_osdi /pdk/ihp-sg13g2/libs.tech/verilog-a/psp103/psp103_nqs.osdi
dc VDS 0 1.2 0.1
asciiplot v(d)
asciiplot -i(vds)
print all > results.txt
.endc

.end
