#assembler.py 

def addi(rd, rs1, imm):
    opcode = 0b0010011
    funct3 = 0b000


    instr = (
        ((imm & 0xFFF) << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )

    return instr



def add(rd, rs1, rs2):    
    opcode = 0b0110011
    funct3 = 0b000
    funct7 = 0b0000000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def sub(rd, rs1, rs2):    
    opcode = 0b0110011
    funct3 = 0b000
    funct7 = 0b0100000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def xori(rd, rs1, imm):
    opcode = 0b0010011
    funct3 = 0b100

    instr = (
        ((imm & 0xFFF) << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )

    return instr

def ori(rd, rs1, imm):
    opcode = 0b0010011
    funct3 = 0b110

    instr = (
        ((imm & 0xFFF) << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )

    return instr

def andi(rd, rs1, imm):
    opcode = 0b0010011
    funct3 = 0b111

    instr = (
        ((imm & 0xFFF) << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )

    return instr

def slti(rd, rs1, imm):
    opcode = 0b0010011
    funct3 = 0b010

    instr = (
        ((imm & 0xFFF) << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )

    return instr

def sltiu(rd, rs1, imm):
    opcode = 0b0010011
    funct3 = 0b011

    instr = (
        ((imm & 0xFFF) << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )

    return instr

def and_(rd, rs1, rs2):    
    opcode = 0b0110011
    funct3 = 0b111
    funct7 = 0b0000000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def or_(rd, rs1, rs2):
    opcode = 0b0110011
    funct3 = 0b110
    funct7 = 0b0000000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr        

def xor_(rd, rs1, rs2):
    opcode = 0b0110011
    funct3 = 0b100
    funct7 = 0b0000000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def slt(rd, rs1, rs2):
    opcode = 0b0110011
    funct3 = 0b010
    funct7 = 0b0000000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def sltu(rd, rs1, rs2):
    opcode = 0b0110011
    funct3 = 0b011
    funct7 = 0b0000000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def sll(rd, rs1, rs2):
    opcode = 0b0110011
    funct3 = 0b001
    funct7 = 0b0000000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def srl(rd, rs1, rs2):
    opcode = 0b0110011
    funct3 = 0b101     
    funct7 = 0b0000000 
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def sra(rd, rs1, rs2):
    opcode = 0b0110011
    funct3 = 0b101      
    funct7 = 0b0100000
    instr = (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )
    return instr

def lw(rd, rs1, imm):
    opcode = 0b0000011
    funct3 = 0b010

    instr = (
        ((imm & 0xFFF) << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )

    return instr

def sw(rs2, rs1, imm):
    opcode = 0b0100011
    funct3 = 0b010


    imm = imm & 0xFFF
    imm11_5 = (imm >> 5) & 0x7F
    imm4_0 = imm & 0x1F

    instr = (
        (imm11_5 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (imm4_0 << 7) |
        opcode
    )

    return instr

def beq(rs1, rs2, imm):
    opcode = 0b1100011
    funct3 = 0b000

    imm = imm & 0x1FFF
    imm12 = (imm >> 12) & 0x1
    imm10_5 = (imm >> 5) & 0x3F
    imm4_1 = (imm >> 1) & 0xF
    imm11 = (imm >> 11) & 0x1

    instr = (
        (imm12 << 31) |
        (imm11 << 7) |
        (imm10_5 << 25) |
        (imm4_1 << 8) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        opcode
    )

    return instr


def bne(rs1, rs2, imm):
    opcode = 0b1100011
    funct3 = 0b001

    imm = imm & 0x1FFF
    imm12 = (imm >> 12) & 0x1
    imm10_5 = (imm >> 5) & 0x3F
    imm4_1 = (imm >> 1) & 0xF
    imm11 = (imm >> 11) & 0x1

    instr = (
        (imm12 << 31) |
        (imm11 << 7) |
        (imm10_5 << 25) |
        (imm4_1 << 8) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        opcode
    )

    return instr

def jal(rd, imm):
    opcode = 0b1101111

    imm = imm & 0x1FFFFF
    imm20 = (imm >> 20) & 0x1
    imm10_1 = (imm >> 1) & 0x3FF
    imm11 = (imm >> 11) & 0x1
    imm19_12 = (imm >> 12) & 0xFF

    instr = (
        (imm20 << 31) |
        (imm19_12 << 12) |
        (imm11 << 20) |
        (imm10_1 << 21) |
        (rd << 7) |
        opcode
    )

    return instr

def jalr(rd, rs1, imm):
    opcode = 0b1100111
    funct3 = 0b000

    instr = (
        ((imm & 0xFFF) << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )

    return instr