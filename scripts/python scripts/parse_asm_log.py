def parse_asm_log(filename="asm.log"):
    """
    Returns two dictionaries:
      1. index_to_asm: maps integer index (e.g. 4) -> "addi x1,x2,10"
      2. pc_to_asm: maps integer PC (e.g. 16) -> "addi x1,x2,10"
    """
    index_to_asm = {}
    pc_to_asm = {}
    
    try:
        with open(filename, "r") as f:
            for line in f:
                if not line.strip():
                    continue
                # Expected format: "0000 PC=00000000 addi x1,x0,5"
                parts = line.split(maxsplit=2)
                if len(parts) >= 3:
                    idx = int(parts[0])
                    pc_val = int(parts[1].split("=")[1], 16)
                    asm_text = parts[2].strip()
                    
                    index_to_asm[idx] = asm_text
                    pc_to_asm[pc_val] = asm_text
    except FileNotFoundError:
        print(f"Warning: {filename} not found. Assembly text will not be available.")
        
    return index_to_asm, pc_to_asm