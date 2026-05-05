`timescale 1ns / 1ps
// this is the primary translator for the alu
// parameters were adjusted and default cases were added to handle unknown
// instructions to prevent CPU from hanging

module alu_control(
    input wire [5:0] funct,
    input wire [1:0] aluop,
    output reg [2:0] select
);

    // ALUOp types
    parameter lwsw  = 2'b00;
    parameter Itype = 2'b01;
    parameter Rtype = 2'b10;

    // ALU Control Select codes
    parameter ALUand = 3'b000;
    parameter ALUor  = 3'b001;
    parameter ALUadd = 3'b010;
    parameter ALUsub = 3'b110;
    parameter ALUslt = 3'b111;
    parameter ALUx   = 3'b011; // Unknown/Error

    always @* begin
        case (aluop)
            lwsw:  select = ALUadd; // LW and SW both use Addition for address
            Itype: select = ALUsub; // BEQ uses Subtraction to compare
            Rtype: begin
                case (funct)
                    6'b100000: select = ALUadd; // ADD
                    6'b100010: select = ALUsub; // SUB
                    6'b100100: select = ALUand; // AND
                    6'b100101: select = ALUor;  // OR
                    6'b101010: select = ALUslt; // SLT
                    default:   select = ALUx;
                endcase
            end
            default: select = ALUx;
        endcase
    end
endmodule
