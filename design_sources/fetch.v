`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 01:10:51 PM
// Design Name: 
// Module Name: fetch
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


module fetch(
    input  wire        clk,
    input  wire        rst,
    input  wire        ex_mem_pc_src, // PCSrc signal
    input  wire [31:0] ex_mem_npc,    // Target PC from Execute/Memory stage
    output wire [31:0] if_id_instr,   // Instruction passed to ID stage
    output wire [31:0] if_id_npc      // PC+4 passed to ID stage
);

    // Internal Wires
    wire [31:0] pc_current;
    wire [31:0] pc_next_val;
    wire [31:0] pc_mux_out;
    wire [31:0] instruction_raw;

    // 1. Mux: Selects between Incremented PC and Branch Target
    mux m0 (
        .y(pc_mux_out),
        .a_true(ex_mem_npc),    // Input 1
        .b_false(pc_next_val),  // Input 0 (PC+4)
        .sel(ex_mem_pc_src)
    );

    // 2. PC Register
    pc pc0 (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_mux_out),
        .pc_out(pc_current)
    );

    // 3. Incrementer (PC + 4)
    incrementer in0 (
        .pcin(pc_current),
        .pcout(pc_next_val)
    );

    // 4. Instruction Memory
    instrMem inMem0 (
        .clk(clk),
        .addr(pc_current),
        .data(instruction_raw)
    );

    // 5. IF/ID Latch: Passes PC+4 and Instruction to the next stage
    ifIdLatch ifIdLatch0 (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_next_val),
        .instr_in(instruction_raw),
        .pc_out(if_id_npc),
        .instr_out(if_id_instr)
    );

endmodule
