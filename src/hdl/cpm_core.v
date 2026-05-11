`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2026 09:31:51 PM
// Design Name: 
// Module Name: cpm_core
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


module cpm_core(
    input reset_n,
    input clk_sm,
    
    input [7:0] cmd_reg,
    input [7:0] offset_i,
    input [7:0] multiplier_i,
    input [31:0] bram_rd_dout,

    output reg[31:0] bram_rd_addr,
    output reg bram_rd_en,
    output reg[31:0] result
    );
   
    localparam IDLE = 3'b000;
    localparam ISSUE_READ = 3'b001;
    localparam WAIT_BRAM = 3'b010;
    localparam EXECUTE = 3'b011;
    localparam DONE = 3'b100;
    
    localparam READ = 3'b000;
    localparam COMPLEMENT = 3'b001;
    localparam SHIFT_LEFT = 3'b010;
    localparam SHIFT_RIGHT = 3'b011;
    localparam ADD = 3'b100;
    localparam SUBTRACT = 3'b101;
    localparam MULTIPLY = 3'b110;
    localparam MULTIPLY_ADD = 3'b111;
    
    reg[2:0] state, next_state;
    reg[2:0] opcode, address;
    reg[7:0] offset, multiplier;
    reg exec_ff1, exec_ff2, exec_ff2_prev;
    wire execute_rise;
    
    reg [31:0] bram_data_reg;
    
    always @(posedge clk_sm or negedge reset_n) begin
        if(!reset_n) begin
            state <= IDLE;
            exec_ff1 <= 1'b0;
            exec_ff2 <= 1'b0;
            exec_ff2_prev <= 1'b0;
            
            opcode <= 3'b000;
            address <= 3'b000;
            offset <= 8'd0;
            multiplier <= 8'd0;
            result <= 32'd0;
            bram_data_reg <= 32'd0;
        end else begin
            state <= next_state;
            exec_ff1 <= cmd_reg[0];
            exec_ff2 <= exec_ff1;
            exec_ff2_prev <= exec_ff2;
            
            if (state == WAIT_BRAM) begin
                bram_data_reg <= bram_rd_dout;
            end
            
            if (state == IDLE && execute_rise) begin
                opcode  <= cmd_reg[7:5];
                address <= cmd_reg[4:2];
                offset <= offset_i;
                multiplier <= multiplier_i;
            end

            if (state == EXECUTE) begin
                case (opcode)
                    READ: result <= bram_data_reg;
                    COMPLEMENT: result <= ~bram_data_reg;
                    SHIFT_LEFT: result <= bram_data_reg << 1;
                    SHIFT_RIGHT: result <= bram_data_reg >> 1;
                    ADD: result <= bram_data_reg + offset;
                    SUBTRACT: result <= bram_data_reg - offset;
                    MULTIPLY: result <= bram_data_reg * multiplier;
                    MULTIPLY_ADD: result <= (bram_data_reg * multiplier) + offset;
                    default: result <= 32'd0;
                endcase
            end
        end
    end
    
    assign execute_rise = exec_ff2 & ~exec_ff2_prev;
    
    
    always @(*) begin
        next_state = state;
        bram_rd_addr = {27'd0, address, 2'b00};
        bram_rd_en   = 1'b0;
        
        case(state)
            IDLE: begin
                bram_rd_addr = 32'd0;
                if (execute_rise) next_state = ISSUE_READ;
            end
            ISSUE_READ: begin
                bram_rd_en = 1'b1;
                next_state = WAIT_BRAM;
            end
            WAIT_BRAM: begin
                bram_rd_addr = {27'd0, address, 2'b00};
                bram_rd_en = 1'b1;
                next_state = EXECUTE;
            end
            EXECUTE: next_state = DONE;
            DONE:
                if(!exec_ff2) next_state = IDLE;
        endcase
    end
    
endmodule
