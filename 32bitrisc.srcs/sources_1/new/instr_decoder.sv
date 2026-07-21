`timescale 1ns / 1ps

import cpu_types_pkg::*;

module instr_decoder(
    input instr_t instruction,

    output reg_addr_t rs1,
    output reg_addr_t rs2,
    output reg_addr_t rd,
    output word_t imm,

    output alu_op_t alu_control,
    output logic reg_write,
    output logic alu_src,

    output logic branch_eq,
    output logic branch_ne,
    output logic branch_lt, 
    output logic branch_mt,

    output logic mem_read,
    output logic mem_write,
    output logic mem_to_reg,
    output logic jal_to_reg,
    output logic jump,
    output logic jalr        // ◄ CONNECTED TO PORT LIST!
);

logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;

word_t i_imm;
word_t s_imm;
word_t b_imm;
word_t j_imm;
word_t u_imm;

assign opcode = instruction[6:0];
assign rd     = instruction[11:7];
assign funct3 = instruction[14:12];
assign rs1    = instruction[19:15];
assign rs2    = instruction[24:20];
assign funct7 = instruction[31:25];

// I-type immediate
assign i_imm = {
    {20{instruction[31]}},
    instruction[31:20]
};

// S-type immediate
assign s_imm = {
    {20{instruction[31]}},
    instruction[31:25],
    instruction[11:7]
};

// B-type immediate
assign b_imm = {
    {19{instruction[31]}},
    instruction[31],
    instruction[7],
    instruction[30:25],
    instruction[11:8],
    1'b0
};

// J-type immediate
assign j_imm = {
    {12{instruction[31]}}, 
    instruction[19:12],    
    instruction[20],       
    instruction[30:21],    
    1'b0                   
};


assign u_imm = {
    instruction[31:12],   // Grab the top 20 bits directly from the instruction
    12'b0                 // Shift them up by padding the bottom 12 bits with zeros
};

always_comb begin
    // defaults
    alu_control = ALU_ADD;
    reg_write   = 1'b0;
    alu_src     = 1'b0;

    mem_read    = 1'b0;
    mem_write   = 1'b0;
    mem_to_reg  = 1'b0;

    branch_eq   = 1'b0;
    branch_ne   = 1'b0;
    jump        = 1'b0;
    jalr        = 1'b0;     // ◄ DEFAULT VALUE RESET
    branch_lt   = 1'b0;
    branch_mt   = 1'b0;

    imm         = 32'd0;
    jal_to_reg  = 1'b0;

    case (opcode)

        // R-TYPE
        7'b0110011: begin
            reg_write = 1'b1;
            alu_src   = 1'b0;

            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0000000)
                        alu_control = ALU_ADD;
                    else if (funct7 == 7'b0100000)
                        alu_control = ALU_SUB;
                end

                3'b111: alu_control = ALU_AND;
                3'b110: alu_control = ALU_OR;
                3'b100: alu_control = ALU_XOR;
                3'b010: alu_control = ALU_SLT;
                3'b011: alu_control = ALU_SLTU;
                3'b001: alu_control = ALU_SLL;

                3'b101: begin
                    if (funct7 == 7'b0000000)
                        alu_control = ALU_SRL;
                    else if (funct7 == 7'b0100000)
                        alu_control = ALU_SRA;
                end
            endcase
        end

        // I-TYPE
        7'b0010011: begin
            reg_write = 1'b1;
            alu_src   = 1'b1;
            imm       = i_imm;

            case (funct3)
                3'b000: alu_control = ALU_ADD;
                3'b100: alu_control = ALU_XOR;
                3'b110: alu_control = ALU_OR;
                3'b111: alu_control = ALU_AND;
                3'b010: alu_control = ALU_SLT;
                3'b011: alu_control = ALU_SLTU;
            endcase
        end

        // LW
        7'b0000011: begin
            reg_write   = 1'b1;
            alu_src     = 1'b1;
            mem_read    = 1'b1;
            mem_to_reg  = 1'b1;
            alu_control = ALU_ADD;
            imm         = i_imm;
        end

        // SW
        7'b0100011: begin
            reg_write   = 1'b0;
            alu_src     = 1'b1;
            mem_write   = 1'b1;
            alu_control = ALU_ADD;
            imm         = s_imm;
        end

        // BRANCH
        7'b1100011: begin
            reg_write = 1'b0;
            alu_src   = 1'b0;
            imm       = b_imm;

            case (funct3)
                3'b000: branch_eq = 1'b1; // BEQ
                3'b001: branch_ne = 1'b1; // BNE
            endcase
        end

        // JAL Opcode
        7'b1101111: begin 
            reg_write  = 1'b1; 
            jump       = 1'b1; 
            jal_to_reg = 1'b1; 
            alu_src    = 1'b0; 
            mem_read   = 1'b0;
            imm        = j_imm;
            mem_write  = 1'b0;
            mem_to_reg = 1'b0;
        end

        // JALR Opcode
        7'b1100111: begin // ◄ SAFE INSIDE CASE BLOCK NOW
            reg_write   = 1'b1;     
            jalr        = 1'b1;     
            jal_to_reg  = 1'b1;     
            alu_src     = 1'b1;     
            alu_control = ALU_ADD;
            imm         = i_imm;    
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            mem_to_reg  = 1'b0;
            jump        = 1'b0;
        end
        
        7'b0110111: begin
            reg_write   = 1'b1;        // Yes, we save to register rd
            alu_src     = 1'b1;        // Use the immediate value
            imm         = u_imm;       // Load our shifted 20-bit value
            alu_control = ALU_ADD;     // Add it to 0 (Note: rs1 field is 0 in machine code)
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            mem_to_reg  = 1'b0;
            jump        = 1'b0;
            jalr        = 1'b0;
        end

    endcase
end

endmodule