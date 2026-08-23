# Testbench – Configurable CAM with Masked Pattern Matching and Priority Resolution

This directory contains the simulation and verification environment for the **Configurable CAM with Masked Pattern Matching and Priority Resolution** Tiny Tapeout project.

The testbench uses **Cocotb** and Verilog to verify the functionality of the CAM at RTL and, where applicable, at gate level.

## Testbench Files

- `tb.v` – Verilog testbench and DUT interface
- `test.py` – Cocotb-based functional tests
- `Makefile` – Simulation and gate-level simulation configuration
- `requirements.txt` – Python dependencies
- `tb.gtkw` – GTKWave waveform configuration
- `gate_level_netlist.v` – Gate-level netlist used for post-hardening simulation

## What is Verified?

The verification environment checks the major functional blocks of the CAM, including:

- Reset operation
- CAM write operation
- Exact pattern matching
- No-match detection
- Masked pattern matching
- Match detection
- Lowest-address priority resolution
- Match address generation
- One-clock search operation

## RTL Simulation

The simulation uses the RTL source specified in the Makefile and runs the Cocotb testbench.

The generated waveform can be inspected using GTKWave or Surfer.

## Gate-Level Simulation

After the design has been hardened, the generated gate-level netlist can be used for post-implementation verification.

Copy the generated gate-level netlist into this directory as:

gate_level_netlist.v

The gate-level simulation can then be run using:

make -B GATES=yes

The gate-level simulation uses the SKY130 standard-cell library models and the hardened netlist to verify that the implemented design maintains the expected functionality.

## Waveform Output

The default simulation generates an FST waveform.

To generate a VCD waveform instead, modify the testbench to use:

$dumpfile("tb.vcd");

and run:

make -B FST=

This generates:

tb.vcd

instead of:

tb.fst

## Viewing Waveforms

GTKWave

To view the FST waveform:

gtkwave tb.fst tb.gtkw

For a VCD waveform:

gtkwave tb.vcd

Surfer

The FST waveform can also be viewed using Surfer:

surfer tb.fst

## Expected Verification Behavior

During simulation, the CAM should:

Store 8-bit input data at the selected CAM address.

Compare the 8-bit search value against the stored CAM entries.

Detect an exact match when the search value is present.

Report no match when the search value is not present.

Perform masked pattern matching when a mask is applied.

Ignore the bits for which the mask is set.

Resolve multiple matching entries by selecting the lowest matching address.

Register the match result and match address on one rising clock edge.

The waveform can be used to observe the CAM write operation, search operation, match detection, masked matching, and lowest-address priority behavior.

The Cocotb testbench verifies the following representative cases:

A5 → exact match at address 0.

F0 → exact match at address 2.

55 → no match.

A0 with mask 0F → masked match at address 0.

AA stored at addresses 3 and 5 → priority match at address 3.

The gate-level testbench verifies that the same CAM functionality is maintained after synthesis and physical implementation.

## Tiny Tapeout Implementation

The design was subsequently hardened using the Tiny Tapeout SKY130 digital flow for the Tiny Tapeout SKY26C shuttle.

The final GDSII layout was successfully generated and passed the Tiny Tapeout implementation checks.

The hardened design was verified using gate-level simulation, DRC, and LVS.

The DRC verification completed with zero errors.

The LVS verification reported that the circuits match uniquely.

For complete project information, architecture, implementation details, and physical-design results, see [main project README](../README.md).

## References

- [Tiny Tapeout](https://tinytapeout.com/)
- [Cocotb Documentation](https://docs.cocotb.org/en/stable/)
- [Tiny Tapeout HDL Testing](https://tinytapeout.com/hdl/testing/)
