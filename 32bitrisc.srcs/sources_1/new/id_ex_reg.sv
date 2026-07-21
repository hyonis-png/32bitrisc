`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2026 10:10:13 PM
// Design Name: 
// Module Name: id_ex_reg
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
import cpu_types_pkg::*;

module id_ex_reg (
    input logic clk,
    input logic rst,
    input logic flush,
    input logic stall,

    input word_t      id_pc,
    input word_t      id_rs1_data,
    input word_t      id_rs2_data,
    input word_t      id_imm,
    input reg_addr_t  id_rd,
    input reg_addr_t  id_rs1,
    input reg_addr_t  id_rs2,
    input alu_op_t    id_alu_control,

    input logic       id_reg_write,
    input logic       id_alu_src,
    input logic       id_mem_read,
    input logic       id_mem_write,
    input logic       id_mem_to_reg,
    input logic       id_jal_to_reg,
    input logic       id_jump,
    input logic       id_jalr,
    input logic       id_branch_eq,
    input logic       id_branch_ne,

    output word_t     ex_pc,
    output word_t     ex_rs1_data,
    output word_t     ex_rs2_data,
    output word_t     ex_imm,
    output reg_addr_t ex_rd,
    output reg_addr_t ex_rs1,
    output reg_addr_t ex_rs2,
    output alu_op_t   ex_alu_control,

    output logic      ex_reg_write,
    output logic      ex_alu_src,
    output logic      ex_mem_read,
    output logic      ex_mem_write,
    output logic      ex_mem_to_reg,
    output logic      ex_jal_to_reg,
    output logic      ex_jump,
    output logic      ex_jalr,
    output logic      ex_branch_eq,
    output logic      ex_branch_ne
);

always_ff @(posedge clk) begin

    if (rst || flush) begin
        ex_pc          <= 32'd0;
        ex_rs1_data    <= 32'd0;
        ex_rs2_data    <= 32'd0;
        ex_imm         <= 32'd0;

        ex_rd          <= 5'd0;
        ex_rs1         <= 5'd0;
        ex_rs2         <= 5'd0;

        ex_alu_control <= ALU_ADD;

        ex_reg_write   <= 1'b0;
        ex_alu_src     <= 1'b0;
        ex_mem_read    <= 1'b0;
        ex_mem_write   <= 1'b0;
        ex_mem_to_reg  <= 1'b0;
        ex_jal_to_reg  <= 1'b0;

        ex_jump        <= 1'b0;
        ex_jalr        <= 1'b0;

        ex_branch_eq   <= 1'b0;
        ex_branch_ne   <= 1'b0;
    end
else if (!stall) begin
        ex_pc          <= id_pc;
        ex_rs1_data    <= id_rs1_data;
        ex_rs2_data    <= id_rs2_data;
        ex_imm         <= id_imm;

        ex_rd          <= id_rd;
        ex_rs1         <= id_rs1;
        ex_rs2         <= id_rs2;

        ex_alu_control <= id_alu_control;

        ex_reg_write   <= id_reg_write;
        ex_alu_src     <= id_alu_src;
        ex_mem_read    <= id_mem_read;
        ex_mem_write   <= id_mem_write;
        ex_mem_to_reg  <= id_mem_to_reg;
        ex_jal_to_reg  <= id_jal_to_reg;

        ex_jump        <= id_jump;
        ex_jalr        <= id_jalr;

        ex_branch_eq   <= id_branch_eq;
        ex_branch_ne   <= id_branch_ne;
    end

end

endmodule