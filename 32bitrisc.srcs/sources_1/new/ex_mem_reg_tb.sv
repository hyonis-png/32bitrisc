`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2026 10:22:58 PM
// Design Name: 
// Module Name: ex_mem_reg_tb
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

module ex_mem_reg_tb;

logic clk;
logic rst;
logic stall;

// EX inputs
word_t      ex_alu_result;
word_t      ex_write_data;
word_t      ex_pc_plus4;

reg_addr_t  ex_rd;

logic       ex_reg_write;
logic       ex_mem_read;
logic       ex_mem_write;
logic       ex_mem_to_reg;
logic       ex_jal_to_reg;

// MEM outputs
word_t      mem_alu_result;
word_t      mem_write_data;
word_t      mem_pc_plus4;

reg_addr_t  mem_rd;

logic       mem_reg_write;
logic       mem_mem_read;
logic       mem_mem_write;
logic       mem_mem_to_reg;
logic       mem_jal_to_reg;

ex_mem_reg dut (
    .clk(clk),
    .rst(rst),
    .stall(stall),

    .ex_alu_result(ex_alu_result),
    .ex_write_data(ex_write_data),
    .ex_pc_plus4(ex_pc_plus4),
    .ex_rd(ex_rd),

    .ex_reg_write(ex_reg_write),
    .ex_mem_read(ex_mem_read),
    .ex_mem_write(ex_mem_write),
    .ex_mem_to_reg(ex_mem_to_reg),
    .ex_jal_to_reg(ex_jal_to_reg),

    .mem_alu_result(mem_alu_result),
    .mem_write_data(mem_write_data),
    .mem_pc_plus4(mem_pc_plus4),
    .mem_rd(mem_rd),

    .mem_reg_write(mem_reg_write),
    .mem_mem_read(mem_mem_read),
    .mem_mem_write(mem_mem_write),
    .mem_mem_to_reg(mem_mem_to_reg),
    .mem_jal_to_reg(mem_jal_to_reg)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    stall = 0;

    ex_alu_result = 0;
    ex_write_data = 0;
    ex_pc_plus4   = 0;
    ex_rd         = 0;

    ex_reg_write  = 0;
    ex_mem_read   = 0;
    ex_mem_write  = 0;
    ex_mem_to_reg = 0;
    ex_jal_to_reg = 0;

    // Reset
    @(posedge clk);

    assert(mem_alu_result == 0) else $fatal("Reset alu_result failed");
    assert(mem_write_data == 0) else $fatal("Reset write_data failed");
    assert(mem_pc_plus4   == 0) else $fatal("Reset pc_plus4 failed");
    assert(mem_rd         == 0) else $fatal("Reset rd failed");
    assert(mem_reg_write  == 0) else $fatal("Reset reg_write failed");

    rst = 0;

    // Store instruction crossing EX/MEM
    ex_alu_result = 32'h00001000;
    ex_write_data = 32'hDEADBEEF;
    ex_pc_plus4   = 32'h00000008;
    ex_rd         = 5'd0;

    ex_reg_write  = 0;
    ex_mem_read   = 0;
    ex_mem_write  = 1;
    ex_mem_to_reg = 0;
    ex_jal_to_reg = 0;

    @(posedge clk);

    assert(mem_alu_result == 32'h00001000) else $fatal("SW alu_result failed");
    assert(mem_write_data == 32'hDEADBEEF) else $fatal("SW write_data failed");
    assert(mem_mem_write  == 1'b1)         else $fatal("SW mem_write failed");
    assert(mem_mem_read   == 1'b0)         else $fatal("SW mem_read failed");
    assert(mem_reg_write  == 1'b0)         else $fatal("SW reg_write failed");

    // Load instruction crossing EX/MEM
    ex_alu_result = 32'h00002000;
    ex_write_data = 32'h0;
    ex_pc_plus4   = 32'h0000000C;
    ex_rd         = 5'd5;

    ex_reg_write  = 1;
    ex_mem_read   = 1;
    ex_mem_write  = 0;
    ex_mem_to_reg = 1;
    ex_jal_to_reg = 0;

    @(posedge clk);

    assert(mem_alu_result == 32'h00002000) else $fatal("LW alu_result failed");
    assert(mem_rd         == 5'd5)         else $fatal("LW rd failed");
    assert(mem_reg_write  == 1'b1)         else $fatal("LW reg_write failed");
    assert(mem_mem_read   == 1'b1)         else $fatal("LW mem_read failed");
    assert(mem_mem_write  == 1'b0)         else $fatal("LW mem_write failed");
    assert(mem_mem_to_reg == 1'b1)         else $fatal("LW mem_to_reg failed");

    // JAL/JALR link crossing EX/MEM
    ex_alu_result = 32'h00000080;
    ex_write_data = 32'h0;
    ex_pc_plus4   = 32'h00000024;
    ex_rd         = 5'd1;

    ex_reg_write  = 1;
    ex_mem_read   = 0;
    ex_mem_write  = 0;
    ex_mem_to_reg = 0;
    ex_jal_to_reg = 1;

    @(posedge clk);

    assert(mem_pc_plus4   == 32'h00000024) else $fatal("JAL pc_plus4 failed");
    assert(mem_rd         == 5'd1)         else $fatal("JAL rd failed");
    assert(mem_reg_write  == 1'b1)         else $fatal("JAL reg_write failed");
    assert(mem_jal_to_reg == 1'b1)         else $fatal("JAL jal_to_reg failed");

    // Stall test
    stall = 1;

    ex_alu_result = 32'hAAAA5555;
    ex_pc_plus4   = 32'hBBBBCCCC;
    ex_rd         = 5'd10;

    @(posedge clk);

    assert(mem_alu_result != 32'hAAAA5555)
        else $fatal("Stall failed: alu_result changed");

    assert(mem_pc_plus4 != 32'hBBBBCCCC)
        else $fatal("Stall failed: pc_plus4 changed");

    stall = 0;

    $display("==================================");
    $display("EX/MEM REGISTER TEST PASSED");
    $display("==================================");

    $finish;
end

endmodule