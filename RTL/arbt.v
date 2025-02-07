module arbt #(
    parameter   TIME_OUT_ns  = 10;
    parameter   ENTYR_NUM    = 32;
    parameter   QOS_TYPE_NUM = 16
    // parameter   TRANS_NUM_W = 5; 
) (
    input               clk, 
    input               rst_n, 

    output                         rdy_in,
    input                          vld_in,
    input  [3                   :0]qos_in, 
    // input                          payload_in, 

    input                          rdy_out,
    output                         vld_out,
    output                         payload_out,
    // input  [3                   :0]qos_in, 
    // input                          payload, 
    // input  []



);

wire [$clog2(ENTYR_NUM) -1:0]entry_id_in;
reg  [$clog2(ENTYR_NUM) -1:0]entry_id_out; 

//====================================================================================
//     determine which entry to be written              
//====================================================================================

reg  [ENTYR_NUM-1 :0] entry_state; // 0: free to be written, 1: 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        entry_state <= 0;
    end else begin 
        if ( rdy_in&vld_in ||  rdy_out&vld_out ) begin 
            for (integer i = 0; i < ENTYR_NUM; i = i + 1) begin
                if ( entry_id_in == i ) begin
                    entry_state[i] <= ~entry_state[i];
                end
            end
        end 
    end 
end

RR_arbiter #(
    .REQ_WIDTH ( ENTYR_NUM )
)u_RR_arbiter(
    .clk        ( clk          ),
    .rst_n      ( rst_n        ),
    .req        ( ~entry_state ),
    .arb_port   ( entry_id_in  )
);


//====================================================================================
//     determine which entry to be readout               
//====================================================================================

wire [ENTYR_NUM-1 :0]time_out_flag;
wire [ENTYR_NUM-1 :0][QOS_TYPE_NUM-1:0]qos_type_flag;

generate
    genvar entry_i;
    for (entry_i = 0; entry_i < ENTYR_NUM; entry_i=entry_i+1) begin: TIMEOUT_CNT
        counter_rst #(
            .MAX_NUM (TIME_OUT_ns)
        )u_timeout_flag(
            .clk            ( clk                                   ), 
            .rst_n          ( rst_n                                 ), 
            .clean          ( rdy_in&vld_in&entry_id_in==entry_i    ), 
            .en             ( rdy_out*vld_out                       ), 
            .flag           ( time_out_flag[entry_i]                )  
        )

        qos_flag #(
            .QOS_TYPE (QOS_TYPE_NUM)
        )u_qos_flag(
            .clk            ( clk                                   ), 
            .rst_n          ( rst_n                                 ), 
            .clean          ( rdy_out&vld_out&entry_id_out==entry_i ), 
            .en             ( rdy_out*vld_out                       ), 
            .qos_type       ( qos_in                                ), 
            .mask           ( entry_state[entry_i]                  ), 
            .type_flag      ( qos_type_flag[entry_i]                )  
        )
    end
endgenerate

wire []



    
endmodule