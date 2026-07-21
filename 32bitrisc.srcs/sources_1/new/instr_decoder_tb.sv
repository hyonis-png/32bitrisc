`timescale 1ns / 1ps

import cpu_types_pkg::*;

module instr_decoder_tb;

    instr_t instruction;

    reg_addr_t rs1;
    reg_addr_t rs2;
    reg_addr_t rd;

    word_t imm;

    alu_op_t alu_control;

    logic reg_write;
    logic alu_src;

    logic branch_eq;
    logic branch_ne;
    logic branch_lt;
    logic branch_mt;

    logic mem_read;
    logic mem_write;
    logic mem_to_reg;

    logic jal_to_reg;
    logic jump;
    logic jalr;

    instr_decoder dut (
        .instruction(instruction),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .imm(imm),

        .alu_control(alu_control),

        .reg_write(reg_write),
        .alu_src(alu_src),

        .branch_eq(branch_eq),
        .branch_ne(branch_ne),
        .branch_lt(branch_lt),
        .branch_mt(branch_mt),

        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),

        .jal_to_reg(jal_to_reg),
        .jump(jump),
        .jalr(jalr)
    );

    // =====================================================
    // Helper Task
    // =====================================================
    task automatic check_equal(
        input int actual,
        input int expected,
        input string msg
    );
    begin
        assert(actual == expected)
        else
            $fatal(
                "%s failed. Expected=%0d Actual=%0d",
                msg,
                expected,
                actual
            );
    end
    endtask

    initial begin

        // =================================================
        // ADD
        // add x3,x1,x2
        // =================================================
        instruction = 32'b0000000_00010_00001_000_00011_0110011;
        #1;

        check_equal(rs1, 5'd1, "ADD rs1");
        check_equal(rs2, 5'd2, "ADD rs2");
        check_equal(rd , 5'd3, "ADD rd");

        assert(alu_control == ALU_ADD);
        check_equal(reg_write, 1, "ADD reg_write");
        check_equal(alu_src, 0, "ADD alu_src");

        // =================================================
        // SUB
        // =================================================
        instruction = 32'b0100000_00010_00001_000_00011_0110011;
        #1;

        assert(alu_control == ALU_SUB)
            else $fatal("SUB decode failed");

        // =================================================
        // AND
        // =================================================
        instruction = 32'b0000000_00010_00001_111_00011_0110011;
        #1;

        assert(alu_control == ALU_AND)
            else $fatal("AND decode failed");

        // =================================================
        // ADDI
        // addi x3,x1,5
        // =================================================
        instruction = 32'b000000000101_00001_000_00011_0010011;
        #1;

        check_equal(rs1, 5'd1, "ADDI rs1");
        check_equal(rd , 5'd3, "ADDI rd");
        check_equal(imm, 32'd5, "ADDI imm");

        assert(alu_control == ALU_ADD);
        check_equal(reg_write, 1, "ADDI reg_write");
        check_equal(alu_src, 1, "ADDI alu_src");

        // =================================================
        // LW
        // lw x2,4(x1)
        // =================================================
        instruction = 32'b000000000100_00001_010_00010_0000011;
        #1;

        check_equal(mem_read, 1, "LW mem_read");
        check_equal(mem_to_reg, 1, "LW mem_to_reg");
        check_equal(reg_write, 1, "LW reg_write");
        check_equal(alu_src, 1, "LW alu_src");

        // =================================================
        // SW
        // sw x2,4(x1)
        // =================================================
        instruction = 32'b0000000_00010_00001_010_00100_0100011;
        #1;

        check_equal(mem_write, 1, "SW mem_write");
        check_equal(reg_write, 0, "SW reg_write");

        // =================================================
        // BEQ
        // =================================================
        instruction = 32'b0000000_00010_00001_000_00000_1100011;
        #1;

        check_equal(branch_eq, 1, "BEQ");

        // =================================================
        // BNE
        // =================================================
        instruction = 32'b0000000_00010_00001_001_00000_1100011;
        #1;

        check_equal(branch_ne, 1, "BNE");

        // =================================================
        // JAL
        // =================================================
        instruction = 32'b00000000000100000000000011101111;
        #1;

        check_equal(jump, 1, "JAL jump");
        check_equal(jal_to_reg, 1, "JAL link");
        check_equal(reg_write, 1, "JAL reg_write");

        // =================================================
        // JALR
        // jalr x2,x1,0
        // =================================================
        instruction = 32'b000000000000_00001_000_00010_1100111;
        #1;

        check_equal(jalr, 1, "JALR");
        check_equal(jal_to_reg, 1, "JALR link");
        check_equal(reg_write, 1, "JALR reg_write");
        check_equal(alu_src, 1, "JALR alu_src");

        $display("==================================");
        $display("INSTR_DECODER TEST PASSED");
        $display("==================================");

        $finish;

    end

endmodule