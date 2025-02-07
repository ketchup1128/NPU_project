`ifndef Retry_tb_top
  `define Retry_tb_top

`include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_TEST.sv"
`include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_include.sv"

module Retry_tb_top;

    bit  clk;
    bit  rst_n; 

    bit                         rdy_req_in; 
    bit                         vld_req_in; 
    bit                         req_type; // 0: not allow retry; 1: allow retry
    bit  [3                 :0] qos_type; 
    bit  [`SRC_NODE_W     -1:0] src_id; 
    bit  [`PAYLD_BW       -1:0] payload_in; 


    bit                        rdy_out_grant; 
    bit                        vld_out_grant; 
    bit  [`SRC_NODE_W    -1:0] grant_des_id; 


    bit                        rdy_resp_out; 
    bit                        vld_resp_out; 
    bit  [`PAYLD_BW      -1:0] payload_out;


    initial begin
        clk = 'd0;
    end
    always #10 clk = ~clk;
    
    // HFM_IF hfm_if(clk);
    Rerey_TR_IF #() Tr_if(clk);

    Retry_TEST  TEST_GB(Tr_if, clk);


    RetryEngine#(
        .SRC_NODE_W    ( `SRC_NODE_W ),
        .CMD_ENTRY_NUM ( `CMD_ENTRY ),
        .RTY_ENTRY_NUM ( `RTY_ENTRY ),
        .PAYLD_BW      ( `PAYLD_BW ),
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



always @ ( rdy_req_in or clk ) begin
  Tr_if.DUT.rdy_req_in <= rdy_req_in;
end

always @ ( * )begin
  vld_req_in <= Tr_if.DUT.vld_req_in;
  req_type   <= Tr_if.DUT.req_type;
  qos_type   <= Tr_if.DUT.qos_type;
  req_type   <= Tr_if.DUT.req_type;
  src_id     <= Tr_if.DUT.src_id;
  payload_in <= Tr_if.DUT.payload_in;
end

endmodule