`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2026 11:07:06 PM
// Design Name: 
// Module Name: mem_wb_reg
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

module mem_wb_reg (
    input logic clk,
    input logic rst,
    input logic stall,

    // Inputs from MEM
    input word_t      mem_alu_result,
    input word_t      mem_read_data,
    input word_t      mem_pc_plus4,

    input reg_addr_t  mem_rd,

    input logic       mem_reg_write,
    input logic       mem_mem_to_reg,
    input logic       mem_jal_to_reg,

    // Outputs to WB
    output word_t      wb_alu_result,
    output word_t      wb_read_data,
    output word_t      wb_pc_plus4,

    output reg_addr_t  wb_rd,

    output logic       wb_reg_write,
    output logic       wb_mem_to_reg,
    output logic       wb_jal_to_reg
);

always_ff @(posedge clk) begin

    if (rst) begin
        wb_alu_result <= 32'd0;
        wb_read_data  <= 32'd0;
        wb_pc_plus4   <= 32'd0;

        wb_rd         <= 5'd0;

        wb_reg_write  <= 1'b0;
        wb_mem_to_reg <= 1'b0;
        wb_jal_to_reg <= 1'b0;
    end
    else if (!stall) begin
        wb_alu_result <= mem_alu_result;
        wb_read_data  <= mem_read_data;
        wb_pc_plus4   <= mem_pc_plus4;

        wb_rd         <= mem_rd;

        wb_reg_write  <= mem_reg_write;
        wb_mem_to_reg <= mem_mem_to_reg;
        wb_jal_to_reg <= mem_jal_to_reg;
    end

end

endmodule