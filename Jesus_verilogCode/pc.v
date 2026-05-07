`timescale 1ns / 1ps

module pc (
    input clk,
    input reset,
    input [31:0] pc_inp,
    output reg [31:0] pc_out
);
    
    initial pc_out = 32'd0;
    
    always @(posedge clk) begin
        if (reset)
            pc_out <= 32'b0;
        else
            pc_out <= pc_inp;            
    end

endmodule