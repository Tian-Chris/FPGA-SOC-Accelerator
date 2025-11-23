import systolic_array_pkg::*;

module process_element (

    input  logic clk,
    input  logic rst_n,
    input  logic                  STOP_WEIGHT_i,
    input  logic                  CLEAR_ALL_i,

    //=========
    //  North
    //=========
    input  logic [DATA_WIDTH-1:0] weight_i,
    input  logic                  WEIGHT_ENABLE_i,

    //=========
    //  South
    //=========
    output logic [DATA_WIDTH-1:0] weight_o,
    output logic                  WEIGHT_ENABLE_o,

    //=========
    //  W