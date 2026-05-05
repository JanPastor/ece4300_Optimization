`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: forwarding_unit
// Description: Detects data hazards and generates forwarding mux selects.
//              Compares source registers (rs, rt) of the current instruction
//              in the EX stage against destination registers of instructions
//              in the MEM and WB stages.
//
// Forward encoding:
//   2'b00 = No forwarding (use register file value)
//   2'b10 = Forward from EX/MEM (result from 1 cycle ago)
//   2'b01 = Forward from MEM/WB (result from 2 cycles ago)
//////////////////////////////////////////////////////////////////////////////////

module forwarding_unit(
    input wire [4:0] id_ex_rs,          // Source register 1 of current instr
    input wire [4:0] id_ex_rt,          // Source register 2 of current instr
    input wire [4:0] ex_mem_rd,         // Dest register from EX/MEM latch
    input wire       ex_mem_regwrite,   // RegWrite from EX/MEM latch
    input wire [4:0] mem_wb_rd,         // Dest register from MEM/WB latch
    input wire       mem_wb_regwrite,   // RegWrite from MEM/WB latch
    output reg [1:0] forward_a,         // Mux select for ALU input A
    output reg [1:0] forward_b          // Mux select for ALU input B
);

    always @* begin
        // Default: no forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;

        // --- EX Hazard (highest priority: most recent result) ---
        // Forward from EX/MEM if previous instruction writes to a register
        // that the current instruction reads as rs
        if (ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs))
            forward_a = 2'b10;
        if (ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rt))
            forward_b = 2'b10;

        // --- MEM Hazard (lower priority: only if EX hazard doesn't cover it) ---
        // Forward from MEM/WB if the instruction two cycles ago writes to
        // a register that the current instruction reads
        if (mem_wb_regwrite && (mem_wb_rd != 5'b0)
            && !(ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs))
            && (mem_wb_rd == id_ex_rs))
            forward_a = 2'b01;
        if (mem_wb_regwrite && (mem_wb_rd != 5'b0)
            && !(ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rt))
            && (mem_wb_rd == id_ex_rt))
            forward_b = 2'b01;
    end

endmodule
