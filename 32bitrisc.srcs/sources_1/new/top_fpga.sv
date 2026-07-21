`timescale 1ns / 1ps

module top_fpga (
    input  logic        CLK100MHZ,
    input  logic [3:0]  btn,
    input  logic [3:0]  sw,

    input  logic        uart_rx,
    output logic        uart_tx,

    output logic [5:2]  led
);

    //---------------------------------------------------------
    // Reset
    //---------------------------------------------------------
    logic sys_reset;
    assign sys_reset = btn[0];

    //---------------------------------------------------------
    // CPU debug
    //---------------------------------------------------------
    logic [31:0] debug_pc;
    logic [31:0] debug_x5;
    logic [3:0]  cpu_led_out;
    logic [31:0] debug_x8;
    logic debug_mem_write_seen;
    logic debug_uart_addr_seen;

    //---------------------------------------------------------
    // UART TX
    //---------------------------------------------------------
    logic [7:0] uart_tx_data;
    logic       uart_tx_start;
    logic       uart_tx_busy;

    //---------------------------------------------------------
    // UART RX
    //---------------------------------------------------------
    logic [7:0] uart_rx_data;
    logic       uart_rx_valid;

    //---------------------------------------------------------
    // Additional UART debug latches
    //---------------------------------------------------------
    logic uart_start_seen;
    logic uart_busy_seen;

    //---------------------------------------------------------
    // CPU
    //---------------------------------------------------------
    cpu_top cpu (
        .clk                    (CLK100MHZ),
        .rst                    (sys_reset),
        .enable                 (1'b1),

        .sw                     (sw),
        .led_out                (cpu_led_out),

        .uart_tx_data           (uart_tx_data),
        .uart_tx_start          (uart_tx_start),
        .uart_tx_busy           (uart_tx_busy),

        .uart_rx_data           (uart_rx_data),
        .uart_rx_valid          (uart_rx_valid),

        .debug_pc               (debug_pc),
        .debug_x5               (debug_x5),

        .debug_mem_write_seen   (debug_mem_write_seen),
        .debug_uart_addr_seen   (debug_uart_addr_seen)
    );

    //---------------------------------------------------------
    // UART transmitter
    //---------------------------------------------------------
    uart_tx tx_inst (
        .clk   (CLK100MHZ),
        .rst   (sys_reset),
        .data  (uart_tx_data),
        .start (uart_tx_start),
        .tx    (uart_tx),
        .busy  (uart_tx_busy)
    );

    //---------------------------------------------------------
    // UART receiver
    //---------------------------------------------------------
    uart_rx rx_inst (
        .clk   (CLK100MHZ),
        .rst   (sys_reset),
        .rx    (uart_rx),
        .data  (uart_rx_data),
        .valid (uart_rx_valid)
    );

    //---------------------------------------------------------
    // Latch short UART events so LEDs can display them
    //---------------------------------------------------------
    always_ff @(posedge CLK100MHZ or posedge sys_reset) begin
        if (sys_reset) begin
            uart_start_seen <= 1'b0;
            uart_busy_seen  <= 1'b0;
        end
        else begin
            if (uart_tx_start)
                uart_start_seen <= 1'b1;

            if (uart_tx_busy)
                uart_busy_seen <= 1'b1;
        end
    end

    //---------------------------------------------------------
    // LED debugging
    //---------------------------------------------------------
assign led[5:2] = debug_x8[3:0];
endmodule