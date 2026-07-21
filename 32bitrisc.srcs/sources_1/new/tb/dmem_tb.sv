`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2026 11:36:56 AM
// Design Name: 
// Module Name: dmem_tb
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

module dmem_tb;

logic clk;
logic mem_read;
logic mem_write;

word_t addr;
word_t write_data;
word_t read_data;

dmem dut (
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
);

always #5 clk = ~clk;

initial begin

    clk = 0;

    mem_read  = 0;
    mem_write = 0;

    addr       = 0;
    write_data = 0;

    // =====================================
    // WRITE TEST
    // =====================================
    addr       = 32'd8;
    write_data = 32'd99;

    mem_write = 1;

    @(posedge clk);

    mem_write = 0;

    // =====================================
    // READ TEST
    // =====================================
    mem_read = 1;

    #1;

    assert(read_data == 32'd99)
        else $fatal("DMEM read failed");

    // =====================================
    // READ DISABLED TEST
    // =====================================
    mem_read = 0;

    #1;

    assert(read_data == 32'd0)
        else $fatal("DMEM read disable failed");

    // =====================================
    // SECOND WRITE TEST
    // =====================================
    addr       = 32'd12;
    write_data = 32'hDEADBEEF;

    mem_write = 1;

    @(posedge clk);

    mem_write = 0;
    mem_read  = 1;

    #1;

    assert(read_data == 32'hDEADBEEF)
        else $fatal("Second write/read failed");

    $display("==================================");
    $display("DMEM TEST PASSED");
    $display("==================================");

    $finish;

end

endmodule