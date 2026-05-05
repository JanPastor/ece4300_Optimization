// helper module

module bottom_mux(
    input wire [4:0] a, b,
    input wire sel,
    output wire [4:0] y
);
    assign y = sel ? a : b;
endmodule
