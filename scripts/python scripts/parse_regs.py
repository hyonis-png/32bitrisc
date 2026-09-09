# parse_regs.py

def parse_register_dump(filename):

    regs = [0] * 32

    with open(filename, "r") as f:
        for line in f:

            if not line.startswith("REG"):
                continue

            _, reg_num, value = line.split()

            reg_num = int(reg_num)
            value = int(value, 16)

            regs[reg_num] = value

    return regs