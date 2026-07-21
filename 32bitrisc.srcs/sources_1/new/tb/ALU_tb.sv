`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2026 11:28:02 AM
// Design Name: 
// Module Name: ALU_tb
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

module ALU_tb;

word_t A;
word_t B;
word_t result;

logic alu_less;
logic alu_more;

alu_op_t alu_control;

ALU dut (
    .A(A),
    .B(B),
    .alu_control(alu_control),

    .result(result),
    .alu_less(alu_less),
    .alu_more(alu_more)
);

initial begin

    // ====================================
    // ADD
    // ====================================
    A = 32'd10;
    B = 32'd7;

    alu_control = ALU_ADD;
    #1;

    assert(result == 32'd17)
        else $fatal("ADD failed");

    // ====================================
    // SUB
    // ====================================
    alu_control = ALU_SUB;
    #1;

    assert(result == 32'd3)
        else $fatal("SUB failed");

    // ====================================
    // AND
    // ====================================
    alu_control = ALU_AND;
    #1;

    assert(result == (A & B))
        else $fatal("AND failed");

    // ====================================
    // OR
    // ====================================
    alu_control = ALU_OR;
    #1;

    assert(result == (A | B))
        else $fatal("OR failed");

    // ====================================
    // XOR
    // ====================================
    alu_control = ALU_XOR;
    #1;

    assert(result == (A ^ B))
        else $fatal("XOR failed");

    // ====================================
    // SLT FALSE
    // ====================================
    alu_control = ALU_SLT;
    #1;

    assert(result == 32'd0)
        else $fatal("SLT false failed");

    // ====================================
    // SLT TRUE
    // ====================================
    A = 32'd5;
    B = 32'd10;

    alu_control = ALU_SLT;
    #1;

    assert(result == 32'd1)
        else $fatal("SLT true failed");

    // ====================================
    // BRANCH COMPARISON TEST
    // ====================================

    // A < B
    assert(alu_less == 1'b1)
        else $fatal("alu_less failed");

    assert(alu_more == 1'b0)
        else $fatal("alu_more failed");

    // A == B
    A = 32'd10;
    B = 32'd10;

    #1;

    assert(alu_less == 1'b0)
        else $fatal("equal less failed");

    assert(alu_more == 1'b0)
        else $fatal("equal more failed");

    // A > B
    A = 32'd20;
    B = 32'd10;

    #1;

    assert(alu_less == 1'b0)
        else $fatal("greater less failed");

    assert(alu_more == 1'b1)
        else $fatal("greater more failed");

    $display("==================================");
    $display("ALU TEST PASSED");
    $display("==================================");

    $finish;

end

endmodule
