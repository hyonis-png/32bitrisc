# scoreboard.py

from parse_regs import parse_regs
from run_reference import run_reference

hw_regs = parse_regs("sim.log")
ref_regs = run_reference("program.hex")

mismatches = 0

for i in range(32):

    if hw_regs[i] != ref_regs[i]:
        print(f"x{i} mismatch:")
        print(f"  HW  = {hw_regs[i]:08x}")
        print(f"  REF = {ref_regs[i]:08x}")
        mismatches += 1

if mismatches == 0:
    print("==================================")
    print("SCOREBOARD PASSED")
    print("==================================")
else:
    print("==================================")
    print(f"SCOREBOARD FAILED ({mismatches} mismatches)")
    print("==================================")