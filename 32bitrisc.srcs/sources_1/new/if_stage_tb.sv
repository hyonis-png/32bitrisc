`timescale 1ns / 1ps
import cpu_types_pkg::*;

module if_stage_tb;

logic clk;
logic rst;
logic stall;

logic branch_taken;
word_t branch_target;

instr_t instr_id_out;
word_t  pc_id_out;

word_t frozen_pc;

if_stage dut (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .branch_taken(branch_taken),
    .branch_target(branch_target),
    .instr_id_out(instr_id_out),
    .pc_id_out(pc_id_out)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    stall = 0;
    branch_taken = 0;
    branch_target = 32'd0;

    // Reset Test
    @(posedge clk);
    #1;

    assert(pc_id_out == 32'd0)
        else $fatal("Reset PC failed, got %h", pc_id_out);

    assert(instr_id_out == 32'h00000013)
        else $fatal("Reset NOP failed, got %h", instr_id_out);

    rst = 0;

    // Normal Fetch Test
    @(posedge clk); #1;
    @(posedge clk); #1;
    @(posedge clk); #1;

    assert(pc_id_out == 32'd8)
        else $fatal("PC increment failed, got %h", pc_id_out);

    // Stall Test
    stall = 1;
    frozen_pc = pc_id_out;

    @(posedge clk);
    #1;

    assert(pc_id_out == frozen_pc)
        else $fatal("PC changed during stall");

    stall = 0;

    // Branch Redirect Test
    branch_taken  = 1;
    branch_target = 32'h00000040;

    @(posedge clk);
    #1;

    branch_taken = 0;

    @(posedge clk);
    #1;

    assert(pc_id_out == 32'h00000040)
        else $fatal("Branch redirect failed, got %h", pc_id_out);

    $display("==================================");
    $display("IF STAGE TEST PASSED");
    $display("==================================");

    $finish;
end

endmodule