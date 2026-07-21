`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2026 11:32:35 AM
// Design Name: 
// Module Name: regfiles
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

module regfile(
    input logic clk,
    input logic rst,
    input logic reg_write,

    input reg_addr_t rs1,
    input reg_addr_t rs2,
    input reg_addr_t rd,

    input word_t write_data,

    output word_t read_data1,
    output word_t read_data2,
    output word_t debug_x8,
    output word_t debug_x5 // ◄ 1. ADD THIS PORT HERE
);

word_t regs [0:31];

// ◄ 2. ADD THIS LINE: Continuously pass out register 4's data
assign debug_x5 = regs[5]; 
assign debug_x8 = regs[8];

assign read_data1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
assign read_data2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

always_ff @(negedge clk) begin
    if (rst) begin
        for (int i = 0; i < 32; i++) begin
            regs[i] <= 32'd0; 
        end
    end else if (reg_write && rd != 5'd0) begin
        regs[rd] <= write_data;
    end
end 

endmodule