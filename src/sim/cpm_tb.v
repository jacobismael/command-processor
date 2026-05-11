`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 01:23:36 PM
// Design Name: 
// Module Name: cpm_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpm_tb;

    localparam READ = 3'b000;
    localparam COMPLEMENT = 3'b001;
    localparam SHIFT_LEFT = 3'b010;
    localparam SHIFT_RIGHT = 3'b011;
    localparam ADD = 3'b100;
    localparam SUBTRACT = 3'b101;
    localparam MULTIPLY = 3'b110;
    localparam MULTIPLY_ADD = 3'b111;

    reg clk_tb;
    reg rst_n_tb;
    
    wire [31:0] bram_rd_addr;
    wire bram_rd_clk;
    wire [31:0] bram_rd_din;
    reg [31:0] bram_rd_dout;
    wire bram_rd_en;
    wire bram_rd_rst;
    wire [3:0]  bram_rd_we;
    
    reg [7:0] gpio_cmdreg;
    wire [31:0]  gpio_rd;
    reg [7:0]  gpio_mult;
    reg [7:0]  gpio_offset;
    
    reg [2:0] opcode, address;
    reg command; 

    
    assign bram_rd_clk = clk_tb;
    assign bram_rd_din = 32'd0;
    assign bram_rd_rst = 1'b0;
    assign bram_rd_we  = 4'b0000;

    cpm_core core_i (
            .reset_n(rst_n_tb),
            .clk_sm(clk_tb),
            .cmd_reg(gpio_cmdreg),
            .offset_i(gpio_offset),
            .multiplier_i(gpio_mult),
            .bram_rd_dout(bram_rd_dout),
            .bram_rd_addr(bram_rd_addr),
            .bram_rd_en(bram_rd_en),
            .result(gpio_rd)
        );

    // Clock generation
    initial begin
        clk_tb = 0;
        forever #5 clk_tb = ~clk_tb; // Generate a clock with a period of 10 ns
    end
    
    always @(*)  gpio_cmdreg = {opcode, address, 1'b0, command};
    
    // Test stimulus
    initial begin
        // Initialize inputs
        rst_n_tb = 1;
        clk_tb = 0;
        opcode = 0;
        address = 0;
        command = 0;
        gpio_offset = 0;
        gpio_mult = 0;          // 0
    
        // Reset the system
        #10 rst_n_tb = 0;      // 10
        #20 rst_n_tb = 1;       // 30
    
//        // READ test
//        #20 opcode = READ;
//        address = 000;      // 50
//        bram_rd_dout = 32'habcd_0123;
//        #10 command = 1;        // 60
//        #10 command = 0;        // 70
        
//        #100 address = 111;      // 170
//        bram_rd_dout = 32'h1111_1111;
//        #10 command = 1;       // 180
//        #10 command = 0;        // 190
        
//        #100 opcode = COMPLEMENT;       // 290
//        address = 100;
//        bram_rd_dout = 32'h1111_1111;
//        #10 command = 1;        // 300
//        #10 command = 0;        // 310
        
//        #100 opcode = SHIFT_LEFT;       // 410
//        address = 101;
//        bram_rd_dout = 32'hffff_ffff;
//        #10 command = 1;        // 420
//        #10 command = 0;        // 430

//        #100 opcode = SHIFT_RIGHT;
//        address = 011;
//        bram_rd_dout = 32'hffff_ffff;
//        #10 command = 1;
//        #10 command = 0;

//        #100 opcode = ADD;
//        bram_rd_dout = 32'habcd_ef01;
//        gpio_offset = 8'h0a;
//        #10 command = 1; #10 command = 0;

//        #100 opcode = SUBTRACT;
//        bram_rd_dout = 32'habcd_ef01;
//        gpio_offset = 8'h0a;
//        #10 command = 1; #10 command = 0;

//        #100 opcode = MULTIPLY;
//        bram_rd_dout = 32'habcd_ef01;
//        gpio_mult = 8'h0a;
//        #10 command = 1; #10 command = 0;

        #100 opcode = MULTIPLY_ADD;
        bram_rd_dout = 32'habcd_ef01;
        gpio_mult = 8'h0a;
        gpio_offset = 8'hff;
        #10 command = 1; #10 command = 0;  // expect: b60b5709
        
        #100 $finish; // End the simulation
    end


endmodule
