`timescale 1ns / 1ps

module mem_stage(
    input wire clk,
    input wire [31:0] ALUResult, WriteData,
    input wire [4:0] WriteReg,
    input wire [1:0] WBControl,
    input wire MemWrite, MemRead, Branch, Zero,
    output wire [31:0] ReadData, ALUResult_out,
    output wire [4:0] WriteReg_out,
    output wire [1:0] WBControl_out,
    output wire PCSrc
);

    // Internal Wires
    wire [31:0] read_data_from_memory;

    // 1. Branch Logic (AND Gate)
    AND branch_logic (
        .membranch(Branch),
        .zero(Zero),
        .PCSrc(PCSrc)
    );

    // 2. Data Memory (RAM)
    data_memory d_mem (
        .clk(clk),
        .addr(ALUResult),
        .write_data(WriteData),
        .memwrite(MemWrite),
        .memread(MemRead),
        .read_data(read_data_from_memory)
    );

    // 3. MEM/WB Latch (Synchronous)
    mem_wb final_latch (
        .clk(clk),
        .control_wb_in(WBControl),
        .read_data_in(read_data_from_memory),
        .alu_result_in(ALUResult),
        .write_reg_in(WriteReg),
        .wb_ctlout(WBControl_out), // Combined back to 2-bits for the testbench
        .read_data(ReadData),
        .mem_alu_result(ALUResult_out),
        .mem_write_reg(WriteReg_out)
    );

endmodule
