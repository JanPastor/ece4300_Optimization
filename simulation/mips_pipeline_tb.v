`timescale 1ns / 1ps

module mips_pipeline_tb;

    reg clk;
    reg rst;

    mips_pipeline uut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #10 rst = 0;
        #500 $finish;
    end

    // Detailed pipeline trace
    always @(posedge clk) begin
        if (!rst) begin
            $display("--- t=%0t ns ---", $time/1000);
            $display("  IF: PC=%0d  instr=%h  npc=%0d",
                uut.stage1_fetch.pc_current,
                uut.if_id_instr,
                uut.if_id_npc);
            $display("  ID: wb=%b mem=%b ex=%b  rs_dat=%0d rt_dat=%0d sext=%0d  rt=%0d rd=%0d",
                uut.id_ex_wb, uut.id_ex_mem, uut.id_ex_ex,
                uut.id_ex_readdat1, uut.id_ex_readdat2, uut.id_ex_sign_ext,
                uut.id_ex_instr_bits_20_16, uut.id_ex_instr_bits_15_11);
            $display("  EX: wb=%b mem=%b  alu=%0d  wreg=%0d  zero=%b",
                uut.ex_mem_wb, uut.ex_mem_mem, uut.ex_mem_alu_result,
                uut.ex_mem_write_reg, uut.ex_mem_zero);
            $display("  WB: wb=%b  rd_data=%0d  alu=%0d  wreg=%0d  wdata=%0d",
                uut.mem_wb_wb, uut.mem_wb_read_data, uut.mem_wb_alu_result,
                uut.mem_wb_write_reg, uut.wb_write_data);
            $display("  REG: R0=%0d R1=%0d R2=%0d R3=%0d",
                uut.stage2_decode.rf0.registers[0],
                uut.stage2_decode.rf0.registers[1],
                uut.stage2_decode.rf0.registers[2],
                uut.stage2_decode.rf0.registers[3]);
        end
    end

endmodule
