`timescale 1ns / 1ps

module sign_ext(
    input  [15:0] immediate,
    output [31:0] extended
);

    assign extended = {{16{immediate[15]}}, immediate};

endmodule