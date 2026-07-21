`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2026 10:16:21 PM
// Design Name: 
// Module Name: id_ex_reg_tb
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

module id_ex_reg_tb;

logic clk;
logic rst;
logic flush;

// ID inputs
word_t      id_pc;
word_t      id_rs1_data;
word_t      id_rs2_data;
word_t      id_imm;

reg_addr_t  id_rd;
reg_addr_t  id_rs1;
reg_addr_t  id_rs2;

alu_op_t    id_alu_control;

logic       id_reg_write;
logic       id_alu_src;
logic       id_mem_read;
logic       id_mem_write;
logic       id_mem_to_reg;
logic       id_jal_to_reg;
logic       id_jump;
logic       id_jalr;
logic       id_branch_eq;
logic       id_branch_ne;

// EX outputs
word_t      ex_pc;
word_t      ex_rs1_data;
word_t      ex_rs2_data;
word_t      ex_imm;

reg_addr_t  ex_rd;
reg_addr_t  ex_rs1;
reg_addr_t  ex_rs2;

alu_op_t    ex_alu_control;

logic       ex_reg_write;
logic       ex_alu_src;
logic       ex_mem_read;
logic       ex_mem_write;
logic       ex_mem_to_reg;
logic       ex_jal_to_reg;
logic       ex_jump;
logic       ex_jalr;
logic       ex_branch_eq;
logic       ex_branch_ne;

id_ex_reg dut (
    .clk(clk),
    .rst(rst),
    .flush(flush),

    .id_pc(id_pc),
    .id_rs1_data(id_rs1_data),
    .id_rs2_data(id_rs2_data),
    .id_imm(id_imm),

    .id_rd(id_rd),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),

    .id_alu_control(id_alu_control),

    .id_reg_write(id_reg_write),
    .id_alu_src(id_alu_src),
    .id_mem_read(id_mem_read),
    .id_mem_write(id_mem_write),
    .id_mem_to_reg(id_mem_to_reg),
    .id_jal_to_reg(id_jal_to_reg),

    .id_jump(id_jump),
    .id_jalr(id_jalr),

    .id_branch_eq(id_branch_eq),
    .id_branch_ne(id_branch_ne),

    .ex_pc(ex_pc),
    .ex_rs1_data(ex_rs1_data),
    .ex_rs2_data(ex_rs2_data),
    .ex_imm(ex_imm),

    .ex_rd(ex_rd),
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),

    .ex_alu_control(ex_alu_control),

    .ex_reg_write(ex_reg_write),
    .ex_alu_src(ex_alu_src),
    .ex_mem_read(ex_mem_read),
    .ex_mem_write(ex_mem_write),
    .ex_mem_to_reg(ex_mem_to_reg),
    .ex_jal_to_reg(ex_jal_to_reg),

    .ex_jump(ex_jump),
    .ex_jalr(ex_jalr),

    .ex_branch_eq(ex_branch_eq),
    .ex_branch_ne(ex_branch_ne)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;
    flush = 0;

    id_pc = 0;
    id_rs1_data = 0;
    id_rs2_data = 0;
    id_imm = 0;

    id_rd = 0;
    id_rs1 = 0;
    id_rs2 = 0;

    id_alu_control = ALU_ADD;

    id_reg_write = 0;
    id_alu_src = 0;
    id_mem_read = 0;
    id_mem_write = 0;
    id_mem_to_reg = 0;
    id_jal_to_reg = 0;
    id_jump = 0;
    id_jalr = 0;
    id_branch_eq = 0;
    id_branch_ne = 0;

    // ====================================
    // RESET TEST
    // ====================================
    @(posedge clk);

    assert(ex_pc == 0)
        else $fatal("Reset failed");

    rst = 0;

    // ====================================
    // NORMAL TRANSFER TEST
    // ====================================
    id_pc          = 32'h4;
    id_rs1_data    = 32'd10;
    id_rs2_data    = 32'd20;
    id_imm         = 32'd100;

    id_rd          = 5'd3;
    id_rs1         = 5'd1;
    id_rs2         = 5'd2;

    id_reg_write   = 1;
    id_alu_src     = 1;

    @(posedge clk);

    assert(ex_pc == 32'h4)
        else $fatal("PC transfer failed");

    assert(ex_rs1_data == 32'd10)
        else $fatal("RS1 transfer failed");

    assert(ex_rs2_data == 32'd20)
        else $fatal("RS2 transfer failed");

    assert(ex_rd == 5'd3)
        else $fatal("RD transfer failed");

    // ====================================
    // FLUSH TEST
    // ====================================
    flush = 1;

    @(posedge clk);

    assert(ex_reg_write == 0)
        else $fatal("Flush failed");

    assert(ex_rd == 0)
        else $fatal("Flush RD failed");

    assert(ex_pc == 0)
        else $fatal("Flush PC failed");

    flush = 0;

    $display("==================================");
    $display("ID/EX REGISTER TEST PASSED");
    $display("==================================");

    $finish;

end

endmodule