# generate_hex.py

import random
from assembler import *

program = []
asm_log = []

def add_instr(instr, text):
    index = len(program)
    pc = index * 4
    program.append(instr)
    asm_log.append(f"{index:04d} PC={pc:08x} {text}")



NUM_INSTRUCTIONS = 100

for i in range(NUM_INSTRUCTIONS):

    # Random instruction type
    choice = random.randint(0, 12)

    # Random registers
    rd = random.randint(1, 31)   # avoid writing x0
    rs1 = random.randint(0, 31)
    rs2 = random.randint(0, 31)

    # Immediates
    imm12 = random.randint(-2048, 2047)
    branch_imm = random.randint(-256, 256) * 2
    jump_imm = random.randint(-1024, 1024) * 2

if choice == 0:
    instr = addi(rd, rs1, imm12)
    text = f"addi x{rd},x{rs1},{imm12}"

elif choice == 1:
    instr = add(rd, rs1, rs2)
    text = f"add x{rd},x{rs1},x{rs2}"

elif choice == 2:
    instr = sub(rd, rs1, rs2)
    text = f"sub x{rd},x{rs1},x{rs2}"

elif choice == 3:
    instr = and_(rd, rs1, rs2)
    text = f"and x{rd},x{rs1},x{rs2}"

elif choice == 4:
    instr = or_(rd, rs1, rs2)
    text = f"or x{rd},x{rs1},x{rs2}"

elif choice == 5:
    instr = xor_(rd, rs1, rs2)
    text = f"xor x{rd},x{rs1},x{rs2}"

elif choice == 6:
    instr = slt(rd, rs1, rs2)
    text = f"slt x{rd},x{rs1},x{rs2}"

elif choice == 7:
    instr = sltu(rd, rs1, rs2)
    text = f"sltu x{rd},x{rs1},x{rs2}"

elif choice == 8:
    instr = sll(rd, rs1, rs2)
    text = f"sll x{rd},x{rs1},x{rs2}"

elif choice == 9:
    instr = srl(rd, rs1, rs2)
    text = f"srl x{rd},x{rs1},x{rs2}"

elif choice == 10:
    instr = lw(rd, rs1, imm12)
    text = f"lw x{rd},{imm12}(x{rs1})"

elif choice == 11:
    instr = sw(rs2, rs1, imm12)
    text = f"sw x{rs2},{imm12}(x{rs1})"

else:
    instr = beq(rs1, rs2, branch_imm)
    text = f"beq x{rs1},x{rs2},{branch_imm}"

add_instr(instr, text)

with open("program.hex", "w") as f:
    for instr in program:
        f.write(f"{instr:08x}\n")

with open("program.asm", "w") as f:
    for line in asm_log:
        f.write(line + "\n")

print(f"Generated {NUM_INSTRUCTIONS} instructions.")
print("program.hex written successfully.")