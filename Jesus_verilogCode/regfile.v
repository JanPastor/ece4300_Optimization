module regfile(
    input wire clk, reset,
    input wire regwrite,
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [4:0] rd,
    input wire [31:0] writedata,
    output wire [31:0] A_readdat1,
    output wire [31:0] B_readdat2
);

    reg [31:0] REG [0:31];
    integer i;

    assign A_readdat1 = REG[rs];
    assign B_readdat2 = REG[rt];

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                REG[i] <= 32'b0;
        end
        else begin
            if (regwrite && rd != 5'd0)
                REG[rd] <= writedata;
        end
    end

endmodule