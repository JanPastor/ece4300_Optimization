`timescale 1ns / 1ps

// the fix here was changing the logic
// from always @* (combinational) to always @(posedge clk) (synchronous).
// MODIFIED: Added aluzero_out output so the zero flag reaches the MEM stage.

module ex_mem(
    input wire clk,
    input wire rst,
    input wire [1:0] ctlwb_in,
    input wire [2:0] ctlm_in,
    input wire [31:0] adder_in,
    input wire aluzero_in,
    input wire [31:0] alu_res_in, rdata2_in,
    input wire [4:0] write_reg_in,
    output reg [1:0] ctlwb_out,
    output reg [2:0] ctlm_out,
    output reg [31:0] adder_out,
    output reg aluzero_out,
    output reg [31:0] alu_result_out, rdata2_out,
    output reg [4:0] muxout_out
);

    // The Latch "snaps" the data on the rising edge of the clock
    always @(posedge clk) begin
        if (rst) begin
            ctlwb_out      <= 2'b0;
            ctlm_out       <= 3'b0;
            adder_out      <= 32'b0;
            aluzero_out    <= 1'b0;
            alu_result_out <= 32'b0;
            rdata2_out     <= 32'b0;
            muxout_out     <= 5'b0;
        end else begin
            ctlwb_out      <= ctlwb_in;
            ctlm_out       <= ctlm_in;
            adder_out      <= adder_in;
            aluzero_out    <= aluzero_in;
            alu_result_out <= alu_res_in;
            rdata2_out     <= rdata2_in;
            muxout_out     <= write_reg_in;
        end
    end

endmodule
