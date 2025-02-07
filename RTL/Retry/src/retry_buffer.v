module retry_buffer #(
    parameter   TIME_OUT_ns   = 10, 
    parameter   ENTYR_NUM     = 32, 
    parameter   QOS_CLASS_NUM = 4, 
    parameter   SRC_NODE_W    = 2, 
    parameter   PAYLD_BW      = 8
    // parameter   TRANS_NUM_W = 5; 
) (
    input               clk, 
    input               rst_n, 

    input                                  wr_en,
    input [$clog2(QOS_CLASS_NUM)     -1:0] qos_in, 
    input [SRC_NODE_W                -1:0] src_id, 
    input [PAYLD_BW                  -1:0] payload_in, 

    input  [QOS_CLASS_NUM            -1:0] rd_en,
    output [$clog2(QOS_CLASS_NUM)    -1:0] qos_out, 
    output [PAYLD_BW                 -1:0] payload_out, 
    output [SRC_NODE_W               -1:0] des_id


);


cmd_buffer #(
    .TIME_OUT_ns            (   TIME_OUT_ns             ),
    .ENTYR_NUM              (   ENTYR_NUM               ),
    .QOS_CLASS_NUM          (   QOS_CLASS_NUM           ), 
    .PAYLD_BW               (   PAYLD_BW + SRC_NODE_W   )
) inst_cmd_buffer(
    .clk                    (   clk                     ), 
    .rst_n                  (   rst_n                   ), 

    .wr_en                  (   wr_en                   ),
    .qos_in                 (   qos_in                  ), 
    .payload_in             (   {payload_in, src_id}    ), 

    .rd_en                  (   rd_en                   ),
    .payload_out            (   {payload_out, des_id}   ), 
    .qos_out                (   qos_out                 )

);




    
endmodule