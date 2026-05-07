


`timescale 1ns / 1ps

module full_pipeline (
    input clk,
    input reset
);

    wire [31:0]pc_from_exmem;
    wire pcsrc;
    
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    
    wire [31:0] if_pc_out; 
    wire [31:0] if_instr_out;
    
    wire [1:0] id_ex_wb;
    wire [2:0] id_ex_mem;
    wire [3:0] id_ex_execute;
    wire [31:0] id_ex_npc;
    wire [31:0] id_ex_readdat1;
    wire [31:0] id_ex_readdat2;
    wire [31:0] id_ex_sign_ext;
    wire [4:0] id_ex_instr_bits_20_16;
    wire [4:0] id_ex_bits_15_11;
    wire [4:0] id_ex_rs;
    
    wire [1:0] ex_mem_wb_ctlout;
    wire ex_mem_branch;
    wire ex_mem_memread;
    wire ex_mem_memwrite;
    wire [31:0] ex_mem_npc;
    wire ex_mem_zero;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_rdata2out;
    wire [4:0] ex_mem_write_reg;
    
    wire MEM_WB_regwrite;
    wire MEM_WB_memtoreg;
    wire [31:0] read_data;
    wire [31:0] mem_alu_result;
    wire [4:0] mem_write_reg;
    wire [31:0] mem_wb_write_data;
    wire MEM_PCSrc;

    assign pc_from_exmem = ex_mem_npc;
    assign pcsrc = MEM_PCSrc;
    
   
top_if dut_if (

    .clk(clk),
    .pc_from_exmem(pc_from_exmem),
    .pcsrc(pcsrc),
    .reset(reset),
    .if_pc_out(if_pc_out), 
    .if_instr_out(if_instr_out)
);

top_id dut_id (
        .clk(clk),
        .reset(reset),
        
        .wb_reg_write(MEM_WB_regwrite),
        .wb_write_reg_location(mem_write_reg),
        .mem_wb_write_data(mem_wb_write_data),
        
        .if_id_instr(if_instr_out),
        .if_id_npc(if_pc_out),

        .id_ex_rs(id_ex_rs),
        .id_ex_wb(id_ex_wb),
        .id_ex_mem(id_ex_mem),
        .id_ex_execute(id_ex_execute),
        .id_ex_npc(id_ex_npc),
        .id_ex_readdat1(id_ex_readdat1),
        .id_ex_readdat2(id_ex_readdat2),
        .id_ex_sign_ext(id_ex_sign_ext),
        .id_ex_instr_bits_20_16(id_ex_instr_bits_20_16),
        .id_ex_bits_15_11(id_ex_bits_15_11)
    );
    
    forwarding_unit dut_forwarding (
        .EX_MEM_RegWrite(ex_mem_wb_ctlout[1]),
        .EX_MEM_RegisterRd(ex_mem_write_reg),

        .MEM_WB_RegWrite(MEM_WB_regwrite),
        .MEM_WB_RegisterRd(mem_write_reg),

        .ID_EX_RegisterRs(id_ex_rs),
        .ID_EX_RegisterRt(id_ex_instr_bits_20_16),

        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    
    
    execute dut_ex (
        .reset(reset),
        .clk(clk),
        .wb_ctl(id_ex_wb),
        .m_ctl(id_ex_mem),
        .regdst(id_ex_execute[3]),
        .alusrc(id_ex_execute[0]),
        .aluop(id_ex_execute[2:1]),
        .funct(id_ex_sign_ext[5:0]),
        .npcout(id_ex_npc),
        .rdata1(id_ex_readdat1),
        .rdata2(id_ex_readdat2),
        .s_extendout(id_ex_sign_ext),
        .instrout_2016(id_ex_instr_bits_20_16),
        .instrout_1511(id_ex_bits_15_11),

         .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .EX_MEM_forward_data(ex_mem_alu_result),
        .MEM_WB_forward_data(mem_wb_write_data),

        .wb_ctlout(ex_mem_wb_ctlout),
        .branch(ex_mem_branch),
        .memread(ex_mem_memread),
        .memwrite(ex_mem_memwrite),
        .EX_MEM_NPC(ex_mem_npc),
        .zero(ex_mem_zero),
        .alu_result(ex_mem_alu_result),
        .rdata2out(ex_mem_rdata2out),
        .five_bit_muxout(ex_mem_write_reg)
    );
    
     MEMORY dut_mem (
        .clk(clk),
        .wb_ctlout(ex_mem_wb_ctlout),
        .branch(ex_mem_branch),
        .memread(ex_mem_memread),
        .memwrite(ex_mem_memwrite),
        .zero(ex_mem_zero),
        .alu_result(ex_mem_alu_result),
        .rdata2out(ex_mem_rdata2out),
        .five_bit_muxout(ex_mem_write_reg),

        .MEM_PCSrc(MEM_PCSrc),
        .MEM_WB_regwrite(MEM_WB_regwrite),
        .MEM_WB_memtoreg(MEM_WB_memtoreg),
        .read_data(read_data),
        .mem_alu_result(mem_alu_result),
        .mem_write_reg(mem_write_reg)
    );
    
    writeback dut_wb (
    .memtoreg(MEM_WB_memtoreg),
    .read_data(read_data),
    .alu_result(mem_alu_result),
    .write_data(mem_wb_write_data)
);

endmodule
