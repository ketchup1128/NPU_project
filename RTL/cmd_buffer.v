module cmd_buffer #(
    parameter   TIME_OUT_ns   = 10,
    parameter   ENTYR_NUM     = 32,
    parameter   QOS_CLASS_NUM = 4, 
    parameter   PAYLD_BW      = 8
    // parameter   TRANS_NUM_W = 5; 
) (
    input               clk, 
    input               rst_n, 

    input                                wr_en,
    input  [$clog2(QOS_CLASS_NUM)  -1:0] qos_in, 
    input  [PAYLD_BW               -1:0] payload_in, 

    input  [QOS_CLASS_NUM          -1:0] rd_en,
    output [PAYLD_BW               -1:0] payload_out,
    input  [$clog2(QOS_CLASS_NUM)  -1:0] qos_out 

);

wire [$clog2(ENTYR_NUM) -1:0]entry_id_in;
reg  [$clog2(ENTYR_NUM) -1:0]entry_id_out; 


reg  [ENTYR_NUM-1 :0] entry_state; // 0: free to be written, 1: 

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        entry_state <= 0;
    end else begin 

        for (integer i = 0; i < ENTYR_NUM; i = i + 1) begin
            if ( entry_id_in == i && wr_en == 1) begin
                entry_state[i] <= 1'b1;
            end else if (entry_id_out == i && |rd_en == 1) begin
                entry_state[i] <= 1'b0;
            end
        end 
        
    end 
end

//====================================================================================
//     determine which entry to be written              
//====================================================================================


RR_arbiter #(
    .REQ_WIDTH ( ENTYR_NUM )
)u_RR_arbiter_entri_in(
    .clk        ( clk          ),
    .rst_n      ( rst_n        ),
    .req        ( ~entry_state ),
    .arb_port   ( entry_id_in  )
);


//====================================================================================
//     determine which entry to be readout               
//====================================================================================

wire [ENTYR_NUM-1 :0]time_out_flag;
wire [ENTYR_NUM-1 :0][QOS_CLASS_NUM-1:0]qos_flag_entry;
reg  [QOS_CLASS_NUM-1:0][ENTYR_NUM-1 :0]qos_flag;

generate
    genvar entry_i;
    for (entry_i = 0; entry_i < ENTYR_NUM; entry_i=entry_i+1) begin: TIMEOUT_CNT

        wire time_out_flag_temp;

        counter_rst #(
            .MAX_NUM (TIME_OUT_ns)
        )u_timeout_flag(
            .clk            ( clk                                   ), 
            .rst_n          ( rst_n                                 ), 
            .clean          ( wr_en && (entry_id_in==entry_i)       ), 
            .en             ( |rd_en                                ),  //  clk count or rd_en count?
            .flag           ( time_out_flag_temp                    )  
        );

        qos_flag #(
            .QOS_TYPE (QOS_CLASS_NUM)
        )u_qos_flag(
            .clk            ( clk                                   ), 
            .rst_n          ( rst_n                                 ), 
            .clean          ( |rd_en && (entry_id_out==entry_i)     ), 
            .en             ( wr_en                                 ), 
            .qos_type       ( qos_in                                ), 
            .type_flag      ( qos_flag_entry[entry_i]               )  
        );

        assign time_out_flag[entry_i] = time_out_flag_temp && |(rd_en & qos_flag_entry[entry_i]);
    end

endgenerate

always @(*) begin
    for (integer i = 0; i < QOS_CLASS_NUM; i = i+1) begin
        for (integer j = 0; j < ENTYR_NUM; j = j+1) begin
            qos_flag[i][j] = qos_flag_entry[j][i];
        end
    end
end

reg [$clog2(QOS_CLASS_NUM) -1:0]qos_type;
always @(*) begin
    qos_type = 0;
    for (integer i = 0; i < QOS_CLASS_NUM; i = i+1) begin
        if (rd_en[i]) begin 
            qos_type = i;
        end 
    end
end


//--------  the entries with the highest qos class level --------  

wire [QOS_CLASS_NUM -1:0][$clog2(ENTYR_NUM) -1:0]entry_id_out_qos;
generate
    genvar qos_i;
    for (qos_i = 0; qos_i < QOS_CLASS_NUM; qos_i = qos_i + 1) begin
        RR_arbiter #(
            .REQ_WIDTH ( ENTYR_NUM )
        )u_RR_arbiter(
            .clk        ( clk                                      ),
            .rst_n      ( rst_n                                    ),
            // .en         ( (qos_type == qos_i) && ~(|time_out_flag) ),
            .req        ( qos_flag[qos_i]                          ),
            .arb_port   ( entry_id_out_qos[qos_i]                  )
        );
    end
endgenerate


//--------  the time out entry --------  
wire [$clog2(ENTYR_NUM) -1:0]entry_id_timeout;
RR_arbiter #(
    .REQ_WIDTH ( ENTYR_NUM )
)u_RR_arbiter_timeout(
    .clk        ( clk                  ),
    .rst_n      ( rst_n                ),
    .req        ( time_out_flag        ),
    .arb_port   ( entry_id_timeout     )
);


reg  [$clog2(ENTYR_NUM) -1:0]entry_id_out_reg; 

always @(*) begin
    if (|entry_state) begin
        entry_id_out = ~(|time_out_flag) ? entry_id_out_qos[qos_type] : entry_id_timeout;
    end else begin
        entry_id_out = entry_id_out_reg;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        entry_id_out_reg <= 0;
    end else begin
        entry_id_out_reg <= entry_id_out;
    end
end

//====================================================================================
//     buffer storeing the payload               
//====================================================================================
reg [PAYBW -1:0]CMD_buffer[0:ENTYR_NUM-1];
reg [PAYBW -1:0]payload_out_reg;
reg [QOS_CLASS_NUM -1:0]qos_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        CMD_buffer <= 0;
    end else begin
        if  (wr_en) begin
            CMD_buffer[entry_id_in] <= payload_in;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        payload_out_reg <= 0;
    end else begin
        if  (rd_en) begin
            payload_out_reg <= CMD_buffer[entry_id_out];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        qos_out_reg <= 0;
    end else begin
        if  (rd_en) begin
            qos_out_reg <= ~(|time_out_flag) ? qos_type : qos_flag_entry[entry_id_timeout];
        end
    end
end

assign payload_out = payload_out_reg;
assign qos_out     = qos_out_reg;

endmodule