`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 11:28:28 AM
// Design Name: 
// Module Name: regfile
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
module regfile(
    input  wire        clk, rst, regwrite,
    input  wire [4:0]  rs, rt, rd, // rd is write_reg_location here
    input  wire [31:0] writedata,
    output wire [31:0] A_readdat1, B_readdat2
);
    reg [31:0] registers [31:0];
    integer i;

    assign A_readdat1 = registers[rs];
    assign B_readdat2 = registers[rt];

    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<32; i=i+1) registers[i] <= 32'b0;
        end else if (regwrite && (rd != 5'b0)) begin
            registers[rd] <= writedata;
        end
    end
endmodule
