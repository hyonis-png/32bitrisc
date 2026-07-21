`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2026 05:10:32 PM
// Design Name: 
// Module Name: cpu_top_tb
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

module cpu_top_tb;

logic clk;
logic rst;

cpu_top dut (
    .clk(clk),
    .rst(rst)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;

    // ============================
    // Reset
    // ============================
    repeat(3) @(posedge clk);

    rst = 0;

    // ============================
    // Let program execute
    // ============================
    repeat(50) @(posedge clk);

    // ============================
    // Check register values
    // ============================

    assert(dut.regfile_inst.regs[1] == 32'd5)
        else $fatal("x1 incorrect");

    assert(dut.regfile_inst.regs[2] == 32'd7)
        else $fatal("x2 incorrect");

    assert(dut.regfile_inst.regs[3] == 32'd12)
        else $fatal("x3 incorrect");

    $display("==================================");
    $display("CPU TOP TEST PASSED");
    $display("==================================");

    $finish;

end

endmodule