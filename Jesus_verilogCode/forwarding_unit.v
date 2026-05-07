module forwarding_unit (
    input wire EX_MEM_RegWrite,
    input wire [4:0] EX_MEM_RegisterRd,

    input wire MEM_WB_RegWrite,
    input wire [4:0] MEM_WB_RegisterRd,

    input wire [4:0] ID_EX_RegisterRs,
    input wire [4:0] ID_EX_RegisterRt,

    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        if (EX_MEM_RegWrite &&
            (EX_MEM_RegisterRd != 5'd0) &&
            (EX_MEM_RegisterRd == ID_EX_RegisterRs)) begin
            ForwardA = 2'b10;
        end

        if (EX_MEM_RegWrite &&
            (EX_MEM_RegisterRd != 5'd0) &&
            (EX_MEM_RegisterRd == ID_EX_RegisterRt)) begin
            ForwardB = 2'b10;
        end

        if (MEM_WB_RegWrite &&
            (MEM_WB_RegisterRd != 5'd0) &&
            !(EX_MEM_RegWrite &&
              (EX_MEM_RegisterRd != 5'd0) &&
              (EX_MEM_RegisterRd == ID_EX_RegisterRs)) &&
            (MEM_WB_RegisterRd == ID_EX_RegisterRs)) begin
            ForwardA = 2'b01;
        end

        if (MEM_WB_RegWrite &&
            (MEM_WB_RegisterRd != 5'd0) &&
            !(EX_MEM_RegWrite &&
              (EX_MEM_RegisterRd != 5'd0) &&
              (EX_MEM_RegisterRd == ID_EX_RegisterRt)) &&
            (MEM_WB_RegisterRd == ID_EX_RegisterRt)) begin
            ForwardB = 2'b01;
        end
    end

endmodule