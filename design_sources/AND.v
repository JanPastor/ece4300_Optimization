module AND(
    input wire membranch, zero,
    output wire PCSrc
);
    assign PCSrc = membranch & zero;
endmodule
