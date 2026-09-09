`timescale 1ns / 1ps

module csr_file #(
    parameter type word_t = logic [31:0]
)(
    input  logic        clk,
    input  logic        rst,

    // CSR instruction interface
    input  logic        csr_write,
    input  logic [11:0] csr_addr,
    input  word_t       csr_write_data,
    output word_t       csr_read_data,

    // Hardware trap interface
    input  logic        trap_enter,
    input  word_t       trap_pc,
    input  logic        trap_return,

    // CSR state used by interrupt hardware
    output word_t       mtvec,
    output word_t       mepc,
    output logic        mstatus_mie,
    output logic        mstatus_mpie
);


// =========================================================================
// CSR ADDRESS MAP
// =========================================================================

localparam logic [11:0] CSR_MSTATUS = 12'h300;
localparam logic [11:0] CSR_MTVEC   = 12'h305;
localparam logic [11:0] CSR_MEPC    = 12'h341;


// =========================================================================
// CSR READ LOGIC
// =========================================================================

always_comb begin

    csr_read_data = 32'd0;

    case (csr_addr)

        CSR_MSTATUS: begin
            csr_read_data    = 32'd0;
            csr_read_data[3] = mstatus_mie;
            csr_read_data[7] = mstatus_mpie;
        end

        CSR_MTVEC: begin
            csr_read_data = mtvec;
        end

        CSR_MEPC: begin
            csr_read_data = mepc;
        end

        default: begin
            csr_read_data = 32'd0;
        end

    endcase

end


// =========================================================================
// MTVEC
//
// Holds the address to jump to when a trap/interrupt is taken.
//
// Example:
//
//      csrw mtvec, x5
//
// causes:
//
//      mtvec <- x5
// =========================================================================

always_ff @(posedge clk) begin

    if (rst) begin

        mtvec <= 32'h0000_0800;

    end

    else if (
        csr_write &&
        (csr_addr == CSR_MTVEC)
    ) begin

        // Direct-mode trap address must be aligned
        mtvec <= {csr_write_data[31:2], 2'b00};

    end

end


// =========================================================================
// MEPC
//
// Holds the PC that execution returns to after MRET.
//
// Hardware writes it automatically on interrupt entry.
// Software may also access it using CSR instructions.
// =========================================================================

always_ff @(posedge clk) begin

    if (rst) begin

        mepc <= 32'd0;

    end

    // Hardware trap entry gets priority
    else if (trap_enter) begin

        mepc <= {trap_pc[31:2], 2'b00};

    end

    else if (
        csr_write &&
        (csr_addr == CSR_MEPC)
    ) begin

        mepc <= {csr_write_data[31:2], 2'b00};

    end

end


// =========================================================================
// MSTATUS
//
// MIE  = bit 3
// MPIE = bit 7
//
// Trap entry:
//
//      MPIE <- MIE
//      MIE  <- 0
//
// MRET:
//
//      MIE  <- MPIE
//      MPIE <- 1
//
// Software can also modify these bits using CSR instructions.
// =========================================================================

always_ff @(posedge clk) begin

    if (rst) begin

        mstatus_mie  <= 1'b0;
        mstatus_mpie <= 1'b1;

    end

    // Hardware trap entry gets priority
    else if (trap_enter) begin

        mstatus_mpie <= mstatus_mie;
        mstatus_mie  <= 1'b0;

    end

    // MRET
    else if (trap_return) begin

        mstatus_mie  <= mstatus_mpie;
        mstatus_mpie <= 1'b1;

    end

    // Software CSR write
    else if (
        csr_write &&
        (csr_addr == CSR_MSTATUS)
    ) begin

        mstatus_mie  <= csr_write_data[3];
        mstatus_mpie <= csr_write_data[7];

    end

end


endmodule