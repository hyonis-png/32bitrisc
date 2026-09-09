import cpu_types_pkg::*;

module icache (
    input  logic   clk,
    input  logic   rst,

    input  word_t  pc,
    input  instr_t imem_raw_instruction,

    output instr_t instruction,
    output logic   cache_hit
);

    // --------------------------------
    // Address split
    // [31:6] = tag
    // [5:2]  = index
    // [1:0]  = unused (byte offset)
    // --------------------------------

    logic [3:0]  index;
    logic [25:0] tag;

    assign index = pc[5:2];
    assign tag   = pc[31:6];


    // --------------------------------
    // 16 cache entries
    // --------------------------------

    logic        valid_array [0:15];
    logic [25:0] tag_array   [0:15];
    instr_t      data_array  [0:15];


    // --------------------------------
    // Cache lookup
    // --------------------------------

    assign cache_hit =
        valid_array[index] &&
        (tag_array[index] == tag);


    // --------------------------------
    // Instruction output
    //
    // Hit  -> cached instruction
    // Miss -> instruction from imem
    // --------------------------------

    always_comb begin

        if (cache_hit)
            instruction = data_array[index];

        else
            instruction = imem_raw_instruction;

    end


    // --------------------------------
    // Cache fill
    // --------------------------------

    integer i;

    always_ff @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < 16; i = i + 1) begin
                valid_array[i] <= 1'b0;
            end

        end

        else begin

            if (!cache_hit) begin

                // Store instruction from imem
                data_array[index] <= imem_raw_instruction;

                // Remember which address owns this entry
                tag_array[index] <= tag;

                // Entry now contains a valid instruction
                valid_array[index] <= 1'b1;

            end

        end

    end

endmodule