module pipeline #(parameter WIDTH=16, DEPTH=4)(
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input logic [WIDTH-1:0] data_in,
    output logic valid_out,
    output logic [WIDTH-1:0] data_out
);
    logic [WIDTH-1:0] stage[DEPTH-1:0];
    logic stage_valid[DEPTH-1:0];

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            stage <= '{default:0};
            stage_valid <= '{default:0};
        end else begin
            stage[0] <= data_in;
            stage_valid[0] <= valid_in;
            for (int i=1; i<DEPTH; i++) begin
                stage[i] <= stage[i-1];
                stage_valid[i] <= stage_valid[i-1];
            end
        end
    end

    assign data_out = stage[DEPTH-1];
    assign valid_out = stage_valid[DEPTH-1];
endmodule
