
module process_element #(parameter DATA_WIDTH = 16, parameter ADD_PIPE = 4) (    
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
    //  West
    //=========
    input  reg   [DATA_WIDTH-1:0] activation_i,
    input  logic                  ACTIVATION_ENABLE_i,
    input  logic                  END_SIGNAL_i,
    output logic [DATA_WIDTH-1:0] data_o,
    output logic                  data_valid_o,

    //=========
    //  East
    //=========
    output logic [DATA_WIDTH-1:0] activation_o,
    output logic                  ACTIVATION_ENABLE_o,
    output logic                  END_SIGNAL_o,
    input  logic [DATA_WIDTH-1:0] data_i,
    input  logic                  data_valid_i

    );
    //---------------------------------------------------------------
    // Datapath Registers
    //---------------------------------------------------------------

    reg [DATA_WIDTH-1:0] accumulator [ADD_PIPE:0];
    reg [DATA_WIDTH-1:0] addr_output [ADD_PIPE:0];
    wire [DATA_WIDTH-1:0] mult_output;
    reg [DATA_WIDTH-1:0] weight_stored;
    reg                  finished_running;

    logic [DATA_WIDTH-1:0] adder_input_a [ADD_PIPE:0];
    logic [DATA_WIDTH-1:0] adder_input_b [ADD_PIPE:0];
    logic addr_start [ADD_PIPE:0];
    logic addr_end [ADD_PIPE:0];

    logic mult_done;
    int   cycle;

    reg   start;

    reg [DATA_WIDTH-1:0] weight_used;
    reg [DATA_WIDTH-1:0] activation_clked;
    always_ff @(posedge clk) begin
        start <=  WEIGHT_ENABLE_i && ACTIVATION_ENABLE_i;
        weight_stored <= weight_i;
        activation_clked <= activation_i;
        if (STOP_WEIGHT_i) begin
            weight_used <= weight_stored;
        end else begin
            weight_used <= weight_i;
        end
    end 
   
    //---------------------------------------------------------------
    // Multiplier and Pipe
    //---------------------------------------------------------------
    fmult_0 multiplier(
        .ap_clk(clk),
        .ap_rst(!rst_n),
        .a(activation_clked),
        .b(weight_stored),
        .ap_return(mult_output)
    );
    //fp16 3 cycles input to output

    //stalls 3 for when mult_output is valid
    pipeline #(.WIDTH(1), .DEPTH(3)) accumulate_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(1),
        .data_in(start),
        .valid_out(),
        .data_out(mult_done)
    );
    
    // Waits for final mult to finish before begining accumulator add
    pipeline #(.WIDTH(1), .DEPTH(10)) end_pipe (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(1),
        .data_in(END_SIGNAL_i),
        .valid_out(),
        .data_out(finished_running)
    );

    //---------------------------------------------------------------
    // ADDERS
    //---------------------------------------------------------------
    genvar i;
        generate
            for(i = 0; i <= ADD_PIPE; i++) begin
                // ====== float16 adder ======
                fadd_0 adder(
                    .ap_clk(clk),
                    .ap_rst(!rst_n),
                    .ap_start(addr_start[i]),
                    //.ap_done(addr_end[i]),
                    .a(adder_input_a[i]),
                    .b(adder_input_b[i]),
                    .ap_return(addr_output[i])
                );
                //4 cycles 5 addrs

                pipeline #(.WIDTH(1), .DEPTH(5)) adder_pipe (
                    .clk(clk),
                    .rst_n(rst_n),
                    .valid_in(1),
                    .data_in(addr_start[i]),
                    .valid_out(),
                    .data_out(addr_end[i])
                );
            end
        endgenerate

    //---------------------------------------------------------------
    // FSM
    //---------------------------------------------------------------
    typedef enum logic [3:0] {
        IDLE,
        RUN,
        TREE1,
        TREE1_W,
        TREE2,
        TREE2_W,
        TREE3,
        OUT_ACC,
        OUT_FOR
    } state_t;
    state_t state, next_state;
    
    // next-state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE:
                if (start) next_state = RUN;

            RUN:
                if (finished_running) next_state = TREE1;

            TREE1:
                next_state = TREE1_W;
            TREE1_W:
                if (addr_end[0] && addr_end[2]) next_state = TREE2;

            TREE2:
                next_state = TREE2_W;

            TREE2_W:
                if (addr_end[0]) next_state = TREE3;

            TREE3:
                if (addr_end[0]) next_state = OUT_ACC;

            OUT_ACC: next_state = OUT_FOR;
            OUT_FOR: if (!data_valid_i) next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    //---------------------------------------------------------------
    // DATAPATH
    //---------------------------------------------------------------
    always_ff @(posedge clk) begin
        state <= next_state;
        for (int j = 0; j <= ADD_PIPE; j++) begin
            addr_start[j]    <= 0;
            adder_input_a[j] <= 0;
            adder_input_b[j] <= 0;
            accumulator[j]   <= addr_end[j] ? addr_output[j] : accumulator[j];
        end
        if (!rst_n || CLEAR_ALL_i) begin
            for (int j = 0; j <= ADD_PIPE; j++) begin
                accumulator[j]   <= 0;
                addr_start[j]    <= 0;
                adder_input_a[j] <= 0;
                adder_input_b[j] <= 0;
            end
            data_valid_o      <= 0;
            WEIGHT_ENABLE_o   <= 0;
            ACTIVATION_ENABLE_o <= 0;
            END_SIGNAL_o      <= 0;
            cycle             <= 0;
            state             <= IDLE;
        end else if(state == IDLE || state == RUN) begin
            activation_o        <= activation_i;
            WEIGHT_ENABLE_o     <= WEIGHT_ENABLE_i;
            ACTIVATION_ENABLE_o <= ACTIVATION_ENABLE_i;
            END_SIGNAL_o        <= END_SIGNAL_i;
            weight_o            <= weight_i;
            if (mult_done) begin // prevents x or z
                cycle <= (cycle == ADD_PIPE) ? 0 : cycle + 1;
                for(int j = 0; j <= ADD_PIPE; j++) begin
                    addr_start[j]    <= (j == cycle);
                    adder_input_a[j] <= (j == cycle) ? accumulator[cycle] : 0;
                    adder_input_b[j] <= (j == cycle) ? mult_output : 0;
                end
            end 
        end else if(state == TREE1) begin
            //sums all 4 accumulators over 8 cycles and 2 add steps
            // acc0 <= acc0 + acc1
            // acc3 <= acc3 + acc4
            // acc0 <= acc0 + acc3
            adder_input_a[0] <= accumulator[0];
            adder_input_a[2] <= accumulator[2];
            adder_input_b[0] <= accumulator[1];
            adder_input_b[2] <= accumulator[3];
            addr_start[0]  <= 1;
            addr_start[2]  <= 1;
        end else if(state == TREE2) begin
            adder_input_a[0] <= accumulator[0];
            adder_input_b[0] <= accumulator[2];
            addr_start[0]    <= 1;
        end else if(state == TREE3) begin
            adder_input_a[0] <= accumulator[0];
            adder_input_b[0] <= accumulator[4];
            addr_start[0]    <= 1;
        end else if(state == OUT_ACC) begin
            data_o          <= accumulator[0];
            data_valid_o    <= 1;
        end else if(state == OUT_FOR) begin
            if(data_valid_i) begin
                data_o          <= data_i;
                data_valid_o    <= data_valid_i;
            end
        end
    end
endmodule
