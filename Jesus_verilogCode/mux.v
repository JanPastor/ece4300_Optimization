`timescale 1ns / 1ps

module mux (
    input [31:0] in_0,
    input [31:0] in_1,
    input select,
    output [31:0] mux_out
);

    assign mux_out = select ? in_1 : in_0;

endmodule