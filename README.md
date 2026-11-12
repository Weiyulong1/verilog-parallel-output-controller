# Parallel Output Controller in Verilog

A digital-systems course project that moves bytes between a processor model and a printer model. The controller exposes a one-byte buffer and a status register. It supports polling through SR7 and interrupt-driven service through IRQ, and transfers data with the RDY/TR handshake.

| Path | Contents |
| --- | --- |
| rtl/poc.v | Output controller |
| rtl/processor.v and rtl/printer.v | Behavioral host and peripheral models |
| rtl/top.v | Integration of the three modules |
| sim/sim.v | Original waveform demonstration. The clock runs continuously and IRQ mode switching is commented out. |
| sim/tb_poc.sv | Self-checking test for polling, IRQ, backpressure, and byte order at the controller interface |

## Run the simulation

From a terminal with the Vivado 2023.2 simulation tools on PATH, run the following from the repository root.

```text
xvlog rtl/poc.v
xvlog -sv sim/tb_poc.sv
xelab tb_poc -s tb_poc_sim
xsim tb_poc_sim -runall
```

For the original integration waveform, add the RTL files and sim/sim.v to a Vivado simulation project, set sim as the simulation top, and run for a finite interval. The printer and processor are behavioral models. Project results describe logic simulation.
