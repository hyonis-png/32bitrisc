from assembler import *

program = []

NOP = addi(0, 0, 0)

# ====================================================
# UART BASE
# x5 = 0x80000000
# ====================================================

program.append(addi(5, 0, 1))
program.append(addi(6, 0, 31))
program.append(sll(5, 5, 6))

program.extend([NOP] * 4)


# ====================================================
# MAIN
# ====================================================

# Call draw_top() for the top border.
# jal x1, draw_top
call_top_border = len(program)
program.append(0)

program.extend([NOP] * 4)


# x9 = 8 middle rows
program.append(addi(9, 0, 8))
program.extend([NOP] * 4)

# Start of the middle-row loop
row_loop = len(program)

# Call draw_middle()
# jal x1, draw_middle
call_middle_row = len(program)
program.append(0)

program.extend([NOP] * 4)

# x9--
program.append(addi(9, 9, -1))
program.extend([NOP] * 4)

# If x9 != 0, draw another middle row
row_offset = (row_loop - len(program)) * 4
program.append(bne(9, 0, row_offset))


# Call draw_top() again for the bottom border
call_bottom_border = len(program)
program.append(0)

program.extend([NOP] * 4)

# Stop forever
program.append(jal(0, 0))


# ====================================================
# DRAW_TOP FUNCTION
#
# Prints:
# ####################
#
# x1 = return address back to main
# x2 = return address back from putchar
# x8 = character counter
# ====================================================

draw_top_label = len(program)

# x8 = 20 characters
program.append(addi(8, 0, 20))
program.extend([NOP] * 4)

top_loop = len(program)

# x7 = '#'
program.append(addi(7, 0, ord('#')))
program.extend([NOP] * 4)

# jal x2, putchar
call_top_putchar = len(program)
program.append(0)

program.extend([NOP] * 4)

# x8--
program.append(addi(8, 8, -1))
program.extend([NOP] * 4)

# Repeat until x8 == 0
top_offset = (top_loop - len(program)) * 4
program.append(bne(8, 0, top_offset))


# Print newline
program.append(addi(7, 0, ord('\n')))
program.extend([NOP] * 4)

# jal x2, putchar
call_top_newline = len(program)
program.append(0)

program.extend([NOP] * 4)

# Return to main using x1
program.append(jalr(0, 1, 0))


# ====================================================
# DRAW_MIDDLE FUNCTION
#
# Prints:
# #                  #
#
# x1 = return address back to main
# x2 = return address back from putchar
# x8 = space counter
# ====================================================

draw_middle_label = len(program)


# -----------------------------
# Print left wall '#'
# -----------------------------

program.append(addi(7, 0, ord('#')))
program.extend([NOP] * 4)

# jal x2, putchar
call_left_wall = len(program)
program.append(0)

program.extend([NOP] * 4)


# -----------------------------
# Print 18 spaces
# -----------------------------

program.append(addi(8, 0, 18))
program.extend([NOP] * 4)

space_loop = len(program)

# x7 = space
program.append(addi(7, 0, ord(' ')))
program.extend([NOP] * 4)

# jal x2, putchar
call_space = len(program)
program.append(0)

program.extend([NOP] * 4)

# x8--
program.append(addi(8, 8, -1))
program.extend([NOP] * 4)

# Repeat until x8 == 0
space_offset = (space_loop - len(program)) * 4
program.append(bne(8, 0, space_offset))


# -----------------------------
# Print right wall '#'
# -----------------------------

program.append(addi(7, 0, ord('#')))
program.extend([NOP] * 4)

# jal x2, putchar
call_right_wall = len(program)
program.append(0)

program.extend([NOP] * 4)


# -----------------------------
# Print newline
# -----------------------------

program.append(addi(7, 0, ord('\n')))
program.extend([NOP] * 4)

# jal x2, putchar
call_middle_newline = len(program)
program.append(0)

program.extend([NOP] * 4)

# Return to main using x1
program.append(jalr(0, 1, 0))


# ====================================================
# PUTCHAR FUNCTION
#
# Input:
#   x7 = character to print
#   x5 = UART base
#
# x2 contains the return address.
# ====================================================

putchar_label = len(program)

# Send x7 to UART address x5 + 12
program.append(sw(7, 5, 12))

program.extend([NOP] * 4)

# Return using x2
program.append(jalr(0, 2, 0))


# ====================================================
# PATCH MAIN FUNCTION CALLS
# ====================================================

# main -> draw_top
program[call_top_border] = jal(
    1,
    (draw_top_label - call_top_border) * 4
)

# main -> draw_middle
program[call_middle_row] = jal(
    1,
    (draw_middle_label - call_middle_row) * 4
)

# main -> draw_top again
program[call_bottom_border] = jal(
    1,
    (draw_top_label - call_bottom_border) * 4
)


# ====================================================
# PATCH DRAW_TOP -> PUTCHAR CALLS
# ====================================================

program[call_top_putchar] = jal(
    2,
    (putchar_label - call_top_putchar) * 4
)

program[call_top_newline] = jal(
    2,
    (putchar_label - call_top_newline) * 4
)


# ====================================================
# PATCH DRAW_MIDDLE -> PUTCHAR CALLS
# ====================================================

program[call_left_wall] = jal(
    2,
    (putchar_label - call_left_wall) * 4
)

program[call_space] = jal(
    2,
    (putchar_label - call_space) * 4
)

program[call_right_wall] = jal(
    2,
    (putchar_label - call_right_wall) * 4
)

program[call_middle_newline] = jal(
    2,
    (putchar_label - call_middle_newline) * 4
)


# ====================================================
# SIZE CHECK
# ====================================================

if len(program) > 256:
    raise RuntimeError(
        f"Program is too large: {len(program)} instructions"
    )

print("Instructions before padding:", len(program))
print("draw_top starts at:", draw_top_label)
print("draw_middle starts at:", draw_middle_label)
print("putchar starts at:", putchar_label)


# ====================================================
# PAD AND WRITE PROGRAM.HEX
# ====================================================

while len(program) < 256:
    program.append(NOP)

with open("program.hex", "w") as file:
    for instruction in program:
        file.write(f"{instruction:08x}\n")

print(f"Generated {len(program)} instructions.")