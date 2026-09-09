# decoder.py

def sign_extend(value, bits):
    sign_bit = 1 << (bits - 1)

    if value & sign_bit:
        value -= (1 << bits)

    return value


def decode(instr):

    # Fields that always occupy the same bit positions
    opcode = instr & 0x7F
    rd      = (instr >> 7) & 0x1F
    funct3  = (instr >> 12) & 0x7
    rs1     = (instr >> 15) & 0x1F
    rs2     = (instr >> 20) & 0x1F
    funct7  = (instr >> 25) & 0x7F

    # =====================
    # R-Type
    # =====================
    if opcode == 0b0110011:
        return {
            "type": "R",
            "opcode": opcode,
            "rd": rd,
            "rs1": rs1,
            "rs2": rs2,
            "funct3": funct3,
            "funct7": funct7
        }

    # =====================
    # I-Type ALU
    # =====================
    elif opcode == 0b0010011:

        imm = sign_extend(
            (instr >> 20) & 0xFFF,
            12
        )

        return {
            "type": "I",
            "opcode": opcode,
            "rd": rd,
            "rs1": rs1,then i 
            "imm": imm,
            "funct3": funct3
        }

    # =====================
    # LW
    # =====================
    elif opcode == 0b0000011:

        imm = sign_extend(
            (instr >> 20) & 0xFFF,
            12
        )

        return {
            "type": "LW",
            "opcode": opcode,
            "rd": rd,
            "rs1": rs1,
            "imm": imm,
            "funct3": funct3
        }

    # =====================
    # S-Type (SW)
    # =====================
    elif opcode == 0b0100011:

        imm11_5 = (instr >> 25) & 0x7F
        imm4_0 = (instr >> 7) & 0x1F

        imm = (imm11_5 << 5) | imm4_0
        imm = sign_extend(imm, 12)

        return {
            "type": "S",
            "opcode": opcode,
            "rs1": rs1,
            "rs2": rs2,
            "imm": imm,
            "funct3": funct3
        }

    # =====================
    # B-Type (BEQ/BNE)
    # =====================
    elif opcode == 0b1100011:

        imm12 = (instr >> 31) & 0x1
        imm10_5 = (instr >> 25) & 0x3F
        imm4_1 = (instr >> 8) & 0xF
        imm11 = (instr >> 7) & 0x1

        imm = (
            (imm12 << 12) |
            (imm11 << 11) |
            (imm10_5 << 5) |
            (imm4_1 << 1)
        )

        imm = sign_extend(imm, 13)

        return {
            "type": "B",
            "opcode": opcode,
            "rs1": rs1,
            "rs2": rs2,
            "imm": imm,
            "funct3": funct3
        }

    # =====================
    # J-Type (JAL)
    # =====================
    elif opcode == 0b1101111:

        imm20 = (instr >> 31) & 0x1
        imm10_1 = (instr >> 21) & 0x3FF
        imm11 = (instr >> 20) & 0x1
        imm19_12 = (instr >> 12) & 0xFF

        imm = (
            (imm20 << 20) |
            (imm19_12 << 12) |
            (imm11 << 11) |
            (imm10_1 << 1)
        )

        imm = sign_extend(imm, 21)

        return {
            "type": "J",
            "opcode": opcode,
            "rd": rd,
            "imm": imm
        }

    # =====================
    # JALR
    # =====================
    elif opcode == 0b1100111:

        imm = sign_extend(
            (instr >> 20) & 0xFFF,
            12
        )

        return {
            "type": "JALR",
            "opcode": opcode,
            "rd": rd,
            "rs1": rs1,
            "imm": imm,
            "funct3": funct3
        }

    # =====================
    # Unknown
    # =====================
    else:
        raise ValueError(
            f"Unknown opcode: {opcode:07b}"
        )