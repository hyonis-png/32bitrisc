`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2026 07:42:40 PM
// Design Name: 
// Module Name: regfile_tb
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

module regfile_tb;

logic clk;
logic rst;
logic reg_write;

reg_addr_t rs1;
reg_addr_t rs2;
reg_addr_t rd;

word_t write_data;
word_t read_data1;
word_t read_data2;

regfile dut (
    .clk(clk),
    .rst(rst),
    .reg_write(reg_write),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),

    .write_data(write_data),

    .read_data1(read_data1),
    .read_data2(read_data2)
);

// ==========================================
// Helper Task
// ==========================================
task check_equal(
    input logic [31:0] actual,
    input logic [31:0] expected,
    input string msg
);
begin
    assert(actual == expected)
    else
        $fatal(
            "%s failed. Expected=%0d Actual=%0d",
            msg,
            expected,
            actual
        );
end
endtask

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;
    reg_write = 0;

    rs1 = 0;
    rs2 = 0;
    rd  = 0;

    write_data = 0;

    // ==========================================
    // Reset Test
    // ==========================================
    #12;
    rst = 0;

    assert(dut.regs[0] == 32'd0)
        else $fatal("x0 reset failed");

    assert(dut.regs[1] == 32'd0)
        else $fatal("Reset failed");

    // ==========================================
    // Manual preload
    // ==========================================
    dut.regs[1] = 32'd10;
    dut.regs[2] = 32'd7;

    rs1 = 5'd1;
    rs2 = 5'd2;

    #1;

    check_equal(
        read_data1,
        32'd10,
        "Read port 1"
    );

    check_equal(
        read_data2,
        32'd7,
        "Read port 2"
    );

    // ==========================================
    // Write Test
    // ==========================================
    reg_write  = 1;
    rd         = 5'd5;
    write_data = 32'd42;

    @(negedge clk);

    assert(dut.regs[5] == 32'd42)
        else $fatal("Write failed");

    // ==========================================
    // x0 Protection Test
    // ==========================================
    rd         = 5'd0;
    write_data = 32'hDEADBEEF;

    @(negedge clk);

    assert(dut.regs[0] == 32'd0)
        else $fatal("x0 modified");

    // ==========================================
    // Read Back Written Register
    // ==========================================
    reg_write = 0;

    rs1 = 5'd5;

    #1;

    check_equal(
        read_data1,
        32'd42,
        "Read-back"
    );

    $display("==================================");
    $display("REGFILE TEST PASSED");
    $display("==================================");

    $finish;

end

endmodule