# run_reference.py

from decoder import decode
import referencemodel as ref

instructions = []

with open("program.hex", "r") as f:
    for line in f:
        instructions.append(int(line.strip(), 16))

while ref.pc < len(instructions) * 4:

    index = ref.pc // 4
    instr = instructions[index]

    decoded = decode(instr)
    type_ = decoded["type"]

    # =========================
    # I-Type
    # =========================
    if type_ == "I":

        opcode = decoded["opcode"]
        funct3 = decoded["funct3"]
        rd = decoded["rd"]
        rs1 = decoded["rs1"]
        imm = decoded["imm"]

        if opcode == 0b0010011:

            if funct3 == 0b000:
                ref.execute_addi(rd, rs1, imm)

            elif funct3 == 0b100:
                ref.execute_xori(rd, rs1, imm)

            elif funct3 == 0b110:
                ref.execute_ori(rd, rs1, imm)

            elif funct3 == 0b111:
                ref.execute_andi(rd, rs1, imm)

            elif funct3 == 0b010:
                ref.execute_slti(rd, rs1, imm)

            elif funct3 == 0b011:
                ref.execute_sltiu(rd, rs1, imm)

            ref.pc += 4

        elif opcode == 0b0000011:
            ref.execute_lw(rd, rs1, imm)

        elif opcode == 0b1100111:
            ref.execute_jalr(rd, rs1, imm)

    # =========================
    # R-Type
    # =========================
    elif type_ == "R":

        funct3 = decoded["funct3"]
        funct7 = decoded["funct7"]
        rd = decoded["rd"]
        rs1 = decoded["rs1"]
        rs2 = decoded["rs2"]

        if funct3 == 0b000 and funct7 == 0b0000000:
            ref.execute_add(rd, rs1, rs2)

        elif funct3 == 0b000 and funct7 == 0b0100000:
            ref.execute_sub(rd, rs1, rs2)

        elif funct3 == 0b111:
            ref.execute_and(rd, rs1, rs2)

        elif funct3 == 0b110:
            ref.execute_or(rd, rs1, rs2)

        elif funct3 == 0b100:
            ref.execute_xor(rd, rs1, rs2)

        elif funct3 == 0b010:
            ref.execute_slt(rd, rs1, rs2)

        elif funct3 == 0b011:
            ref.execute_sltu(rd, rs1, rs2)

        ref.pc += 4

    # =========================
    # S-Type
    # =========================
    elif type_ == "S":

        funct3 = decoded["funct3"]
        rs1 = decoded["rs1"]
        rs2 = decoded["rs2"]
        imm = decoded["imm"]

        if funct3 == 0b010:
            ref.execute_sw(rs2, rs1, imm)

        ref.pc += 4

    # =========================
    # B-Type
    # =========================
    elif type_ == "B":

        funct3 = decoded["funct3"]
        rs1 = decoded["rs1"]
        rs2 = decoded["rs2"]
        imm = decoded["imm"]

        if funct3 == 0b000:
            ref.execute_beq(rs1, rs2, imm)

        elif funct3 == 0b001:
            ref.execute_bne(rs1, rs2, imm)

    # =========================
    # J-Type
    # =========================
    elif type_ == "J":

        rd = decoded["rd"]
        imm = decoded["imm"]

        ref.execute_jal(rd, imm)