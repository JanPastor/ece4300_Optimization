`timescale 1ns / 1ps

module if_latch (
    input clk,
    input reset,
    input [31:0] if_instr_in,
    input [31:0] if_pc_in,
    output reg [31:0] if_instr_out,
    output reg [31:0] if_pc_out
);
    
    initial begin
        if_instr_out = 32'd0;
        if_pc_out = 32'd0;
    end
       
    always @(posedge clk) begin
        if (reset) begin
            if_instr_out <= 32'b0;
            if_pc_out <= 32'b0;
        end
        else begin
            if_instr_out <= if_instr_in;
            if_pc_out <= if_pc_in;
        end
    end

endmodule