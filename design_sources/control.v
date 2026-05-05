`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 11:27:57 AM
// Design Name: 
// Module Name: control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module control(
    input  wire [5:0] opcode,
    output reg  [1:0] wb,  // {RegWrite, MemToReg}
    output reg  [2:0] mem, // {Branch, MemRead, MemWrite}
    output reg  [3:0] ex   // {RegDst, ALUOp1, ALUOp0, ALUSrc}
);
    always @(*) begin
        case(opcode)
            6'h00: begin // R-Format
                wb = 2'b10; mem = 3'b000; ex = 4'b1100;
            end
            6'h23: begin // LW
                wb = 2'b11; mem = 3'b010; ex = 4'b0001;
            end
            6'h2B: begin // SW
                wb = 2'b00; mem = 3'b001; ex = 4'bX001;
            end
            6'h04: begin // BEQ
                wb = 2'b00; mem = 3'b100; ex = 4'bX010;
            end
            default: begin
                wb = 2'b00; mem = 3'b000; ex = 4'b0000;
            end
        endcase
    end
endmodule
