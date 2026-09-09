regs = [0] * 32
memory = {}
pc = 0

def execute_addi(rd, rs1, imm):
    if rd != 0:
        regs[rd] = regs[rs1] + imm

def xori(rd, rs1, imm):
    if rd != 0:
        regs[rd] = regs[rs1] ^ imm

        
def ori(rd, rs1, imm):
    if rd != 0:
        regs[rd] = regs[rs1] | imm


def andi(rd, rs1, imm):
    if rd != 0:
        regs[rd] = regs[rs1] & imm

def slti(rd, rs1, imm):
    if rd != 0:
        regs[rd] = 1 if regs[rs1] < imm else 0

def sltiu(rd, rs1, imm):
    if rd != 0:
        regs[rd] = 1 if (regs[rs1] & 0xFFFFFFFF) < (imm & 0xFFFFFFFF) else 0        

def execute_add(rd, rs1, rs2):
    if rd != 0:
        regs[rd] = regs[rs1] + regs[rs2]


def execute_sub(rd, rs1, rs2):
    if rd != 0:
        regs[rd] = regs[rs1] - regs[rs2]

        
def execute_and(rd, rs1, rs2):
    if rd != 0:
        regs[rd] = regs[rs1] & regs[rs2]

def execute_or(rd, rs1, rs2):
    if rd != 0:
        regs[rd] = regs[rs1] | regs[rs2]

def execute_xor(rd, rs1, rs2):
    if rd != 0:
        regs[rd] = regs[rs1] ^ regs[rs2]


def execute_slt(rd, rs1, rs2):
    if rd != 0:
        regs[rd] = 1 if regs[rs1] < regs[rs2] else 0

def execute_sltu(rd, rs1, rs2):
    if rd != 0:
        regs[rd] = 1 if (regs[rs1] & 0xFFFFFFFF) < (regs[rs2] & 0xFFFFFFFF) else 0

def execute_sll(rd, rs1, shamt):
    if rd != 0:
        regs[rd] = regs[rs1] << shamt