# ============================================================
# CPM Hardware Test Commands
# Run after programming the FPGA bitstream.
# ============================================================

# AXI memory map
set CMDREG_ADDR  0x40000000
set RESULT_ADDR  0x40000008
set OFFSET_ADDR  0x40010000
set MULT_ADDR    0x40010008
set BRAM_BASE    0xC0000000

# Opcodes from cpm_core.v
set OP_READ      0
set OP_COMP      1
set OP_SHL       2
set OP_SHR       3
set OP_ADD       4
set OP_SUB       5
set OP_MUL       6
set OP_MADD      7

# Get JTAG AXI master
set axi [lindex [get_hw_axis] 0]

if {$axi eq ""} {
    puts "ERROR: No JTAG AXI master found. Program the FPGA first, then try again."
    return
}

set txn_id 0

proc axi_write32 {addr data} {
    global axi txn_id
    incr txn_id

    set name "wr_$txn_id"
    set addr_hex [format "%08X" $addr]
    set data_hex [format "%08X" [expr {$data & 0xFFFFFFFF}]]

    create_hw_axi_txn -force $name $axi -type WRITE -address $addr_hex -data $data_hex
    run_hw_axi [get_hw_axi_txns $name]
    delete_hw_axi_txn [get_hw_axi_txns $name]
}

proc axi_read32 {addr} {
    global axi txn_id
    incr txn_id

    set name "rd_$txn_id"
    set addr_hex [format "%08X" $addr]

    create_hw_axi_txn -force $name $axi -type READ -address $addr_hex
    run_hw_axi [get_hw_axi_txns $name]

    # Vivado prints the read result in the Tcl console.
    # This also shows the transaction properties.
    report_property [get_hw_axi_txns $name]

    delete_hw_axi_txn [get_hw_axi_txns $name]
}

proc cpm_cmd {opcode addr exec} {
    return [expr {(($opcode & 0x7) << 5) | (($addr & 0x7) << 2) | ($exec & 0x1)}]
}

proc cpm_write_bram {index data} {
    global BRAM_BASE

    if {$index < 0 || $index > 7} {
        puts "ERROR: BRAM index must be 0-7"
        return
    }

    set addr [expr {$BRAM_BASE + 4*$index}]
    axi_write32 $addr $data
}

proc cpm_read_result {} {
    global RESULT_ADDR
    axi_read32 $RESULT_ADDR
}

proc cpm_exec {opcode addr {offset 0} {multiplier 0}} {
    global CMDREG_ADDR OFFSET_ADDR MULT_ADDR

    # Write arithmetic operands
    axi_write32 $OFFSET_ADDR $offset
    axi_write32 $MULT_ADDR $multiplier

    # Issue command with execute bit high
    set cmd [cpm_cmd $opcode $addr 1]
    axi_write32 $CMDREG_ADDR $cmd

    # Give FSM time to run
    after 10

    # Clear execute bit so another command can run
    axi_write32 $CMDREG_ADDR [expr {$cmd & 0xFE}]

    # Give GPIO/result time to settle
    after 10

    # Read result
    cpm_read_result
}
