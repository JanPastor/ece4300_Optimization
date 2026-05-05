`timescale 1ns / 1ps

module data_memory (
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire memread, memwrite,
    output reg [31:0] read_data
);

    reg [31:0] DMEM[0:255];
    integer i;

    initial begin
        read_data = 0;
        // Load initial values from .mem file (preferred by professor)
        $readmemb("data.mem", DMEM);
        for (i = 0; i < 6; i = i + 1) begin
            $display("DMEM[%0d] = %b", i, DMEM[i]);
        end
    end

    // Read Logic (Asynchronous/Combinational)
    always @(*) begin
        if (memread)
            read_data = DMEM[addr[7:0]]; // Using lower 8 bits for 256-word range
        else
            read_data = 32'h00000000;
    end

    // Write Logic (Synchronous - must happen on clock edge)
    always @(posedge clk) begin
        if (memwrite) begin
            DMEM[addr[7:0]] <= write_data;
        end
    end

endmodule
