//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2026 10:27:27 PM
// Design Name: 
// Module Name: imem_tb
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

module imem_tb;

    word_t  addr;
    instr_t instruction;

    imem dut (
        .addr(addr),
        .instruction(instruction)
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

    initial begin

        // =====================================
        // Instruction 0
        // =====================================
        addr = 32'h00000000;
        #1;

        check_equal(
            instruction,
            32'h00500093,
            "Instruction 0"
        );

        // =====================================
        // Instruction 1
        // =====================================
        addr = 32'h00000004;
        #1;

        check_equal(
            instruction,
            32'h00700113,
            "Instruction 1"
        );

        // =====================================
        // Instruction 2
        // =====================================
        addr = 32'h00000008;
        #1;

        check_equal(
            instruction,
            32'h002081B3,
            "Instruction 2"
        );

        // =====================================
        // Address Alignment Check
        // addr[9:2] means 0x08 and 0x09
        // should fetch same instruction
        // =====================================
        addr = 32'h00000009;
        #1;

        check_equal(
            instruction,
            32'h002081B3,
            "Address Alignment"
        );

        $display("==================================");
        $display("IMEM TEST PASSED");
        $display("==================================");

        $finish;

    end

endmodule