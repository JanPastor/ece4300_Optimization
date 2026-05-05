`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: mips_pipeline
// Description: Top-level wrapper connecting all 5 pipeline stages.
//              MODIFIED: Added forwarding unit for data hazard resolution.
//
// Control signal encoding (from control.v):
//   wb[1:0]  = {RegWrite, MemToReg}
//   mem[2:0] = {Branch, MemRead, MemWrite}
//   ex[3:0]  = {RegDst, ALUOp1, ALUOp0, ALUSrc}
//
// Program: (1 + 2) + 3 + 6 + 0 = 12, result in $r1
//////////////////////////////////////////////////////////////////////////////////

module mips_pipeline(
    input wire clk,
    input wire rst
);

    // =========================================================================
    //  Inter-stage wires
    // =========================================================================

    // --- IF -> ID ---
    wire [31:0] if_id_instr, if_id_npc;

    // --- ID -> EX (from idExLatch outputs inside decode) ---
    wire [1:0]  id_ex_wb;
    wire [2:0]  id_ex_mem;
    wire [3:0]  id_ex_ex;
    wire [31:0] id_ex_npc, id_ex_readdat1, id_ex_readdat2, id_ex_sign_ext;
    wire [4:0]  id_ex_instr_bits_25_21;   // rs (for forwarding)
    wire [4:0]  id_ex_instr_bits_20_16, id_ex_instr_bits_15_11;

    // --- EX -> MEM (from ex_mem latch outputs inside execute) ---
    wire [1:0]  ex_mem_wb;
    wire [2:0]  ex_mem_mem;
    wire [31:0] ex_mem_adder, ex_mem_alu_result, ex_mem_rdata2;
    wire [4:0]  ex_mem_write_reg;
    wire        ex_mem_zero;

    // --- MEM -> WB (from mem_wb latch outputs inside mem_stage) ---
    wire [31:0] mem_wb_read_data, mem_wb_alu_result;
    wire [4:0]  mem_wb_write_reg;
    wire [1:0]  mem_wb_wb;

    // --- Feedback signals ---
    wire        pc_src;
    wire [31:0] wb_write_data;

    // --- Forwarding signals ---
    wire [1:0]  forward_a, forward_b;

    // =========================================================================
    //  STAGE 5: WRITEBACK MUX (defined first so decode can use it)
    // =========================================================================
    // wb[1] = RegWrite,  wb[0] = MemToReg
    // MemToReg=1 -> select memory read data;  MemToReg=0 -> select ALU result
    assign wb_write_data = mem_wb_wb[0] ? mem_wb_read_data : mem_wb_alu_result;

    // =========================================================================
    //  FORWARDING UNIT
    // =========================================================================
    // Compares source registers of current EX-stage instruction (rs, rt)
    // with destination registers of instructions in MEM and WB stages.
    forwarding_unit fwd_unit (
        .id_ex_rs         (id_ex_instr_bits_25_21),  // rs from current instr
        .id_ex_rt         (id_ex_instr_bits_20_16),  // rt from current instr
        .ex_mem_rd        (ex_mem_write_reg),         // dest reg from MEM stage
        .ex_mem_regwrite  (ex_mem_wb[1]),             // RegWrite from MEM stage
        .mem_wb_rd        (mem_wb_write_reg),         // dest reg from WB stage
        .mem_wb_regwrite  (mem_wb_wb[1]),             // RegWrite from WB stage
        .forward_a        (forward_a),
        .forward_b        (forward_b)
    );

    // =========================================================================
    //  STAGE 1: FETCH
    // =========================================================================
    fetch stage1_fetch (
        .clk            (clk),
        .rst            (rst),
        .ex_mem_pc_src  (pc_src),
        .ex_mem_npc     (ex_mem_adder),
        .if_id_instr    (if_id_instr),
        .if_id_npc      (if_id_npc)
    );

    // =========================================================================
    //  STAGE 2: DECODE
    // =========================================================================
    decode stage2_decode (
        .clk                    (clk),
        .rst                    (rst),
        .wb_reg_write           (mem_wb_wb[1]),       // RegWrite from WB
        .wb_write_reg_location  (mem_wb_write_reg),   // Dest register from WB
        .mem_wb_write_data      (wb_write_data),      // Write-back data (mux output)
        .if_id_instr            (if_id_instr),
        .if_id_npc              (if_id_npc),
        .id_ex_wb               (id_ex_wb),
        .id_ex_mem              (id_ex_mem),
        .id_ex_execute          (id_ex_ex),
        .id_ex_npc              (id_ex_npc),
        .id_ex_readdat1         (id_ex_readdat1),
        .id_ex_readdat2         (id_ex_readdat2),
        .id_ex_sign_ext         (id_ex_sign_ext),
        .id_ex_instr_bits_25_21 (id_ex_instr_bits_25_21),
        .id_ex_instr_bits_20_16 (id_ex_instr_bits_20_16),
        .id_ex_instr_bits_15_11 (id_ex_instr_bits_15_11)
    );

    // =========================================================================
    //  STAGE 3: EXECUTE (with forwarding)
    // =========================================================================
    execute stage3_execute (
        .clk              (clk),
        .rst              (rst),
        .ctlwb_in         (id_ex_wb),
        .ctlm_in          (id_ex_mem),
        .npc              (id_ex_npc),
        .rdata1           (id_ex_readdat1),
        .rdata2           (id_ex_readdat2),
        .s_extend         (id_ex_sign_ext),
        .instr_2016       (id_ex_instr_bits_20_16),
        .instr_1511       (id_ex_instr_bits_15_11),
        .alu_op           (id_ex_ex[2:1]),           // ALUOp[1:0]
        .funct            (id_ex_sign_ext[5:0]),     // funct from sign-extended imm
        .alusrc           (id_ex_ex[0]),             // ALUSrc
        .regdst           (id_ex_ex[3]),             // RegDst
        // Forwarding connections
        .forward_a        (forward_a),
        .forward_b        (forward_b),
        .ex_mem_alu_fwd   (ex_mem_alu_result),       // Forward from EX/MEM
        .wb_write_data_fwd(wb_write_data),           // Forward from WB mux
        // Outputs
        .ctlwb_out        (ex_mem_wb),
        .ctlm_out         (ex_mem_mem),
        .adder_out        (ex_mem_adder),
        .alu_result_out   (ex_mem_alu_result),
        .rdata2_out       (ex_mem_rdata2),
        .muxout_out       (ex_mem_write_reg),
        .zero_out         (ex_mem_zero)
    );

    // =========================================================================
    //  STAGE 4: MEMORY
    // =========================================================================
    mem_stage stage4_memory (
        .clk            (clk),
        .ALUResult      (ex_mem_alu_result),
        .WriteData      (ex_mem_rdata2),
        .WriteReg       (ex_mem_write_reg),
        .WBControl      (ex_mem_wb),
        .MemWrite       (ex_mem_mem[0]),
        .MemRead        (ex_mem_mem[1]),
        .Branch         (ex_mem_mem[2]),
        .Zero           (ex_mem_zero),
        .ReadData       (mem_wb_read_data),
        .ALUResult_out  (mem_wb_alu_result),
        .WriteReg_out   (mem_wb_write_reg),
        .WBControl_out  (mem_wb_wb),
        .PCSrc          (pc_src)
    );

endmodule
