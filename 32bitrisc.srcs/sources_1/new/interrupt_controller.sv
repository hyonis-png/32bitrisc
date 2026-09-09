`timescale 1ns / 1ps

import cpu_types_pkg::*;

module interrupt_controller (

    input  logic  clk,
    input  logic  rst,

    // =========================================================
    // INTERRUPT SOURCE
    // =========================================================

    input  logic  timer_irq,


    // =========================================================
    // PIPELINE / CPU CONTROL
    // =========================================================

    // CPU says whether the current pipeline state is safe
    // for accepting an interrupt.
    input  logic  can_take_irq,

    // Global machine interrupt enable from mstatus.MIE.
    input  logic  mstatus_mie,

    // MRET has reached EX.
    input  logic  irq_return,


    // =========================================================
    // CSR STATE
    // =========================================================
    //
    // The interrupt controller DOES NOT own these registers.
    //
    // csr_file owns mtvec and mepc.
    // We only consume their current values.
    //

    input  word_t mtvec,
    input  word_t mepc,


    // =========================================================
    // INTERRUPT CONTROL OUTPUTS
    // =========================================================

    // High when the CPU accepts the timer interrupt.
    output logic  irq_taken,

    // PC destination on interrupt entry.
    output word_t irq_target,

    // PC destination on MRET.
    output word_t irq_return_pc,

    // Additional nesting protection.
    output logic  in_interrupt
);


// =========================================================================
// INTERRUPT ACCEPTANCE
// =========================================================================
//
// Take the interrupt only when:
//
// 1. Timer has a pending interrupt.
// 2. Software has enabled machine interrupts using mstatus.MIE.
// 3. We aren't already servicing an interrupt.
// 4. The pipeline says this is a safe boundary.
//
// =========================================================================

assign irq_taken =
    timer_irq      &&
    mstatus_mie    &&
    !in_interrupt  &&
    can_take_irq;


// =========================================================================
// INTERRUPT TARGET
// =========================================================================
//
// mtvec is owned by csr_file.
//
// Software can execute:
//
//      csrw mtvec, x5
//
// to change the trap-handler address.
//
// On interrupt:
//
//      PC <- mtvec
//
// =========================================================================

assign irq_target = mtvec;


// =========================================================================
// INTERRUPT RETURN TARGET
// =========================================================================
//
// mepc is also owned by csr_file.
//
// On interrupt entry, cpu_top tells csr_file:
//
//      trap_enter = irq_taken
//      trap_pc    = id_pc
//
// csr_file therefore performs:
//
//      mepc <- id_pc
//
// On MRET:
//
//      PC <- mepc
//
// =========================================================================

assign irq_return_pc = mepc;


// =========================================================================
// INTERRUPT STATE
// =========================================================================
//
// This prevents nested interrupts in this simple implementation.
//
// irq_taken:
//      in_interrupt <- 1
//
// MRET:
//      in_interrupt <- 0
//
// mstatus.MIE ALSO gets cleared/restored by csr_file.
//
// =========================================================================

always_ff @(posedge clk) begin

    if (rst) begin

        in_interrupt <= 1'b0;

    end

    else if (irq_return) begin

        in_interrupt <= 1'b0;

    end

    else if (irq_taken) begin

        in_interrupt <= 1'b1;

    end

end


endmodule