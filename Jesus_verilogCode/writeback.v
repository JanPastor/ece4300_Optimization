module writeback (
    input wire memtoreg,
    input wire [31:0] read_data,
    input wire [31:0] alu_result,
    output wire [31:0] write_data
);

    assign write_data = (memtoreg) ? read_data : alu_result;

endmodule