`timescale 1ns / 1ps

module timer (
    input  logic        clk,
    input  logic        rst,

    // Free-running counter
    output logic [31:0] counter,

    // Compare register
    output logic [31:0] compare,
    input  logic        compare_write,
    input  logic [31:0] compare_write_data,

    // Timer interrupt enable
    output logic        irq_enable,
    input  logic        irq_enable_write,
    input  logic        irq_enable_write_data,

    // Interrupt
    input  logic        irq_clear,
    output logic        irq
);

    // ----------------------------------------------------
    // Free-running counter
    // ----------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 32'd0;
        else
            counter <= counter + 1'b1;
    end

    // ----------------------------------------------------
    // Compare register
    // ----------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            compare <= 32'd0;
        else if (compare_write)
            compare <= compare_write_data;
    end

    // ----------------------------------------------------
    // Interrupt enable register
    // ----------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            irq_enable <= 1'b0;
        else if (irq_enable_write)
            irq_enable <= irq_enable_write_data;
    end

    // ----------------------------------------------------
    // Interrupt pending register
    // ----------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            irq <= 1'b0;
        else if (irq_clear)
            irq <= 1'b0;
        else if (irq_enable && (counter == compare))
            irq <= 1'b1;
    end

endmodule