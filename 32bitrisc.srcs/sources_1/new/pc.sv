`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 03:55:01 PM
// Design Name: 
// Module Name: pc
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

module pc(
    input logic clk,
    input logic rst,
    input logic stall,
    input word_t next_pc,
    output logic [31:0] pc_out
);

always_ff @(posedge clk) begin
    if (rst)
        pc_out <= 32'h00000000;
    else if (!stall)
        pc_out <= next_pc;
end

endmodule