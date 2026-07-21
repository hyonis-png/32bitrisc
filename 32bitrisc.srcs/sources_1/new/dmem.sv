`timescale 1ns / 1ps
import cpu_types_pkg::*;

module dmem (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    
    output logic [31:0] read_data
);

    // Create an internal RAM storage array (e.g., 16KB = 4096 words)
    // Adjust the depth (4096) to match whatever size you are using!
    logic [31:0] ram [0:4095];

    // Convert the raw byte address into a Word Address (divide by 4)
    // This strips off the bottom 2 bits because instructions/data are 4-byte aligned.
    logic [11:0] word_addr; 
    assign word_addr = addr[13:2]; 

    //------------------------------------------------------------------
    // Memory Write Operation (With Safety Address Filtering)
    //------------------------------------------------------------------
    always_ff @(posedge clk) begin
        // Only write to RAM if mem_write is active AND the address is low (starts with 0-7)
        // addr[31] == 1'b0 ensures we completely ignore MMIO addresses!
        if (mem_write && (addr[31] == 1'b0)) begin
            ram[word_addr] <= write_data;
        end
    end

    //------------------------------------------------------------------
    // Memory Read Operation
    //------------------------------------------------------------------
    always_comb begin
        if (mem_read && (addr[31] == 1'b0)) begin
            read_data = ram[word_addr];
        end else begin
            read_data = 32'd0; // Return 0 if not reading or if out of bounds
        end
    end

endmodule