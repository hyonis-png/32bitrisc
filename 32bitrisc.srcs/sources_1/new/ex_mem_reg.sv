`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2026 10:20:58 PM
// Design Name: 
// Module Name: ex_mem_reg
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

`timescale 1ns / 1ps
import cpu_types_pkg::*;

module ex_mem_reg (
    input logic clk,
    input logic rst,
    input logic stall,

    input word_t      ex_alu_result,
    input word_t      ex_write_data,
    input word_t      ex_pc_plus4,
    input reg_addr_t  ex_rd,

    input logic       ex_reg_write,
    input logic       ex_mem_read,
    input logic       ex_mem_write,
    input logic       ex_mem_to_reg,
    input logic       ex_jal_to_reg,

    output word_t      mem_alu_result,
    output word_t      mem_write_data,
    output word_t      mem_pc_plus4,
    output reg_addr_t  mem_rd,

    output logic       mem_reg_write,
    output logic       mem_mem_read,
    output logic       mem_mem_write,
    output logic       mem_mem_to_reg,
    output logic       mem_jal_to_reg
);

always_ff @(posedge clk) begin

    if (rst) begin
        mem_alu_result <= 32'd0;
        mem_write_data <= 32'd0;
        mem_pc_plus4   <= 32'd0;

        mem_rd         <= 5'd0;

        mem_reg_write  <= 1'b0;
        mem_mem_read   <= 1'b0;
        mem_mem_write  <= 1'b0;
        mem_mem_to_reg <= 1'b0;
        mem_jal_to_reg <= 1'b0;
    end
    else if (!stall) begin
        mem_alu_result <= ex_alu_result;
        mem_write_data <= ex_write_data;
        mem_pc_plus4   <= ex_pc_plus4;

        mem_rd         <= ex_rd;

        mem_reg_write  <= ex_reg_write;
        mem_mem_read   <= ex_mem_read;
        mem_mem_write  <= ex_mem_write;
        mem_mem_to_reg <= ex_mem_to_reg;
        mem_jal_to_reg <= ex_jal_to_reg;
    end

end

endmodule