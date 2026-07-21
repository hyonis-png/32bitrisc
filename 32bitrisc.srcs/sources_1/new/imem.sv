`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2026 10:12:52 PM
// Design Name: 
// Module Name: imem
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

module imem(
    input word_t addr,
    output instr_t instruction
);

instr_t mem [0:255];

initial begin
    $readmemh("program.hex", mem);
end

assign instruction = mem[addr[9:2]];

endmodule