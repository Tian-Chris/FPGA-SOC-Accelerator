`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 05:40:47 PM
// Design Name: 
// Module Name: tb_fadd
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
module tb_fadd;

    reg         clk;
    reg         rst;
    reg         ap_start;
    wire        ap_done;
    wire        ap_idle;
    wire        ap_ready;
    reg  [15:0] a;
    reg  [15:0] b;
    wire [15:0] ap_return;

    fadd_0 dut (
        .ap_clk(clk),
        .ap_rst(rst),
        .ap_start(ap_start),
        .ap_done(ap_done),
        .ap_idle(ap_idle),
        .ap_ready(ap_ready),
        .a(a),
        .b(b),
        .ap_return(ap_return)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        ap_start = 0;
        a = 0;
        b = 0;

        #20;
        rst = 0;

        a = 16'h3C00;
        b = 16'h4000;

        #10;
        a = 16'h3C00;
        b = 16'h4000;
        
        #40;
        ap_start = 0;
        
        #20;
        a = 16'h5300;
        b = 16'h3C80; 
        
        #10;
        ap_start = 0;  
        #20;
        $finish;
    end

endmodule

