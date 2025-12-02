`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 05:01:32 PM
// Design Name: 
// Module Name: systolic_tb
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

module systolic_tb;
    parameter DATA_WIDTH = 16;
    parameter ADD_PIPE   = 4;
    parameter ROWS       = 2;
    parameter COLS       = 2;
    
    logic clk;
    logic rst_n;
    
    logic STOP_WEIGHT_i;
    logic CLEAR_ALL_i;
    
    logic [DATA_WIDTH-1:0] activation_in [0:ROWS-1];
    logic ACTIVATION_ENABLE_in [0:ROWS-1];
    logic END_SIGNAL_in [0:ROWS-1];
    
    logic [DATA_WIDTH-1:0] weight_in [0:COLS-1];
    logic WEIGHT_ENABLE_in [0:COLS-1];
    logic [DATA_WIDTH-1:0] data_out [0:ROWS-1];
    logic data_valid_out [0:ROWS-1];
    
    systolic #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADD_PIPE(ADD_PIPE),
        .ROWS(ROWS),
        .COLS(COLS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .STOP_WEIGHT_i(STOP_WEIGHT_i),
        .CLEAR_ALL_i(CLEAR_ALL_i),
        .activation_in(activation_in),
        .ACTIVATION_ENABLE_in(ACTIVATION_ENABLE_in),
        .END_SIGNAL_in(END_SIGNAL_in),
        .weight_in(weight_in),
        .WEIGHT_ENABLE_in(WEIGHT_ENABLE_in),
        .data_out(data_out),
        .data_valid_out(data_valid_out)
    );
    
    initial clk = 0;
    always #5 clk = ~clk; 
    
    initial begin
        rst_n = 0;
        STOP_WEIGHT_i = 0;
        CLEAR_ALL_i = 0;
        for (int i=0; i<ROWS; i++) begin
            activation_in[i] = 0;
            ACTIVATION_ENABLE_in[i] = 0;
            END_SIGNAL_in[i] = 0;
        end
        for (int j=0; j<COLS; j++) begin
            weight_in[j] = 0;
            WEIGHT_ENABLE_in[j] = 0;
        end
    
        #20;
        rst_n = 1;
    
        #10;
        weight_in[0] = 16'h3C00;
        weight_in[1] = 16'h0000;
        WEIGHT_ENABLE_in[0] = 1;
        WEIGHT_ENABLE_in[1] = 0;
    
        activation_in[0] = 16'h4000;
        activation_in[1] = 16'h0000;
        ACTIVATION_ENABLE_in[0] = 1;
        ACTIVATION_ENABLE_in[1] = 0;
        
        #10
        activation_in[0] = 16'h4000;
        activation_in[1] = 16'h4000;
        WEIGHT_ENABLE_in[0] = 1;
        WEIGHT_ENABLE_in[1] = 1;
        
        weight_in[0] = 16'h3C00;
        weight_in[1] = 16'h3C00;
        ACTIVATION_ENABLE_in[0] = 1;
        ACTIVATION_ENABLE_in[1] = 1;
        
        #10
        weight_in[0] = 16'h0000; 
        weight_in[1] = 16'h3C00;
        WEIGHT_ENABLE_in[0] = 0;
        WEIGHT_ENABLE_in[1] = 1;
    
        activation_in[0] = 16'h0000;
        activation_in[1] = 16'h4000;
        ACTIVATION_ENABLE_in[0] = 0;
        ACTIVATION_ENABLE_in[1] = 1;
        END_SIGNAL_in[0] = 1;

        #10
        END_SIGNAL_in[1] = 1;
        WEIGHT_ENABLE_in[1] = 0;
        ACTIVATION_ENABLE_in[1] = 0;

        $finish;
    end
endmodule
