# check_regs.py

# Software copy of the hardware register file
hw_regs = [0] * 32

# Open simulator output
with open("sim.log") as f:
    for line in f:

        # Ignore lines that don't start with REG
        if not line.startswith("REG"):
            continue

        # Example:
        # "REG 2 0000000a"
        parts = line.split()

        # parts becomes:
        # ['REG', '2', '0000000a']

        reg_num = int(parts[1])       # 2
        reg_val = int(parts[2], 16)   # 10

        # Store value into our software register file
        hw_regs[reg_num] = reg_val

# Print register file
print("Hardware Registers:")

for i in range(32):
    print(f"x{i:02d} = {hw_regs[i]}")