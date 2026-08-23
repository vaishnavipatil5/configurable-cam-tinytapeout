# Testbench – Configurable CAM with Masked Pattern Matching and Priority Resolution

This directory contains the simulation and verification environment for the **Configurable CAM with Masked Pattern Matching and Priority Resolution** Tiny Tapeout SKY26C project.

The testbench uses **Cocotb** and Verilog to verify the functionality of the CAM at RTL and, where applicable, at gate level.

## Testbench Files

- `tb.v` – Verilog testbench and DUT interface
- `test.py` – Cocotb-based functional tests
- `Makefile` – Simulation and gate-level simulation configuration
- `requirements.txt` – Python dependencies
- `tb.gtkw` – GTKWave waveform configuration
- `gate_level_netlist.v` – Gate-level netlist used for post-hardening simulation

## What is Verified?

The verification environment checks the major functional operations of the CAM, including:

- Reset operation
- CAM write operation
- Exact-match search
- No-match search
- Masked pattern matching
- Match detection
- Priority resolution
- Address generation
- One-clock search operation

## RTL Simulation

The simulation uses the RTL source specified in the Makefile and runs the Cocotb testbench.

The generated waveform can be inspected using GTKWave or Surfer.

## Gate-Level Simulation

After the design has been hardened, the generated gate-level netlist can be used for post-implementation verification.

Copy the generated gate-level netlist into this directory as:

`gate_level_netlist.v`

The gate-level simulation can then be run using:

```bash
make -B GATES=yes
