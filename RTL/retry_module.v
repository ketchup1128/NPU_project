module RetryEngine #(
    parameter SRC_NODE_W     = 2,
    parameter CMD_ENTRY_NUM  = 32, 
    parameter RTY_ENTRY_NUM  = 16, 
    parameter PAYLD_BW       = 8,
    parameter QoS_CLASS      = 4
)(
    input clk, 
    input rst_n, 

    output                       rdy_req_in, 
    input                        vld_req_in, 
    input                        req_type, // 0: not allow retry, 1: allow retry
    input  [3                :0] qos_type, 
    input  [SRC_NODE_W     -1:0] src_id, 
    input  [PAYLD_BW       -1:0] payload_in, 


    input                        rdy_out_grant, 
    output                       vld_out_grant, 
    output [3                :0] grant_des_id, 


    input                        rdy_resp_out, 
    output                       vld_resp_out, 
    output [PAYLD_BW       -1:0] payload_out

);

// ==============================================================================================
//       set qos priority and set entry num for each qos class
// ==============================================================================================
    localparam int Q_CMD_ENTRY_NUM[4]   = '{CMD_ENTRY_NUM, CMD_ENTRY_NUM/2, CMD_ENTRY_NUM/4, CMD_ENTRY_NUM/8};  
    localparam int Q_LEVEL[4]           = '{8, 12, 15, 16};  
    localparam RESERVE_ENTRY_NUM        = 2;
    

    reg  [QoS_CLASS -1:0]allc_cnt_inc, allc_cnt_dec;
    reg  [QoS_CLASS -1:0]infl_cnt_inc, infl_cnt_dec;
    reg  [QoS_CLASS -1:0]rty_cnt_inc , rty_cnt_dec ;

    reg  [QoS_CLASS -1:0][$clog2(CMD_ENTRY_NUM)     :0]allc_cnt
    reg  [QoS_CLASS -1:0][$clog2(RTY_ENTRY_NUM)     :0]infy_cnt;
    reg  [QoS_CLASS -1:0][$clog2(RTY_ENTRY_NUM)     :0]rty_cnt;

    reg [$clog2(CMD_ENTRY_NUM) :0] allc_cnt_total, infly_cnt_total, rty_cnt_total;      


    // reg cmd_full, cmd_empty;
    // reg rty_full, rty_empty;

    // one hot
//=============================================================================================
//    def QoS class
//=============================================================================================
reg  [$clog2(QoS_CLASS) -1:0]q_group_in;

always @(*) begin
    q_group_in = 0;
    for (integer i = 1; i < QoS_CLASS ; i = i + 1) begin
        if (qos_type > Q_LEVEL[i]) begin
            q_group_in = i;
        end
    end
end



//=============================================================================================
//        gen cmd_buffer rd_en, wr_en
//=============================================================================================
wire cmd_buf_wr_en, cmd_buf_rd_en;

always @(posedge clk negedge rst_n) begin
    if (~rst_n) begin
        allc_cnt_total <= 0;
    end else begin
        allc_cnt_total <= allc_cnt_total + cmd_buf_wr_en - cmd_buf_rd_en;
    end
end

// for not allow retry: cmd buffer is not full, alloc_cnt[qos_type] < Q_CMD_ENTRY_NUM[qos_type], write req to cmd buffer
// for allow retry: cmd buffer is not full (reserver entry do not take into consider), alloc_cnt[qos_type]+infly_cnt[qos_type] < Q_CMD_ENTRY_NUM[qos_type], write req to cmd buffer
reg [QoS_CLASS -1:0]cmd_wr_en_allrey_n, cmd_wr_en_allrey;
always @(*) begin
    for (integer i = 0; i < QoS_CLASS; i = i + 1) begin
        cmd_wr_en_allrey[i]  = (Q_CMD_ENTRY_NUM[i]- RESERVE_ENTRY_NUM > rty_cnt[i] + allc_cnt[i]) && (CMD_ENTRY_NUM - RESERVE_ENTRY_NUM > allc_cnt_total + rty_cnt_total);
        cmd_wr_en_nallrey[i] = (Q_CMD_ENTRY_NUM[i] > allc_cnt[i]) && (CMD_ENTRY_NUM > allc_cnt_total);
    end
end

reg [QoS_CLASS -1:0]cmd_buf_rd_en_qos;
always @(*) begin
    for (integer i = 0; i < QoS_CLASS; i = i + 1) begin
        cmd_buf_rd_en_qos[i] = (allc_cnt[i] > 0) && (vld_resp_out == 0 || rdy_resp_out == 1);
    end
end

assign cmd_buf_wr_en = (req_type == 0 ? (cmd_wr_en_nallrey[q_group_in]) : (cmd_wr_en_allrey[q_group_in]));
assign cmd_buf_rd_en = |cmd_buf_rd_en_qos;

wire [$clog2(QOS_CLASS_NUM) -1:0]q_group_out;
cmd_buffer #(
    .TIME_OUT_ns            (   TIME_OUT_ns             ),
    .ENTYR_NUM              (   CMD_ENTRY_NUM           ),
    .QOS_CLASS_NUM          (   QoS_CLASS               ), 
    .PAYLD_BW               (   PAYLD_BW                )
) inst_cmd_buffer(
    .clk                    (   clk                     ), 
    .rst_n                  (   rst_n                   ), 

    .wr_en                  (   vld_req_in & cmd_buf_wr_en           ),
    .qos_in                 (   q_group_in              ), 
    .payload_in             (   payload_in              ), 

    .rd_en                  (   cmd_buf_rd_en_qos       ),
    .qos_out                (   q_group_out             ),
    .payload_out            (   payload_out_cmd         )

);


//=============================================================================================
//        gen rty_buffer rd_en, wr_en
//=============================================================================================
wire rty_buf_wr_en, rty_buf_rd_en;

reg [QoS_CLASS -1:0]rty_buf_rd_en_qos;
always @(*) begin
    for (integer i = 0; i < QoS_CLASS; i = i + 1) begin
        rty_buf_rd_en_qos[i] = (allc_cnt[i] + infly_cnt[i] < Q_CMD_ENTRY_NUM[i]) && (rty_cnt[i] > infly_cnt[i]) && (rdy_out_grant == 1 || vld_out_grant == 0);
    end
end

assign rty_buf_wr_en = (req_type == 1) && (|cmd_wr_en_allrey == 0) && (rty_cnt_total < RTY_ENTRY_NUM);
assign rty_buf_rd_en = |rty_buf_rd_en_qos;

wire [$clog2(QOS_CLASS_NUM) -1:0]rty_qos_out;

retry_buffer #(
    .TIME_OUT_ns            (   TIME_OUT_ns             ),
    .ENTYR_NUM              (   CMD_ENTRY_NUM           ),
    .QOS_CLASS_NUM          (   QoS_CLASS               ), 
    .PAYLD_BW               (   PAYLD_BW                ), 
    .SRC_NODE_W             (   SRC_NODE_W              )
) inst_retry_buffer(
    .clk                    (   clk                     ), 
    .rst_n                  (   rst_n                   ), 

    .wr_en                  (   vld_req_in & rty_buf_wr_en           ),
    .qos_in                 (   q_group_in              ), 
    .src_id                 (   src_id                  ), 
    .payload_in             (   payload_in              ), 

    .rd_en                  (   rty_buf_rd_en_qos       ),
    .qos_out                (   rty_qos_out             ), 
    .payload_out            (   payload_out_cmd         ), 
    .des_id                 (   grant_des_id            )

);


// --------------------------------------------------------------------------------------
//    update free counter
// --------------------------------------------------------------------------------------

always @(*) begin
    for (integer i = 0; i < QoS_CLASS; i=i+1) begin
        allc_cnt_inc[i] = q_group_in  == i ? cmd_buf_wr_en : 0;
        allc_cnt_dec[i] = q_group_out == i ? cmd_buf_rd_en : 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        allc_cnt <= 0;
    end else begin
        for (integer i = 0; i < QoS_CLASS; i = i + 1) begin
            allc_cnt[i] <= allc_cnt[i] + allc_cnt_inc[i] - allc_cnt_dec[i];
        end
    end
end


// --------------------------------------------------------------------------------------
//    update retry counter
// --------------------------------------------------------------------------------------

always @(*) begin
    for (integer i = 0; i < QoS_CLASS; i=i+1) begin
        rty_cnt_inc[i] = q_group_in  == i ? rty_buf_wr_en : 0;
        rty_cnt_dec[i] = q_group_in  == i ? cmd_buf_wr_en : 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rty_cnt <= 0;
    end else begin
        for (integer i = 0; i < QoS_CLASS; i = i + 1) begin
            rty_cnt[i] <= rty_cnt[i] + rty_cnt_inc[i] - rty_cnt_dec[i];
        end
    end
end


// --------------------------------------------------------------------------------------
//    update inflight counter
// --------------------------------------------------------------------------------------

always @(*) begin
    for (integer i = 0; i < QoS_CLASS; i=i+1) begin
        infl_cnt_inc[i] = rty_qos_out == i ? rty_buf_rd_en : 0;
        infl_cnt_dec[i] = q_group_in  == i ? cmd_buf_wr_en : 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        infy_cnt <= 0;
    end else begin
        for (integer i = 0; i < QoS_CLASS; i = i + 1) begin
            infy_cnt[i] <= infy_cnt[i] + infy_cnt_inc[i] - infy_cnt_dec[i];
        end
    end
end




//=============================================================================================
//        gen input rdy, vld
//=============================================================================================

assign rdy_req_in = cmd_buf_wr_en | rty_buf_wr_en;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        vld_resp_out <= 0;
    end else if (rdy_resp_out) begin
        vld_resp_out <= cmd_buf_rd_en;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        vld_out_grant <= 0;
    end else if (rdy_out_grant) begin
        vld_out_grant <= rty_buf_rd_en;
    end
end

endmodule