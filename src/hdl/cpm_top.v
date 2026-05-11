`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 03/06/2026 11:58:19 PM
//////////////////////////////////////////////////////////////////////////////////


module cpm_top(
    input sys_clock,
    input reset
    );
    
    wire [31:0] bram_rd_addr;
    wire bram_rd_clk;
    wire [31:0] bram_rd_din;
    wire [31:0] bram_rd_dout;
    wire bram_rd_en;
    wire bram_rd_rst;
    wire [3:0]  bram_rd_we;

    wire [7:0] gpio_cmdreg;
    wire [31:0]  gpio_rd;
    wire clk_sm;
    wire [7:0]  gpio_mult;
    wire [7:0]  gpio_offset;
    
    wire [2:0] state;
    
    cpm_bd cpm_bd_i (
        .BRAM_PORT_RD_addr(bram_rd_addr),
        .BRAM_PORT_RD_clk(clk_sm),
        .BRAM_PORT_RD_din(32'd0),
        .BRAM_PORT_RD_dout(bram_rd_dout),
        .BRAM_PORT_RD_en(bram_rd_en),
        .BRAM_PORT_RD_rst(1'b0),
        .BRAM_PORT_RD_we(4'b0000),
        .GPIO_CMDREG(gpio_cmdreg),
        .GPIO_RD(gpio_rd),
        .clk_sm(clk_sm),
        .gpio_mult(gpio_mult),
        .gpio_offset(gpio_offset),
        .reset(reset),
        .sys_clock(sys_clock)
    );
    
    cpm_core core_i (
        .reset_n(reset),
        .clk_sm(clk_sm),
        .cmd_reg(gpio_cmdreg),
        .offset_i(gpio_offset),
        .multiplier_i(gpio_mult),
        .bram_rd_dout(bram_rd_dout),
        .bram_rd_addr(bram_rd_addr),
        .bram_rd_en(bram_rd_en),
        .result(gpio_rd)
    );
    
endmodule
