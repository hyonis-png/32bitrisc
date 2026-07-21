`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2026 11:13:00 PM
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_tx (
    input  logic       clk,      // Needs 100MHz raw clock
    input  logic       rst,      // Active-high system reset
    input  logic [7:0] data,     // The 8-bit ASCII character from the CPU
    input  logic       start,    // Pulse high for 1 cycle to send data
    output logic       tx,       // Connects to the physical FPGA Tx Pin
    output logic       busy      // Tells CPU if it is currently sending a byte
);
    //---------------------------------------------------------
    // Parameters
    //---------------------------------------------------------
    parameter CLK_FREQ = 100_000_000;
    parameter BAUD     = 115200;

    localparam integer BAUD_DIV = CLK_FREQ / BAUD;

    //---------------------------------------------------------
    // Registers
    //---------------------------------------------------------
    logic [15:0] baud_counter;
    logic [2:0]  bit_counter;
    logic [7:0]  shift_reg;

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    //---------------------------------------------------------
    // UART Transmitter
    //---------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            state        <= IDLE;

            tx           <= 1'b1;
            busy         <= 1'b0;

            baud_counter <= 16'd0;
            bit_counter  <= 3'd0;

            shift_reg    <= 8'd0;

        end

        else begin

            case(state)

            //-------------------------------------------------
            // IDLE
            //-------------------------------------------------
            IDLE: begin

                tx <= 1'b1;
                busy <= 1'b0;

                baud_counter <= 0;
                bit_counter  <= 0;

                if(start) begin

                    shift_reg <= data;

                    busy <= 1'b1;

                    state <= START;

                end

            end

            //-------------------------------------------------
            // START BIT
            //-------------------------------------------------
            START: begin

                tx <= 1'b0;

                if(baud_counter == BAUD_DIV-1) begin

                    baud_counter <= 0;

                    state <= DATA;

                end
                else begin

                    baud_counter <= baud_counter + 1;

                end

            end

            //-------------------------------------------------
            // DATA BITS
            //-------------------------------------------------
            DATA: begin

                tx <= shift_reg[0];

                if(baud_counter == BAUD_DIV-1) begin

                    baud_counter <= 0;

                    shift_reg <= shift_reg >> 1;

                    if(bit_counter == 3'd7) begin

                        bit_counter <= 0;

                        state <= STOP;

                    end
                    else begin

                        bit_counter <= bit_counter + 1;

                    end

                end
                else begin

                    baud_counter <= baud_counter + 1;

                end

            end

            //-------------------------------------------------
            // STOP BIT
            //-------------------------------------------------
            STOP: begin

                tx <= 1'b1;

                if(baud_counter == BAUD_DIV-1) begin

                    baud_counter <= 0;

                    busy <= 1'b0;

                    state <= IDLE;

                end
                else begin

                    baud_counter <= baud_counter + 1;

                end

            end

            endcase

        end

    end

endmodule

    