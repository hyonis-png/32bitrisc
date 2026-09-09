.section .text

.globl trap_entry

.extern interrupt_handler
.extern current_thread
.extern threads


trap_entry:

    # ============================================================
    # 1. CREATE 128-BYTE CONTEXT FRAME FOR CURRENT THREAD
    # ============================================================

    addi sp, sp, -128


    # ============================================================
    # 2. SAVE CURRENT THREAD'S REGISTERS
    #
    # x0 is always zero.
    # x2 is sp itself, so it is handled separately.
    # ============================================================

    sw x1,    4(sp)      # ra

    sw x3,   12(sp)      # gp
    sw x4,   16(sp)      # tp

    sw x5,   20(sp)      # t0
    sw x6,   24(sp)      # t1
    sw x7,   28(sp)      # t2

    sw x8,   32(sp)      # s0 / fp
    sw x9,   36(sp)      # s1

    sw x10,  40(sp)      # a0
    sw x11,  44(sp)      # a1
    sw x12,  48(sp)      # a2
    sw x13,  52(sp)      # a3
    sw x14,  56(sp)      # a4
    sw x15,  60(sp)      # a5
    sw x16,  64(sp)      # a6
    sw x17,  68(sp)      # a7

    sw x18,  72(sp)      # s2
    sw x19,  76(sp)      # s3
    sw x20,  80(sp)      # s4
    sw x21,  84(sp)      # s5
    sw x22,  88(sp)      # s6
    sw x23,  92(sp)      # s7
    sw x24,  96(sp)      # s8
    sw x25, 100(sp)      # s9
    sw x26, 104(sp)      # s10
    sw x27, 108(sp)      # s11

    sw x28, 112(sp)      # t3
    sw x29, 116(sp)      # t4
    sw x30, 120(sp)      # t5
    sw x31, 124(sp)      # t6


    # ============================================================
    # 3. FIND CURRENT THREAD'S TCB
    #
    # thread_t is:
    #
    #   +0 : sp
    #   +4 : pc
    #
    # sizeof(thread_t) = 8 bytes
    # ============================================================

    la   t0, current_thread
    lw   t1, 0(t0)              # t1 = current_thread

    la   t2, threads

    slli t3, t1, 3              # offset = current_thread * 8
    add  t2, t2, t3             # t2 = &threads[current_thread]


    # ============================================================
    # 4. SAVE CURRENT THREAD'S SP
    #
    # sp currently points to the 128-byte saved-register frame.
    # ============================================================

    sw sp, 0(t2)


    # ============================================================
    # 5. SAVE CURRENT THREAD'S PC
    #
    # Hardware placed interrupted PC into mepc.
    # ============================================================

    csrr t4, mepc
    sw   t4, 4(t2)


    # ============================================================
    # 6. CALL C INTERRUPT HANDLER
    #
    # interrupt_handler:
    #
    #   timer_irq_clear();
    #   timer_set_compare(...);   <-- rearm timer
    #   schedule();
    #
    # schedule() changes current_thread.
    # ============================================================

    call interrupt_handler


    # ============================================================
    # 7. FIND THE THREAD SELECTED BY schedule()
    # ============================================================

    la   t0, current_thread
    lw   t1, 0(t0)

    la   t2, threads

    slli t3, t1, 3              # selected_thread * 8
    add  t2, t2, t3             # &threads[selected_thread]


    # ============================================================
    # 8. GET SELECTED THREAD'S SAVED PC
    #
    # Do this BEFORE replacing sp.
    # ============================================================

    lw t4, 4(t2)


    # ============================================================
    # 9. SWITCH STACKS
    #
    # THIS IS THE ACTUAL THREAD STACK SWITCH.
    #
    # Before:
    #     sp -> old thread's frame
    #
    # After:
    #     sp -> selected thread's frame
    # ============================================================

    lw sp, 0(t2)


    # ============================================================
    # 10. CHANGE INTERRUPT RETURN ADDRESS
    #
    # mret will now return into the selected thread.
    # ============================================================

    csrw mepc, t4


    # ============================================================
    # 11. RESTORE SELECTED THREAD'S REGISTERS
    #
    # Notice these are the SAME lw instructions as before.
    #
    # The difference is that sp now points to ANOTHER THREAD'S
    # saved context.
    # ============================================================

    lw x1,    4(sp)

    lw x3,   12(sp)
    lw x4,   16(sp)

    lw x5,   20(sp)
    lw x6,   24(sp)
    lw x7,   28(sp)

    lw x8,   32(sp)
    lw x9,   36(sp)

    lw x10,  40(sp)
    lw x11,  44(sp)
    lw x12,  48(sp)
    lw x13,  52(sp)
    lw x14,  56(sp)
    lw x15,  60(sp)
    lw x16,  64(sp)
    lw x17,  68(sp)

    lw x18,  72(sp)
    lw x19,  76(sp)
    lw x20,  80(sp)
    lw x21,  84(sp)
    lw x22,  88(sp)
    lw x23,  92(sp)
    lw x24,  96(sp)
    lw x25, 100(sp)
    lw x26, 104(sp)
    lw x27, 108(sp)

    lw x28, 112(sp)
    lw x29, 116(sp)
    lw x30, 120(sp)
    lw x31, 124(sp)


    # ============================================================
    # 12. REMOVE SELECTED THREAD'S 128-BYTE CONTEXT FRAME
    # ============================================================

    addi sp, sp, 128


    # ============================================================
    # 13. RETURN INTO SELECTED THREAD
    #
    # PC <- mepc
    # ============================================================

    mret