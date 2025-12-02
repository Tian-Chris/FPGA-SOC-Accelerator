`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 02:56:32 PM
// Design Name: 
// Module Name: tb_process_element
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

module tb_process_element();
    localparam DATA_WIDTH = 16;
    // ======================
    //  DUT signals
    // ======================
    logic clk;
    logic rst_n;

    logic STOP_WEIGHT_i;
    logic CLEAR_ALL_i;

    logic [DATA_WIDTH-1:0] weight_i;
    logic WEIGHT_ENABLE_i;

    logic [DATA_WIDTH-1:0] activation_i;
    logic ACTIVATION_ENABLE_i;
    logic END_SIGNAL_i;

    logic [DATA_WIDTH-1:0] weight_o;
    logic WEIGHT_ENABLE_o;
    logic [DATA_WIDTH-1:0] activation_o;
    logic ACTIVATION_ENABLE_o;
    logic END_SIGNAL_o;

    logic [DATA_WIDTH-1:0] data_o;
    logic [DATA_WIDTH-1:0] data_i;

    // ======================
    // Instantiate DUT
    // ======================
    process_element dut (
        .clk(clk),
        .rst_n(rst_n),
        .STOP_WEIGHT_i(STOP_WEIGHT_i),
        .CLEAR_ALL_i(CLEAR_ALL_i),
        .weight_i(weight_i),
        .WEIGHT_ENABLE_i(WEIGHT_ENABLE_i),
        .weight_o(weight_o),
        .WEIGHT_ENABLE_o(WEIGHT_ENABLE_o),
        .activation_i(activation_i),
        .ACTIVATION_ENABLE_i(ACTIVATION_ENABLE_i),
        .END_SIGNAL_i(END_SIGNAL_i),
        .data_o(data_o),
        .activation_o(activation_o),
        .ACTIVATION_ENABLE_o(ACTIVATION_ENABLE_o),
        .END_SIGNAL_o(END_SIGNAL_o),
        .data_i(data_i)
    );

    // ======================
    // Clock Generation
    // ======================
    always #5 clk = ~clk;

    // ======================
    // Test Procedure
    // ======================
    initial begin
        clk = 0;
        rst_n = 0;
        CLEAR_ALL_i = 0;
        STOP_WEIGHT_i = 0;

        WEIGHT_ENABLE_i = 0;
        ACTIVATION_ENABLE_i = 0;
        END_SIGNAL_i = 0;
        data_i = 0;

        #10;
        rst_n = 1;
        #10;
        // ======================================================
        // Send activation + weight for a single multiply-add
        // ======================================================
        @(posedge clk);
        WEIGHT_ENABLE_i = 1;
        ACTIVATION_ENABLE_i = 1;

        weight_i     = 16'h3FC0; // 2.03125
        activation_i = 16'h4010; // 1.9375
        //3.93554688

        @(posedge clk);
        weight_i     = 16'h4300; // 3.5
        activation_i = 16'h3C80; // 1.125
        //3.92

        @(posedge clk);
        weight_i     = 16'h5300; // 56
        activation_i = 16'h3C80; // 1.125
        //63

        @(posedge clk);
        weight_i     = 16'h2300; // 3.5
        activation_i = 16'h3C80; // 1.125
        //0.015

        @(posedge clk);
        // disable after one cycle
        WEIGHT_ENABLE_i = 0;
        ACTIVATION_ENABLE_i = 0;
        END_SIGNAL_i = 1;

        @(posedge clk);
        END_SIGNAL_i = 0;

        // Wait long enough for your IP (mult + add) + pipeline delays
        repeat (9) @(posedge clk);

        $display("====================================================");
        $display("  FP16 output accumulator = %h", data_o);
        $display("  Expected                = 43DF");
        $display("====================================================");

        if (data_o === 16'h43DF) begin
            $display("PASS: Multiply + add result correct!");
        end else begin
            $display("FAIL: Got %h, expected 43DF", data_o);
        end

        $finish;
    end

endmodule
