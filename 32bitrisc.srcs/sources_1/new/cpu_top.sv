`timescale 1ns / 1ps
import cpu_types_pkg::*;

module cpu_top (
    input  logic        clk,
    input  logic        rst,
    input  logic        enable,
    input  logic [3:0]  sw,
    output logic [3:0]  led_out,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_x5,
    output word_t debug_x8,
    
    // --- NEW UART MMIO PORTS ---
    output logic [7:0]  uart_tx_data,
    output logic        uart_tx_start,
    input  logic        uart_tx_busy,
    
    input  logic [7:0]  uart_rx_data,
    input  logic        uart_rx_valid,
    output logic        debug_mem_write_seen,
    output logic        debug_uart_addr_seen

);

    // =========================================================================
    // EXPLICIT WIRE DECLARATIONS (Fixes Vivado Implicit Net Warnings/Errors)
    // =========================================================================
    word_t      writeback_data;
    reg_addr_t  wb_rd;
    logic       wb_reg_write;
    
    // MEM-stage signals are declared early because the UART handshake uses them.
    word_t      mem_alu_result;
    word_t      mem_write_data;
    word_t      mem_pc_plus4;
    reg_addr_t  mem_rd;

    logic       mem_reg_write;
    logic       mem_mem_read;
    logic       mem_mem_write;
    logic       mem_mem_to_reg;
    logic       mem_jal_to_reg;

    logic hazard_stall;
    logic branch_taken;
    logic uart_write_request;
    logic uart_wait;
    word_t ex_branch_target;

    // =========================================================================
    // GLOBAL STALL & ENABLE NETWORK
    // =========================================================================
    logic global_stall;

    // A UART TX write is a store to MMIO address 0x8000_000C.
    assign uart_write_request =
        mem_mem_write &&
        enable &&
        (mem_alu_result == 32'h8000_000C);

    // If the UART is busy, keep the store instruction in MEM until it can be accepted.
    assign uart_wait =
        uart_write_request &&
        uart_tx_busy;

    assign global_stall =
        !enable ||
        uart_wait;

    logic if_id_stall;
    logic id_ex_stall;
    logic ex_mem_stall;
    logic mem_wb_stall;

    // Route stall logic per pipeline stage
    assign if_id_stall  = global_stall || hazard_stall;
    assign id_ex_stall  = global_stall;
    assign ex_mem_stall = global_stall;
    assign mem_wb_stall = global_stall;

    // =========================================================================
    // STAGE 1: FETCH
    // =========================================================================
    instr_t id_instruction;
    word_t  id_pc;

    if_stage if_stage_inst (
        .clk(clk),
        .rst(rst),
        .stall(if_id_stall), 
        .branch_taken(branch_taken),
        .branch_target(ex_branch_target),
        .instr_id_out(id_instruction),
        .pc_id_out(id_pc)
    );

    // =========================================================================
    // STAGE 2: DECODE
    // =========================================================================
    reg_addr_t id_rs1, id_rs2, id_rd;
    word_t     id_imm;
    alu_op_t   id_alu_control;

    logic id_reg_write;
    logic id_alu_src;
    logic id_mem_read;
    logic id_mem_write;
    logic id_mem_to_reg;
    logic id_jal_to_reg;

    logic id_branch_eq;
    logic id_branch_ne;
    logic id_branch_lt;
    logic id_branch_mt;
    logic id_jump;
    logic id_jalr;

    word_t id_rs1_data;
    word_t id_rs2_data;

    instr_decoder decoder_inst (
        .instruction(id_instruction),

        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_rd),
        .imm(id_imm),

        .alu_control(id_alu_control),
        .reg_write(id_reg_write),
        .alu_src(id_alu_src),

        .branch_eq(id_branch_eq),
        .branch_ne(id_branch_ne),
        .branch_lt(id_branch_lt),
        .branch_mt(id_branch_mt),

        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg),

        .jal_to_reg(id_jal_to_reg),
        .jump(id_jump),
        .jalr(id_jalr)
    );

    regfile my_regfile (
        .clk(clk),
        .rst(rst),
        .rs1(id_rs1),                
        .rs2(id_rs2),                
        .rd(wb_rd),                  
        .write_data(writeback_data), 
        .reg_write(wb_reg_write),    
        .read_data1(id_rs1_data),    
        .read_data2(id_rs2_data),    
        .debug_x8(debug_x8),
        .debug_x5(debug_x5)        
    );

    // =========================================================================
    // PIPELINE WALL 1: ID/EX
    // =========================================================================
    word_t     ex_pc;
    word_t     ex_pc_plus4;
    word_t     ex_rs1_data;
    word_t     ex_rs2_data;
    word_t     ex_imm;

    reg_addr_t ex_rd;
    reg_addr_t ex_rs1;
    reg_addr_t ex_rs2;

    alu_op_t ex_alu_control;

    logic ex_reg_write;
    logic ex_alu_src;
    logic ex_mem_read;
    logic ex_mem_write;
    logic ex_mem_to_reg;
    logic ex_jal_to_reg;

    logic ex_branch_eq;
    logic ex_branch_ne;
    logic ex_jump;
    logic ex_jalr;

    id_ex_reg id_ex_register_inst (
        .clk(clk),
        .rst(rst),
        .flush(!global_stall && (hazard_stall || branch_taken)), 
        .stall(id_ex_stall), 

        .id_pc(id_pc),
        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data),
        .id_imm(id_imm),

        .id_rd(id_rd),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),

        .id_alu_control(id_alu_control),

        .id_reg_write(id_reg_write),
        .id_alu_src(id_alu_src),
        .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_jal_to_reg(id_jal_to_reg),

        .id_jump(id_jump),
        .id_jalr(id_jalr),

        .id_branch_eq(id_branch_eq),
        .id_branch_ne(id_branch_ne),

        .ex_pc(ex_pc),
        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_imm(ex_imm),

        .ex_rd(ex_rd),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),

        .ex_alu_control(ex_alu_control),

        .ex_reg_write(ex_reg_write),
        .ex_alu_src(ex_alu_src),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_jal_to_reg(ex_jal_to_reg),

        .ex_jump(ex_jump),
        .ex_jalr(ex_jalr),

        .ex_branch_eq(ex_branch_eq),
        .ex_branch_ne(ex_branch_ne)
    );

    assign ex_pc_plus4 = ex_pc + 32'd4;

    // =========================================================================
    // STAGE 3: EXECUTE
    // =========================================================================
    logic [1:0] forward_A;
    logic [1:0] forward_B;

    word_t final_alu_A;
    word_t forwarded_rs2_data;
    word_t ex_alu_B;
    word_t ex_alu_result;

    logic ex_alu_less;
    logic ex_alu_more;
    word_t mem_forward_data;

assign mem_forward_data =
    mem_jal_to_reg ? mem_pc_plus4 :
                     mem_alu_result;

   assign final_alu_A =
    (forward_A == 2'b01) ? mem_forward_data :
    (forward_A == 2'b10) ? writeback_data    :
                           ex_rs1_data;
    assign forwarded_rs2_data =
    (forward_B == 2'b01) ? mem_forward_data :
    (forward_B == 2'b10) ? writeback_data    :
                           ex_rs2_data;

    assign ex_alu_B = ex_alu_src ? ex_imm : forwarded_rs2_data;

    ALU alu_inst (
        .A(final_alu_A),
        .B(ex_alu_B),
        .alu_control(ex_alu_control),
        .result(ex_alu_result),
        .alu_less(ex_alu_less),
        .alu_more(ex_alu_more)
    );

    assign ex_branch_target =
        ex_jalr ? ((final_alu_A + ex_imm) & 32'hFFFF_FFFE)
                : (ex_pc + ex_imm);

    // =========================================================================
    // PIPELINE WALL 2: EX/MEM
    // =========================================================================
    ex_mem_reg ex_mem_register_inst (
        .clk(clk),
        .rst(rst),
        .stall(ex_mem_stall), 

        .ex_alu_result(ex_alu_result),
        .ex_write_data(forwarded_rs2_data),
        .ex_pc_plus4(ex_pc_plus4),
        .ex_rd(ex_rd),

        .ex_reg_write(ex_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_jal_to_reg(ex_jal_to_reg),

        .mem_alu_result(mem_alu_result),
        .mem_write_data(mem_write_data),
        .mem_pc_plus4(mem_pc_plus4),
        .mem_rd(mem_rd),

        .mem_reg_write(mem_reg_write),
        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_jal_to_reg(mem_jal_to_reg)
    );

    // =========================================================================
    // STAGE 4: MEMORY (With Intercept Railroad Muxing)
    // =========================================================================
    word_t mem_dmem_read_data;
    word_t mem_ram_read_data;
    logic  is_mmio;
    
    // Address check: If it starts with 8 or higher, is_mmio turns TRUE (1)
    assign is_mmio = (mem_alu_result >= 32'h8000_0000);

    // 1. Data Memory (Silenced when talking to FPGA pins/peripherals)
    dmem dmem_inst (
        .clk(clk),
        .mem_read(mem_mem_read && enable && !is_mmio),   
        .mem_write(mem_mem_write && enable && !is_mmio), 
        .addr(mem_alu_result),
        .write_data(mem_write_data),
        .read_data(mem_ram_read_data)
    );

    // --- UART RX Holding Buffer Logic ---
    logic [7:0] rx_buffer;
    logic       rx_data_ready;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_buffer      <= 8'd0;
            rx_data_ready  <= 1'b0;
        end else begin
            if (uart_rx_valid) begin
                rx_buffer     <= uart_rx_data;  
                rx_data_ready <= 1'b1;          
            end 
            else if (mem_mem_read && enable && (mem_alu_result == 32'h8000_000C)) begin
                rx_data_ready <= 1'b0;
            end
        end
    end

    // --- UART TX Pulse Trigger ---
    assign uart_tx_data = mem_write_data[7:0];

    // One-cycle start pulse when the pending store is accepted.
    assign uart_tx_start =
        uart_write_request &&
        !uart_tx_busy;

    // 2. The Return Mux (Decides what data is packed into the CPU backpack)
    always_comb begin
        if (is_mmio) begin
            case (mem_alu_result)
                32'h8000_0000: mem_dmem_read_data = {28'd0, sw}; 
                32'h8000_0008: mem_dmem_read_data = {30'd0, rx_data_ready, uart_tx_busy};
                32'h8000_000C: mem_dmem_read_data = {24'd0, rx_buffer};
                default:       mem_dmem_read_data = 32'd0;
            endcase
        end else begin
            mem_dmem_read_data = mem_ram_read_data;
        end
    end
    
    always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        debug_mem_write_seen <= 1'b0;
        debug_uart_addr_seen <= 1'b0;
    end
    else begin
        // CPU executed any store instruction
        if (mem_mem_write)
            debug_mem_write_seen <= 1'b1;

        // CPU executed a store to the UART TX address
        if (
            mem_mem_write &&
            enable &&
            (mem_alu_result == 32'h8000_000C)
        )
            debug_uart_addr_seen <= 1'b1;
    end
end

    // 3. Drive physical LEDs
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            led_out <= 4'd0;
        else if (uart_tx_start)
            led_out <= led_out + 1'b1;
    end

    // =========================================================================
    // PIPELINE WALL 3: MEM/WB
    // =========================================================================
    word_t     wb_alu_result;
    word_t     wb_read_data;
    word_t     wb_pc_plus4;

    logic wb_mem_to_reg;
    logic wb_jal_to_reg;

    mem_wb_reg mem_wb_register_inst (
        .clk(clk),
        .rst(rst),
        .stall(mem_wb_stall), 

        .mem_alu_result(mem_alu_result),
        .mem_read_data(mem_dmem_read_data), 
        .mem_pc_plus4(mem_pc_plus4),

        .mem_rd(mem_rd),

        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_jal_to_reg(mem_jal_to_reg),

        .wb_alu_result(wb_alu_result),
        .wb_read_data(wb_read_data),
        .wb_pc_plus4(wb_pc_plus4),

        .wb_rd(wb_rd),

        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_jal_to_reg(wb_jal_to_reg)
    );

    // =========================================================================
    // STAGE 5: WRITEBACK
    // =========================================================================
    assign writeback_data =
        wb_jal_to_reg ? wb_pc_plus4 :
        wb_mem_to_reg ? wb_read_data :
                        wb_alu_result;

    // =========================================================================
    // FORWARDING UNIT
    // =========================================================================
    always_comb begin
        forward_A = 2'b00; 
        if (wb_reg_write && (wb_rd != 5'd0) && (wb_rd == ex_rs1)) begin
            forward_A = 2'b10;
        end
        if (mem_reg_write && (mem_rd != 5'd0) && (mem_rd == ex_rs1)) begin
            forward_A = 2'b01;
        end

        forward_B = 2'b00; 
        if (wb_reg_write && (wb_rd != 5'd0) && (wb_rd == ex_rs2)) begin
            forward_B = 2'b10;
        end
        if (mem_reg_write && (mem_rd != 5'd0) && (mem_rd == ex_rs2)) begin
            forward_B = 2'b01;
        end
    end

    // =========================================================================
    // LOAD-USE HAZARD DETECTION
    // =========================================================================
    always_comb begin
        if (ex_mem_read &&
            (ex_rd != 5'd0) &&
            ((ex_rd == id_rs1) || (ex_rd == id_rs2))) begin
            hazard_stall = 1'b1;
        end
        else begin
            hazard_stall = 1'b0;
        end
    end

    // =========================================================================
    // CONTROL HAZARD / BRANCH DECISION
    // =========================================================================
    always_comb begin
        if ((ex_branch_eq && !ex_alu_less && !ex_alu_more) ||
            (ex_branch_ne && (ex_alu_less || ex_alu_more)) ||
            ex_jump ||
            ex_jalr) begin
            branch_taken = 1'b1;
        end
        else begin
            branch_taken = 1'b0;
        end
    end

    assign debug_pc = id_pc;

endmodule