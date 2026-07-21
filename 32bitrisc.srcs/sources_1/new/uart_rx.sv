`timescale 1ns / 1ps

module uart_rx(

    input  logic       clk,
    input  logic       rst,

    input  logic       rx,

    output logic [7:0] data,
    output logic       valid

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
    // UART Receiver
    //---------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            state        <= IDLE;
            valid        <= 1'b0;
            data         <= 8'd0;

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

                valid <= 1'b0;

                baud_counter <= 0;
                bit_counter  <= 0;

                if (rx == 1'b0) begin
                    state <= START;
                end

            end

            //-------------------------------------------------
            // START BIT
            //-------------------------------------------------
            START: begin

                if (baud_counter == (BAUD_DIV/2)) begin

                    if (rx == 1'b0) begin

                        baud_counter <= 0;
                        bit_counter  <= 0;

                        state <= DATA;

                    end
                    else begin

                        // False start
                        state <= IDLE;

                    end

                end
                else begin

                    baud_counter <= baud_counter + 1;

                end

            end

            //-------------------------------------------------
            // DATA
            //-------------------------------------------------
            DATA: begin

                if (baud_counter == BAUD_DIV-1) begin

                    baud_counter <= 0;

                    shift_reg[bit_counter] <= rx;

                    if (bit_counter == 3'd7) begin

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

                if (baud_counter == BAUD_DIV-1) begin

                    baud_counter <= 0;

                    if (rx == 1'b1) begin

                        data  <= shift_reg;
                        valid <= 1'b1;

                    end

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

 