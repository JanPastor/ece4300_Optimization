`timescale 1ns / 1ps

module instr_mem (
    input [31:0] address,
    input clk,
    input reset,
    output reg [31:0] instruction
);
    
    reg [31:0] memory [0:299];
    integer i;

    initial begin
        instruction = 32'b0;

        for (i = 0; i < 300; i = i + 1)
            memory[i] = 32'b0;

        $readmemb("fwd_instr.mem", memory);
    end
    
    always @(posedge clk) begin
        if (reset)
            instruction <= 32'b0;
        else
            instruction <= memory[address[31:2]];
    end

endmodule