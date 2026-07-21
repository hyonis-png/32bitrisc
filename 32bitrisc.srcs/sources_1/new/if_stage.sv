`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2026 12:17:58 PM
// Design Name: 
// Module Name: if_stage
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

module if_stage(
    input logic clk,
    input logic rst,
    input logic stall,

    input logic branch_taken,
    input word_t branch_target,

    output instr_t instr_id_out,
    output word_t pc_id_out
);

word_t next_pc;
word_t pc_if_raw;
instr_t fetched_instr;

assign next_pc =
    branch_taken ? branch_target
                 : (pc_if_raw + 32'd4);

pc pc_inst(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .next_pc(next_pc),
    .pc_out(pc_if_raw)
);

imem imem_inst(
    .addr(pc_if_raw),
    .instruction(fetched_instr)
);

always_ff @(posedge clk) begin

    if (rst) begin
        instr_id_out <= 32'h00000013;
        pc_id_out    <= 32'd0;
    end
    else if (!stall) begin
        instr_id_out <= fetched_instr;
        pc_id_out    <= pc_if_raw;
    end

end

endmodule