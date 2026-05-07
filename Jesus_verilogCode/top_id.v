`timescale 1ns / 1ps

module top_id(
    input wire clk,
    input wire reset,
    input wire wb_reg_write,
    input wire [4:0] wb_write_reg_location,
    input wire [31:0] mem_wb_write_data,
    input wire [31:0] if_id_instr,
    input wire [31:0] if_id_npc,

    output wire [4:0] id_ex_rs,
    output wire [1:0] id_ex_wb,
    output wire [2:0] id_ex_mem,
    output wire [3:0] id_ex_execute,
    output wire [31:0] id_ex_npc,
    output wire [31:0] id_ex_readdat1,
    output wire [31:0] id_ex_readdat2,
    output wire [31:0] id_ex_sign_ext,
    output wire [4:0] id_ex_instr_bits_20_16,
    output wire [4:0] id_ex_bits_15_11
);

    //internal
    wire [31:0] sign_ext_internal, readdat1_internal, readdat2_internal;
    wire [1:0] wb_internal;
    wire [2:0] mem_internal;
    wire [3:0] ex_internal;
    
    assign id_ex_rs = if_id_instr[25:21];
    
    sign_ext sE0(
        //complete parameters
        .immediate(if_id_instr[15:0]),
        .extended(sign_ext_internal) 
    );
    
    regfile rf0(
    // COMPLETE PARAMETERS
    .clk(clk),
    .reset(reset),
    .regwrite(wb_reg_write),
    .rs(if_id_instr[25:21]),
    .rt(if_id_instr[20:16]),
    .rd(wb_write_reg_location),
    .writedata(mem_wb_write_data),
    .A_readdat1(readdat1_internal),
    .B_readdat2(readdat2_internal)
);


    control c0 (
        
        .reset(reset),
        .opcode(if_id_instr[31:26]),
        .wb(wb_internal),
        .mem(mem_internal),
        .ex(ex_internal)
       
    );
    
    idExLatch iEL0(
        .clk(clk),
        .reset(reset),
        .ctl_wb(wb_internal),
        .ctl_mem(mem_internal),
        .ctl_ex(ex_internal),
        .npc(if_id_npc),
        .readdat1(readdat1_internal),
        .readdat2(readdat2_internal),
        .sign_ext(sign_ext_internal),
        .instr_bits_20_16(if_id_instr[20:16]),
        .instr_bits_15_11(if_id_instr[15:11]),

        .wb_out(id_ex_wb),
        .mem_out(id_ex_mem),
        .ctl_out(id_ex_execute),
        .npc_out(id_ex_npc),
        .readdat1_out(id_ex_readdat1),
        .readdat2_out(id_ex_readdat2),
        .sign_ext_out(id_ex_sign_ext),
        .instr_bits_20_16_out(id_ex_instr_bits_20_16),
        .instr_bits_15_11_out(id_ex_bits_15_11)
);

endmodule