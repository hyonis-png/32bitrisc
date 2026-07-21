`timescale 1ns / 1ps

import cpu_types_pkg::*;

module mem_wb_reg_tb;

logic clk;
logic rst;
logic stall;

// MEM inputs
word_t      mem_alu_result;
word_t      mem_read_data;
word_t      mem_pc_plus4;

reg_addr_t  mem_rd;

logic       mem_reg_write;
logic       mem_mem_to_reg;
logic       mem_jal_to_reg;

// WB outputs
word_t      wb_alu_result;
word_t      wb_read_data;
word_t      wb_pc_plus4;

reg_addr_t  wb_rd;

logic       wb_reg_write;
logic       wb_mem_to_reg;
logic       wb_jal_to_reg;

// Simulated writeback mux
word_t wb_write_data;

mem_wb_reg dut (
    .clk(clk),
    .rst(rst),
    .stall(stall),

    .mem_alu_result(mem_alu_result),
    .mem_read_data(mem_read_data),
    .mem_pc_plus4(mem_pc_plus4),

    .mem_rd(mem_rd),

    .mem_reg_write(mem_reg_write),
    .mem_mem_to_reg(mem_mem_to_reg),
    .mem_jal_to_reg(mem_jal_to_reg),

    .wb_alu_result(wb_alu_result),
    .wb_read_data(wb_read_data),
    .wb_pc_plus4(wb_pc_plus4),

    .wb_rd(wb_rd),

    .wb_reg_write(wb_reg_write),
    .wb_mem_to_reg(wb_mem_to_reg),
    .wb_jal_to_reg(wb_jal_to_reg)
);

task automatic check_equal(
    input logic [31:0] actual,
    input logic [31:0] expected,
    input string msg
);
begin
    assert(actual == expected)
    else
        $fatal(
            "%s failed. Expected=%0h Actual=%0h",
            msg,
            expected,
            actual
        );
end
endtask

// Final WB mux used in cpu_top
assign wb_write_data =
    wb_jal_to_reg ? wb_pc_plus4 :
    wb_mem_to_reg ? wb_read_data :
                    wb_alu_result;

// Clock generation
always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;
    stall = 0;

    mem_alu_result = 0;
    mem_read_data  = 0;
    mem_pc_plus4   = 0;

    mem_rd         = 0;

    mem_reg_write  = 0;
    mem_mem_to_reg = 0;
    mem_jal_to_reg = 0;

    // =====================================
    // Reset Test
    // =====================================
    @(posedge clk);
    #1;

    check_equal(wb_alu_result, 32'd0, "Reset wb_alu_result");
    check_equal(wb_read_data , 32'd0, "Reset wb_read_data");
    check_equal(wb_pc_plus4  , 32'd0, "Reset wb_pc_plus4");
    check_equal(wb_rd        , 32'd0, "Reset wb_rd");

    rst = 0;

    // =====================================
    // ALU Writeback Test
    // =====================================
    mem_alu_result = 32'd45;
    mem_rd         = 5'd3;
    mem_reg_write  = 1;
    mem_mem_to_reg = 0;
    mem_jal_to_reg = 0;

    @(posedge clk);
    #1;

    check_equal(wb_write_data, 32'd45, "ALU writeback");
    check_equal(wb_rd, 5'd3, "ALU destination register");

    // =====================================
    // LOAD Writeback Test
    // =====================================
    mem_read_data  = 32'hAABBCCDD;
    mem_rd         = 5'd5;
    mem_mem_to_reg = 1;
    mem_jal_to_reg = 0;

    @(posedge clk);
    #1;

    check_equal(wb_read_data, 32'hAABBCCDD, "Load data");
    check_equal(wb_write_data, 32'hAABBCCDD, "Load writeback");
    check_equal(wb_rd, 5'd5, "Load destination register");

    // =====================================
    // JAL Writeback Test
    // =====================================
    mem_pc_plus4   = 32'h00000020;
    mem_rd         = 5'd1;

    mem_mem_to_reg = 0;
    mem_jal_to_reg = 1;

    @(posedge clk);
    #1;

    check_equal(wb_write_data, 32'h00000020, "JAL writeback");
    check_equal(wb_rd, 5'd1, "JAL destination register");

    // =====================================
    // Stall Test
    // =====================================
    stall = 1;

    mem_pc_plus4 = 32'h12345678;

    @(posedge clk);
    #1;

    check_equal(
        wb_pc_plus4,
        32'h00000020,
        "Pipeline held during stall"
    );

    stall = 0;

    $display("==================================");
    $display("MEM/WB TEST PASSED");
    $display("==================================");

    $finish;

end

endmodule

