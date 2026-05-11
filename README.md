# Command Processor Module

Vivado FPGA project implementing a command processor module with an AXI-based block design, GPIO-mapped control/status registers, BRAM access, and Integrated Logic Analyzer support for hardware debugging.

## Tools
- Vivado 2022.1
- Verilog/SystemVerilog/VHDL
- AXI GPIO
- AXI BRAM Controller
- Block Memory Generator
- ILA

## Rebuilding the Project

Open Vivado, then run:

```tcl
source scripts/create_project.tcl
source scripts/cmd_proc_bd.tcl
```
