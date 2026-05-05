`timescale 1ns / 1ps
// this is the primary math engine of the ALU, i.e. sum = a + b (signed)
//bitwise AND/OR syntax is fixed and zero flag is correctly calculated outside the
// always block

module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] control,
    output reg [31:0] result,
    output wire zero
);

    parameter ALUand = 3'b000;
    parameter ALUor  = 3'b001;
    parameter ALUadd = 3'b010;
    parameter ALUsub = 3'b110;
    parameter ALUslt = 3'b111;

    wire sign_mismatch = a[31] ^ b[31];

    always @* begin
        case (control)
            ALUand: result = a & b;
            ALUor:  result = a | b;
            ALUadd: result = a + b;
            ALUsub: result = a - b;
            ALUslt: result = (a < b) ? (1 - sign_mismatch) : (0 + sign_mismatch);
            default: result = 32'hXXXXXXXX;
        endcase
    end

    assign zero = (result == 0);

endmodule
