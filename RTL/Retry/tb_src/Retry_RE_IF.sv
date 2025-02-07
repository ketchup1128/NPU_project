`ifndef Retry_RE_IF
  `define Retry_RE_IF

`include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_include.sv"
`timescale 1ns/1ps

interface Retry_RE_IF ( input bit clk );  

    logic                        rdy_out_grant;
    logic                        vld_out_grant;
    logic  [3                :0] grant_des_id;


    logic                        rdy_resp_out;
    logic                        vld_resp_out;
    logic  [`PAYLD_BW      -1:0] payload_out;

     
    clocking cbr_out @( posedge clk );
        input  vld_out_grant, grant_des_id, vld_resp_out, payload_out;
        output rdy_out_grant, rdy_resp_out;
    endclocking: cbr_out

    modport DUT( 
        input  rdy_out_grant, rdy_resp_out,
        output vld_out_grant, grant_des_id, vld_resp_out, payload_out
        );

    modport TB_Re( clocking cbr_out );

endinterface : Retry_RE_IF

typedef virtual Retry_RE_IF         vRE_IF;
typedef virtual Retry_RE_IF.TB_Re   vTB_Re;


`endif

