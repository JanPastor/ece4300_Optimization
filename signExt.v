`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 11:30:43 AM
// Design Name: 
// Module Name: signExt
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

module signExt(
    input  wire [15:0] immediate,
    output wire [31:0] extended
);
    // Sign extend: repeat the most significant bit (bit 15) 16 times
    assign extended = {{16{immediate[15]}}, immediate};

endmodule
