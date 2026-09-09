import cpu_types_pkg::*;

module dcache (
    input  logic        clk,
    input  logic        rst,

    input  word_t       mem_alu_result,
    input  logic        mem_mem_read,
    input  logic        mem_mem_write,
    input  word_t       mem_write_data,
    input  load_type_t  mem_load_type,
    input  store_type_t mem_store_type,
    input logic cacheable,
    

    // Raw 32-bit word coming from dmem
    input  word_t       dmem_raw_word,

    output word_t       read_data,
    output logic        cache_hit
);



    // --------------------------------
    // Address split
    // [31:6] = tag
    // [5:2]  = index
    // [1:0]  = byte offset
    // --------------------------------

    logic [3:0]  index;
    logic [25:0] tag;

    assign index = mem_alu_result[5:2];
    assign tag   = mem_alu_result[31:6];


    // --------------------------------
    // 16 cache entries
    // --------------------------------

    logic        valid_array [0:15];
    logic [25:0] tag_array   [0:15];
    word_t       data_array  [0:15];


    // --------------------------------
    // Cache lookup
    // --------------------------------

    assign cache_hit =
    cacheable &&
    valid_array[index] &&
    (tag_array[index] == tag);
    //
    // Hit  -> cache
    // Miss -> dmem
    // --------------------------------

    word_t raw_data;

    always_comb begin
        if (cache_hit)
            raw_data = data_array[index];
        else
            raw_data = dmem_raw_word;
    end


    // --------------------------------
    // Load processing
    // --------------------------------

    always_comb begin

        case (mem_load_type)

            LOAD_W: begin
                read_data = raw_data;
            end


            LOAD_B: begin
                case (mem_alu_result[1:0])

                    2'b00:
                        read_data =
                            {{24{raw_data[7]}},
                             raw_data[7:0]};

                    2'b01:
                        read_data =
                            {{24{raw_data[15]}},
                             raw_data[15:8]};

                    2'b10:
                        read_data =
                            {{24{raw_data[23]}},
                             raw_data[23:16]};

                    2'b11:
                        read_data =
                            {{24{raw_data[31]}},
                             raw_data[31:24]};

                endcase
            end


            LOAD_BU: begin
                case (mem_alu_result[1:0])

                    2'b00:
                        read_data = {24'b0, raw_data[7:0]};

                    2'b01:
                        read_data = {24'b0, raw_data[15:8]};

                    2'b10:
                        read_data = {24'b0, raw_data[23:16]};

                    2'b11:
                        read_data = {24'b0, raw_data[31:24]};

                endcase
            end


            LOAD_H: begin
                if (mem_alu_result[1] == 1'b0)
                    read_data =
                        {{16{raw_data[15]}},
                         raw_data[15:0]};
                else
                    read_data =
                        {{16{raw_data[31]}},
                         raw_data[31:16]};
            end


            LOAD_HU: begin
                if (mem_alu_result[1] == 1'b0)
                    read_data =
                        {16'b0, raw_data[15:0]};
                else
                    read_data =
                        {16'b0, raw_data[31:16]};
            end


            default: begin
                read_data = 32'd0;
            end

        endcase

    end


    // --------------------------------
    // Cache fill + store update
    // --------------------------------

    integer i;

    always_ff @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < 16; i = i + 1) begin
                valid_array[i] <= 1'b0;
            end

        end

        else begin

            // -------------------------
            // LOAD MISS
            // -------------------------
            if (cacheable  && mem_mem_read && !cache_hit) begin

                data_array[index]  <= dmem_raw_word;
                tag_array[index]   <= tag;
                valid_array[index] <= 1'b1;

            end


            // -------------------------
            // STORE HIT
            // -------------------------
            else if (cacheable && mem_mem_write && cache_hit) begin

                case (mem_store_type)

                    STORE_W: begin
                        data_array[index] <= mem_write_data;
                    end


                    STORE_H: begin

                        case (mem_alu_result[1])

                            1'b0:
                                data_array[index] <= {
                                    data_array[index][31:16],
                                    mem_write_data[15:0]
                                };

                            1'b1:
                                data_array[index] <= {
                                    mem_write_data[15:0],
                                    data_array[index][15:0]
                                };

                        endcase

                    end


                    STORE_B: begin

                        case (mem_alu_result[1:0])

                            2'b00:
                                data_array[index] <= {
                                    data_array[index][31:8],
                                    mem_write_data[7:0]
                                };

                            2'b01:
                                data_array[index] <= {
                                    data_array[index][31:16],
                                    mem_write_data[7:0],
                                    data_array[index][7:0]
                                };

                            2'b10:
                                data_array[index] <= {
                                    data_array[index][31:24],
                                    mem_write_data[7:0],
                                    data_array[index][15:0]
                                };

                            2'b11:
                                data_array[index] <= {
                                    mem_write_data[7:0],
                                    data_array[index][23:0]
                                };

                        endcase

                    end


                    default: begin
                        data_array[index] <= data_array[index];
                    end

                endcase

            end

        end

    end

endmodule