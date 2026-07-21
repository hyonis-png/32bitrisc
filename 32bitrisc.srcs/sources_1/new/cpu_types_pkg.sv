`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2026 10:46:52 PM
// Design Name: 
// Module Name: cpu_types_pkg
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


package cpu_types_pkg;

    typedef logic [31:0] word_t;
    typedef logic [31:0] instr_t;
    typedef logic [4:0] reg_addr_t;

    typedef enum logic [4:0] {
        ALU_ADD   = 5'd0,
        ALU_SUB   = 5'd1,
        ALU_AND   = 5'd2,
        ALU_OR    = 5'd3,
        ALU_XOR   = 5'd4,
        ALU_SLT   = 5'd5,
        ALU_SLTU  = 5'd6,
        ALU_SLL   = 5'd7,
        ALU_SRL   = 5'd8,
        ALU_SRA   = 5'd9,

        ALU_PASS_B = 5'd10,   // useful for LUI
        ALU_EQ     = 5'd11,   // branch compare
        ALU_NE     = 5'd12,
        ALU_LT     = 5'd13,
        ALU_GE     = 5'd14,
        ALU_LTU    = 5'd15,
        ALU_GEU    = 5'd16
    } alu_op_t;

endpackage