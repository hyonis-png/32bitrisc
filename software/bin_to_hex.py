with open("program.bin", "rb") as f:
    data = f.read()

# Pad to a multiple of 4 bytes
while len(data) % 4 != 0:
    data += b"\x00"

with open(r"C:\Users\heyso\32bitrisc\32bitrisc.srcs\sources_1\new\program.hex", "w") as f:
    for i in range(0, len(data), 4):
        word = int.from_bytes(data[i:i+4], "little")
        f.write(f"{word:08x}\n")