`ifndef Retry_TR_IF
  `define Retry_TR_IF

`include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_include.sv"

`timescale 1ns/1ps

interface Retry_TR_IF(
    input bit clk
);  

    logic                         rdy_req_in; 
    logic                         vld_req_in; 
    logic                         req_type; // 0: not allow retry; 1: allow retry
    logic  [3                 :0] qos_type; 
    logic  [`SRC_NODE_W     -1:0] src_id; 
    logic  [`PAYLD_BW       -1:0] payload_in; 
     

    clocking cbt_in @(posedge clk);
        input  rdy_req_in;
        output vld_req_in, req_type, qos_type, src_id, payload_in;
    endclocking: cbt_in

    modport DUT( 
        input  vld_req_in, req_type, qos_type, src_id, payload_in,
        output rdy_req_in
        );

    modport TB_Tr(clocking cbt_in);

endinterface : Retry_TR_IF

typedef virtual Retry_TR_IF         vTR_IF;
typedef virtual Retry_TR_IF.TB_Tr   vTB_Tr;


`endif

