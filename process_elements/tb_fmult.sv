`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 02:37:14 PM
// Design Name: 
// Module Name: tb_fmult
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

module tb_fmult;

    logic         clk;
    logic         rst_n;
    reg  [15:0] a;
    reg  [15:0] b;
    wire [15:0] ap_return;

    fmult_0 multiplier(
        .ap_clk(clk),
        .ap_rst(!rst_n),
        .a(a),
        .b(b),
        .ap_return(ap_return)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        @(posedge clk);
        a     = 16'h3FC0; 
        b = 16'h4010;

        @(posedge clk);
        a     = 16'h4300;
        b = 16'h3C80; 

        @(posedge clk);
        a     = 16'h5300; 
        b = 16'h3C80;

        @(posedge clk);
        a     = 16'h2300;
        b     = 16'h3C80;
        

        #20;
        $finish;
    end

endmodule
