`timescale 1ns / 1ps

module top_if (
    input clk,
    input [31:0] pc_from_exmem,
    input pcsrc,
    input reset,
    output [31:0] if_pc_out,
    output [31:0] if_instr_out
);   
    wire [31:0] mux_out;
    wire [31:0] adder_out;
    wire [31:0] instr_mem_out;
    wire [31:0] pc_out;
    
    mux dut_mux (
        .select(pcsrc),
        .in_0(adder_out),
        .in_1(pc_from_exmem),
        .mux_out(mux_out)
    );   
        
    instr_mem dut_instr_mem (
        .reset(reset),
        .address(pc_out),
        .clk(clk),
        .instruction(instr_mem_out)
    );
    
    adder dut_adder (
        .a(pc_out),
        .adder_out(adder_out)
    );
        
    pc dut_pc (
        .reset(reset),
        .pc_inp(mux_out),
        .clk(clk),
        .pc_out(pc_out)
    );    
    
    if_latch dut_latch (
        .reset(reset),
        .clk(clk),
        .if_instr_in(instr_mem_out),
        .if_pc_in(adder_out),
        .if_pc_out(if_pc_out),
        .if_instr_out(if_instr_out)
    );

endmodule