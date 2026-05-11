# Command Processor Module

Vivado FPGA project implementing a command processor module with an AXI-based block design, GPIO-mapped control/status registers, BRAM access, and Integrated Logic Analyzer support for hardware debugging.

## Building

Open Vivado, then run:

```tcl
source scripts/build.tcl
open_project build/final.xpr
```

## Running CPM Instructions

After generating the bitstream and programming the FPGA, load the CPM command script:

```tcl
source scripts/run_cpm.tcl
```

### Processor Tcl Commands

| Command | Parameters | What it does |
|---|---|---|
| `cpm_write_bram <index> <data>` | `index`: BRAM word index `0-7`<br>`data`: 32-bit value | Writes a 32-bit value into BRAM at `0xC0000000 + 4*index`. |
| `cpm_exec <opcode> <addr> [offset] [multiplier]` | `opcode`: operation code<br>`addr`: BRAM word index `0-7`<br>`offset`: optional 8-bit offset<br>`multiplier`: optional 8-bit multiplier | Executes one processor instruction, clears the execute bit, and reads the result. |
| `cpm_read_result` | None | Reads the 32-bit result register from GPIO. |
| `cpm_cmd <opcode> <addr> <exec>` | `opcode`: 3-bit opcode<br>`addr`: BRAM word index `0-7`<br>`exec`: `0` or `1` | Builds the raw 8-bit command register value. Usually `cpm_exec` should be used instead. |

### Processor Opcodes

| Tcl Variable | Opcode | Operation | Description |
|---|---:|---|---|
| `$OP_READ` | `000` | Read | Returns the selected BRAM word unchanged. |
| `$OP_COMP` | `001` | Complement | Bitwise complements the selected BRAM word. |
| `$OP_SHL` | `010` | Shift left | Shifts the selected BRAM word left by 1 bit. |
| `$OP_SHR` | `011` | Shift right | Shifts the selected BRAM word right by 1 bit. |
| `$OP_ADD` | `100` | Add | Adds the offset value to the selected BRAM word. |
| `$OP_SUB` | `101` | Subtract | Subtracts the offset value from the selected BRAM word. |
| `$OP_MUL` | `110` | Multiply | Multiplies the selected BRAM word by the multiplier value. |
| `$OP_MADD` | `111` | Multiply-add | Multiplies the selected BRAM word by the multiplier, then adds the offset. |


### AXI Address Map

| Address | Register | Description |
|---:|---|---|
| `0x40000000` | `CMDREG` | Command register. Used to send opcode, BRAM address, and execute bit. |
| `0x40000008` | `GPIO_RD` | Result register. Used to read the processor output. |
| `0x40010000` | `GPIO_OFFSET` | Offset register. Used by ADD, SUBTRACT, and MULTIPLY-ADD. |
| `0x40010008` | `GPIO_MULT` | Multiplier register. Used by MULTIPLY and MULTIPLY-ADD. |
| `0xC0000000` | BRAM base | Shared BRAM base address. Word `n` is at `0xC0000000 + 4*n`. |