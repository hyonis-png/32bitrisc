`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2026 10:33:43 PM
// Design Name: 
// Module Name: ALU
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

module ALU (
    input word_t A,
    input word_t B,
    input alu_op_t alu_control,
    output word_t result,
    output logic alu_less, // ◄ NEW SIGNAL HERE
    output logic alu_more
);

always_comb begin
    // Default values
    result   = 32'd0;
    
    // FIX: Calculate 'alu_less' combinationally using signed math
    alu_less = ($signed(A) < $signed(B)); 
    alu_more = ($signed(A) > $signed(B));

    case (alu_control)
        ALU_ADD:  result = A + B;
        ALU_SUB:  result = A - B;
        ALU_AND:  result = A & B;
        ALU_OR:   result = A | B;
        ALU_XOR:  result = A ^ B;
        ALU_SLL:  result = A << B[4:0];
        ALU_SRL:  result = A >> B[4:0];
        ALU_SRA:  result = $signed(A) >>> B[4:0];
        ALU_SLT:  result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
        ALU_SLTU: result = (A < B) ? 32'd1 : 32'd0;
        default:  result = 32'd0;
    endcase
end

endmodule
    
