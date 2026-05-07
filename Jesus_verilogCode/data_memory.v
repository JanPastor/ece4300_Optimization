`timescale 1ns / 1ps

module data_memory (
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire memread,
    input wire memwrite,
    output reg [31:0] read_data
);

    reg [31:0] DMEM [0:255];
    integer i;

    initial begin
        read_data = 32'b0;

        for (i = 0; i < 256; i = i + 1)
            DMEM[i] = 32'b0;

        $readmemb("data.mem", DMEM);
    end

    always @(*) begin
        if (memread)
            read_data = DMEM[addr];
        else
            read_data = 32'b0;
    end

    always @(*) begin
        if (memwrite)
            DMEM[addr] = write_data;
    end

endmodule