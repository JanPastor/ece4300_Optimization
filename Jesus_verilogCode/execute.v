`timescale 1ns / 1ps
/*
Execute Stage: This uses the outputs of Fetch and Decode Stages as well as combining the modules: adder, bottom_mux(5-bit), alu_control, alu, top_mux (32-bit),
and ex_mem.
*/
module execute (
    input clk,
    input reset,
    input wire [1:0] wb_ctl,  //11 inputs, based off of outputs of ID/EX latch (Lab 2-2)
    input wire [2:0] m_ctl,
    input wire regdst, alusrc,
    input wire [1:0] aluop, 
    input wire [5:0] funct,
    input wire [31:0] npcout, rdata1, rdata2, s_extendout,
    input wire [4:0] instrout_2016, instrout_1511,
    
    input wire [1:0] ForwardA,
    input wire [1:0] ForwardB,
    input wire [31:0] EX_MEM_forward_data,
    input wire [31:0] MEM_WB_forward_data,
    
    output wire [1:0] wb_ctlout, //9 total outputs from EX/MEM latch
    output wire branch, memread, memwrite,
    output wire [31:0] EX_MEM_NPC,
    output wire zero,
    output wire [31:0] alu_result, rdata2out,
    output wire [4:0] five_bit_muxout
);

    wire [31:0] adder_out, b, aluout;//internal wires to connect internal EXECUTE components together
    wire [31:0] alu_a_forwarded;
    wire [31:0] rdata2_forwarded;
    
    wire [4:0] muxout;
    wire [2:0] control;
    wire aluzero;
    
    assign alu_a_forwarded =
        (ForwardA == 2'b10) ? EX_MEM_forward_data :
        (ForwardA == 2'b01) ? MEM_WB_forward_data :
                              rdata1;

    assign rdata2_forwarded =
        (ForwardB == 2'b10) ? EX_MEM_forward_data :
        (ForwardB == 2'b01) ? MEM_WB_forward_data :
                              rdata2;
    
    adder_ex adder3(
        .add_in1(npcout),
        .add_in2(s_extendout),
        .add_out(adder_out)
    );
    
    bottom_mux bottom_mux3(
        .a(instrout_1511),  //in case of error, check this
        .b(instrout_2016),
        .sel(regdst),  
        .y(muxout)
    ); 
    
    alu_control alu_control3(
        .funct(funct),
        .aluop(aluop),
        .select(control)
    );
    
    alu alu3(
        .a(alu_a_forwarded),
        .b(b), // b <= output of top_mux
        .control(control),
        .result(aluout),
        .zero(aluzero)
    );
    
    top_mux top_mux3(
        .y(b), // output of mux is 32 bit "b" wire
        .a(s_extendout), 
        .b(rdata2_forwarded), // input a = 1'b1, b = 1'b0
        .alusrc(alusrc)
    );
    
    ex_mem ex_mem3(
        .clk(clk),
        .reset(reset),
        .ctlwb_out(wb_ctl), // inputs, which should stem from intermediate modules 
        .ctlm_out(m_ctl),
        .adder_out(adder_out),
        .aluzero(aluzero),
        .aluout(aluout), 
        .readdat2(rdata2_forwarded),
        .muxout(muxout), 
        .wb_ctlout(wb_ctlout), // outputs going to FETCH or MEM/WB
        .branch(branch), 
        .memread(memread), 
        .memwrite(memwrite), 
        .add_result(EX_MEM_NPC),
        .zero(zero),
        .alu_result(alu_result), 
        .rdata2out(rdata2out),
        .five_bit_muxout(five_bit_muxout)
    );
    
endmodule // IEXECUTE


