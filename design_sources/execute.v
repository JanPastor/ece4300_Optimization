`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: execute
// Description: EX Stage wrapper.
//   MODIFIED: Added data forwarding muxes before ALU inputs.
//   forward_a/forward_b select between:
//     2'b00 = register file value (no forwarding)
//     2'b10 = EX/MEM forwarded value (1 cycle ago)
//     2'b01 = MEM/WB forwarded value (2 cycles ago)
//////////////////////////////////////////////////////////////////////////////////

module execute(
    input wire clk,
    input wire rst,
    input wire [1:0] ctlwb_in,
    input wire [2:0] ctlm_in,
    input wire [31:0] npc, rdata1, rdata2, s_extend,
    input wire [4:0] instr_2016, instr_1511,
    input wire [1:0] alu_op,
    input wire [5:0] funct,
    input wire alusrc, regdst,
    // Forwarding inputs
    input wire [1:0]  forward_a,          // Mux select for ALU input A
    input wire [1:0]  forward_b,          // Mux select for ALU input B
    input wire [31:0] ex_mem_alu_fwd,     // Forwarded ALU result from EX/MEM
    input wire [31:0] wb_write_data_fwd,  // Forwarded write-back data from WB
    // Outputs
    output wire [1:0] ctlwb_out,
    output wire [2:0] ctlm_out,
    output wire [31:0] adder_out, alu_result_out, rdata2_out,
    output wire [4:0] muxout_out,
    output wire zero_out
);

    // Internal Wires
    wire [31:0] npc_plus_offset;
    wire [31:0] alu_input_b;
    wire [31:0] alu_res_internal;
    wire [4:0] write_reg_internal;
    wire [2:0] alu_control_wire;
    wire zero_internal;

    // Forwarded ALU operands
    reg [31:0] alu_a_forwarded;
    reg [31:0] alu_b_forwarded;

    // *** FORWARDING MUX A (ALU input A) ***
    always @* begin
        case (forward_a)
            2'b00:   alu_a_forwarded = rdata1;            // No forwarding
            2'b10:   alu_a_forwarded = ex_mem_alu_fwd;    // From EX/MEM
            2'b01:   alu_a_forwarded = wb_write_data_fwd; // From MEM/WB
            default: alu_a_forwarded = rdata1;
        endcase
    end

    // *** FORWARDING MUX B (ALU input B, before ALUSrc mux) ***
    always @* begin
        case (forward_b)
            2'b00:   alu_b_forwarded = rdata2;            // No forwarding
            2'b10:   alu_b_forwarded = ex_mem_alu_fwd;    // From EX/MEM
            2'b01:   alu_b_forwarded = wb_write_data_fwd; // From MEM/WB
            default: alu_b_forwarded = rdata2;
        endcase
    end

    // 1. Branch Address Adder
    adder adder3 (
        .add_in1(npc),
        .add_in2(s_extend),
        .add_out(npc_plus_offset)
    );

    // 2. RegDst Mux (Selects destination register: rt or rd)
    bottom_mux bottom_mux3 (
        .a(instr_1511),  // rd
        .b(instr_2016),  // rt
        .sel(regdst),
        .y(write_reg_internal)
    );

    // 3. ALUSrc Mux — now uses FORWARDED B value
    assign alu_input_b = alusrc ? s_extend : alu_b_forwarded;

    // 4. ALU Control
    alu_control alu_control3 (
        .funct(funct),
        .aluop(alu_op),
        .select(alu_control_wire)
    );

    // 5. ALU — now uses FORWARDED A value
    alu alu3 (
        .a(alu_a_forwarded),
        .b(alu_input_b),
        .control(alu_control_wire),
        .result(alu_res_internal),
        .zero(zero_internal)
    );

    // 6. EX/MEM Latch
    ex_mem ex_mem3 (
        .clk(clk),
        .rst(rst),
        .ctlwb_in(ctlwb_in),
        .ctlm_in(ctlm_in),
        .adder_in(npc_plus_offset),
        .aluzero_in(zero_internal),
        .alu_res_in(alu_res_internal),
        .rdata2_in(alu_b_forwarded),  // Use forwarded value for store data too
        .write_reg_in(write_reg_internal),
        .ctlwb_out(ctlwb_out),
        .ctlm_out(ctlm_out),
        .adder_out(adder_out),
        .aluzero_out(zero_out),
        .alu_result_out(alu_result_out),
        .rdata2_out(rdata2_out),
        .muxout_out(muxout_out)
    );

endmodule
