`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 01:10:23 PM
// Design Name: 
// Module Name: components
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// 2-to-1 Multiplexer
module mux (
    output wire [31:0] y,
    input  wire [31:0] a_true,  // Selected when sel = 1
    input  wire [31:0] b_false, // Selected when sel = 0
    input  wire        sel
);
    assign y = (sel) ? a_true : b_false;
endmodule

// Program Counter (PC) Register
module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_in,
    output reg  [31:0] pc_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'h0000_0000;
        else
            pc_out <= pc_in;
    end
endmodule

// Adder / Incrementer
module incrementer (
    input  wire [31:0] pcin,
    output wire [31:0] pcout
);
    // Incrementing by 4 to match 0, 4, 8... addressing
    assign pcout = pcin + 4;
endmodule

// Instruction Memory
module instrMem (
    input  wire        clk,
    input  wire [31:0] addr,
    output reg  [31:0] data
);
    // Using a smaller depth for simulation stability
    reg [31:0] rom [0:1023]; 

    initial begin
        // Load optimized instructions (forwarding eliminates most NOPs)
        $readmemb("instr_forwarding.mem", rom);
    end

    always @(posedge clk) begin
        // Address divided by 4 to get the word index
        data <= rom[addr >> 2]; 
    end
endmodule

// IF/ID Pipeline Latch
module ifIdLatch (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_in,
    input  wire [31:0] instr_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] instr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out    <= 32'b0;
            instr_out <= 32'b0;
        end else begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule
