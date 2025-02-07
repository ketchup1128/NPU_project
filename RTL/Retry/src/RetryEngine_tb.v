`timescale  1 ns / 100 ps

module RetryEngine_tb;

parameter SRC_NODE_W     = 2;
parameter CMD_ENTRY_NUM  = 32; 
parameter RTY_ENTRY_NUM  = 16; 
parameter PAYLD_BW       = 8;
parameter QoS_CLASS      = 4;
    
reg clk, rst_n;

wire rdy_req_in;
reg  vld_req_in;

reg                        req_type; // 0: not allow retry; 1: allow retry
reg  [3                :0] qos_type; 
reg  [SRC_NODE_W     -1:0] src_id; 
reg  [PAYLD_BW       -1:0] payload_in;

reg                         rdy_out_grant;
wire                        vld_out_grant;
wire  [3                :0] grant_des_id;


reg                          rdy_resp_out;
wire                         vld_resp_out;
wire   [PAYLD_BW       -1:0] payload_out;



RetryEngine#(
    .SRC_NODE_W    ( 2 ),
    .CMD_ENTRY_NUM ( 32 ),
    .RTY_ENTRY_NUM ( 16 ),
    .PAYLD_BW      ( 8 ),
    .QoS_CLASS     ( 4 )
)u_RetryEngine(
    .clk           ( clk           ),
    .rst_n         ( rst_n         ),
    .rdy_req_in    ( rdy_req_in    ),
    .vld_req_in    ( vld_req_in    ),
    .req_type      ( req_type      ),
    .qos_type      ( qos_type      ),
    .src_id        ( src_id        ),
    .payload_in    ( payload_in    ),
    .rdy_out_grant ( rdy_out_grant ),
    .vld_out_grant ( vld_out_grant ),
    .grant_des_id  ( grant_des_id  ),
    .rdy_resp_out  ( rdy_resp_out  ),
    .vld_resp_out  ( vld_resp_out  ),
    .payload_out   ( payload_out   )
);



initial begin
    clk = 0;
end

always #10 clk = ~clk;


initial begin
    rst_n      =  1;
    #11 rst_n  =  0;
    #54 rst_n  =  1;
end



initial begin
    vld_req_in = 0;
    req_type   = 0;
    payload_in = 1;
    rdy_out_grant = 0;
    rdy_resp_out  = 0;
end



always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        req_type <= 0;
    end else begin
        if (rdy_req_in&vld_req_in) begin
            // req_type <= {$random}%2;
            req_type <= 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        vld_req_in <= 0;
    end else begin
        if (rdy_req_in|(~vld_req_in)) begin
            vld_req_in <= {$random}%2;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        qos_type <= 0;
        src_id   <= 0;
    end else begin
        if (rdy_req_in&vld_req_in) begin
            qos_type <= {$random}%16;
            src_id   <= {$random}%3;
        end
    end
end





initial begin
    #1000;
    $finish;
end


endmodule