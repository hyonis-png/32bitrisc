`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2026 11:00:16 PM
// Design Name: 
// Module Name: fetch_tb
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


typedef logic [31:0] vaddr_t;
typedef logic [31:0] instr_t;

module fetch_tb;

logic clk;
logic rst;
logic stall;

vaddr_t next_pc;
vaddr_t pc_out;
instr_t instruction;

pc dut_pc (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .next_pc(next_pc),
    .pc_out(pc_out)
);

imem dut_imem (
    .addr(pc_out),
    .instruction(instruction)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    stall = 0;
    next_pc = 0;

    #10;
    rst = 0;

    assert(instruction == 32'h00500093)
        else $fatal("Fetch instruction 0 failed");

    next_pc = 32'h00000004;
    #10;
    assert(instruction == 32'h00700113)
        else $fatal("Fetch instruction 1 failed");

    next_pc = 32'h00000008;
    #10;
    assert(instruction == 32'h002081B3)
        else $fatal("Fetch instruction 2 failed");

    $display("FETCH TEST PASSED");
    $finish;
end

endmodule