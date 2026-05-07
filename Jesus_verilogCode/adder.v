`timescale 1ns / 1ps

module adder (
    input [31:0] a,
    output [31:0] adder_out
);
    
    assign adder_out = a + 32'd4;   
    
endmodule