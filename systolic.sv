module systolic #(parameter DATA_WIDTH = 16, parameter ADD_PIPE = 4, parameter ROWS = 2, parameter COLS = 2) (
    input  logic clk,
    input  logic rst_n,
    input  logic STOP_WEIGHT_i,
    input  logic CLEAR_ALL_i,
    
    input  logic [DATA_WIDTH-1:0] activation_in [0:ROWS-1],
    input  logic ACTIVATION_ENABLE_in [0:ROWS-1],
    input  logic END_SIGNAL_in [0:ROWS-1],
    
    input  logic [DATA_WIDTH-1:0] weight_in [0:COLS-1],
    input  logic WEIGHT_ENABLE_in [0:COLS-1],
    
    output logic [DATA_WIDTH-1:0] data_out [0:ROWS-1],
    output logic data_valid_out [0:ROWS-1]
);
    
    logic [DATA_WIDTH-1:0] act_wire [0:ROWS-1][0:COLS-1];  
    logic ACTIVATION_ENABLE_wire [0:ROWS-1][0:COLS-1];
    logic END_SIGNAL_wire [0:ROWS-1][0:COLS-1];
    
    logic [DATA_WIDTH-1:0] weight_wire [0:ROWS-1][0:COLS-1];
    logic WEIGHT_ENABLE_wire [0:ROWS-1][0:COLS-1];
    
    logic [DATA_WIDTH-1:0] data_wire [0:ROWS-1][0:COLS-1];
    logic data_valid_wire [0:ROWS-1][0:COLS-1];
    
    genvar r, c;
    generate
        for (r = 0; r < ROWS; r = r+1) begin
            assign act_wire[r][0] = activation_in[r];
            assign ACTIVATION_ENABLE_wire[r][0] = ACTIVATION_ENABLE_in[r];
            assign END_SIGNAL_wire[r][0] = END_SIGNAL_in[r];
    
            assign data_wire[r][COLS] = 16'd0;
            assign data_valid_wire[r][COLS] = 1'b0;
        end
        for (c = 0; c < COLS; c = c+1) begin
            assign weight_wire[0][c] = weight_in[c];
            assign WEIGHT_ENABLE_wire[0][c] = WEIGHT_ENABLE_in[c];
        end
    endgenerate
    
    generate
        for (r = 0; r < ROWS; r = r+1) begin
            for (c = 0; c < COLS; c = c+1) begin
                process_element #(.DATA_WIDTH(DATA_WIDTH), .ADD_PIPE(ADD_PIPE)) pe_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .STOP_WEIGHT_i(STOP_WEIGHT_i),
                    .CLEAR_ALL_i(CLEAR_ALL_i),
    
                    .weight_i(weight_wire[r][c]),
                    .WEIGHT_ENABLE_i(WEIGHT_ENABLE_wire[r][c]),
                    .weight_o(weight_wire[r+1][c]),
                    .WEIGHT_ENABLE_o(WEIGHT_ENABLE_wire[r+1][c]),
    
                    .activation_i(act_wire[r][c]),
                    .ACTIVATION_ENABLE_i(ACTIVATION_ENABLE_wire[r][c]),
                    .END_SIGNAL_i(END_SIGNAL_wire[r][c]),
                    .activation_o(act_wire[r][c+1]),
                    .ACTIVATION_ENABLE_o(ACTIVATION_ENABLE_wire[r][c+1]),
                    .END_SIGNAL_o(END_SIGNAL_wire[r][c+1]),
    
                    //outputs
                    .data_i(data_wire[r][c+1]),
                    .data_valid_i(data_valid_wire[r][c+1]),
                    .data_o(data_wire[r][c]),
                    .data_valid_o(data_valid_wire[r][c])
                );
            end
        end
    endgenerate
    
    generate
        for (r = 0; r < ROWS; r = r+1) begin
            assign data_out[r] = data_wire[r][0]; 
            assign data_valid_out[r] = data_valid_wire[r][0];
        end
    endgenerate
endmodule
