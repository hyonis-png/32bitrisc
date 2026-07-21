# assembler.py




# -----------------------------
# I-Type
# -----------------------------
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


# -----------------------------
# R-Type
# -----------------------------
def add(rd, rs1, rs2):
    return (
        (0b0000000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b000 << 12) |
        (rd << 7) |
        0b0110011
    )


def sub(rd, rs1, rs2):
    return (
        (0b0100000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b000 << 12) |
        (rd << 7) |
        0b0110011
    )


def and_(rd, rs1, rs2):
    return (
        (0b0000000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b111 << 12) |
        (rd << 7) |
        0b0110011
    )


def or_(rd, rs1, rs2):
    return (
        (0b0000000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b110 << 12) |
        (rd << 7) |
        0b0110011
    )


def xor_(rd, rs1, rs2):
    return (
        (0b0000000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b100 << 12) |
        (rd << 7) |
        0b0110011
    )


def slt(rd, rs1, rs2):
    return (
        (0b0000000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b010 << 12) |
        (rd << 7) |
        0b0110011
    )


def sltu(rd, rs1, rs2):
    return (
        (0b0000000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b011 << 12) |
        (rd << 7) |
        0b0110011
    )


def sll(rd, rs1, rs2):
    return (
        (0b0000000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b001 << 12) |
        (rd << 7) |
        0b0110011
    )


def srl(rd, rs1, rs2):
    return (
        (0b0000000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b101 << 12) |
        (rd << 7) |
        0b0110011
    )


def sra(rd, rs1, rs2):
    return (
        (0b0100000 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (0b101 << 12) |
        (rd << 7) |
        0b0110011
    )


# -----------------------------
# S-Type
# -----------------------------
def sw(rs2, rs1, imm):

    opcode = 0b0100011
    funct3 = 0b010

    imm &= 0xFFF

    return (
        (((imm >> 5) & 0x7F) << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        ((imm & 0x1F) << 7) |
        opcode
    )


# -----------------------------
# B-Type
# -----------------------------
def beq(rs1, rs2, imm):

    opcode = 0b1100011
    funct3 = 0b000

    imm &= 0x1FFF

    return (
        (((imm >> 12) & 1) << 31) |
        (((imm >> 5) & 0x3F) << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (((imm >> 1) & 0xF) << 8) |
        (((imm >> 11) & 1) << 7) |
        opcode
    )


def bne(rs1, rs2, imm):

    opcode = 0b1100011
    funct3 = 0b001

    imm &= 0x1FFF

    return (
        (((imm >> 12) & 1) << 31) |
        (((imm >> 5) & 0x3F) << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (((imm >> 1) & 0xF) << 8) |
        (((imm >> 11) & 1) << 7) |
        opcode
    )


# -----------------------------
# J-Type
# -----------------------------
def jal(rd, imm):

    opcode = 0b1101111

    imm &= 0x1FFFFF

    return (
        (((imm >> 20) & 1) << 31) |
        (((imm >> 1) & 0x3FF) << 21) |
        (((imm >> 11) & 1) << 20) |
        (((imm >> 12) & 0xFF) << 12) |
        (rd << 7) |
        opcode
    )

def lui(rd, imm20):
    opcode = 0b0110111

    instr = (
        ((imm20 & 0xFFFFF) << 12) |
        (rd << 7) |
        opcode
    )

    return instr
