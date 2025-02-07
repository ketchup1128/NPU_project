//======================================================
// Copyright (C) 2020 By 
// All Rights Reserved
//======================================================
// Module : 
// Author : 
// Contact : 
// Date : 
//=======================================================
// Description :
//========================================================
`ifndef HFM_DUMP
  `define HFM_DUMP

module HFM_DUMP(
  input   Clk,
  input   rst_n,
  
  input   DumpStart,
  input   DumpEnd
);

  string  f_data, f_flag;
  integer p_data, p_flag;
  int data_cnt;
  int flag_cnt;
  int frame_cnt;
  string cmd;

initial begin
  $system("rm ./dump/* -rf");
  $system("mkdir ./dump/Frame00");
end

always @ ( posedge Clk )begin
  if( top.Top.inst_SSCNN.HFM.GBB_in_req && top.Top.inst_SSCNN.HFM.GBB_out_ack )begin
    cmd = $psprintf("mkdir ./dump/Frame%02d/Data%02d", frame_cnt, data_cnt);
    //$display(cmd);
    $system(cmd);
  end
end

always @ ( posedge Clk )begin
  if( top.Top.inst_SSCNN.HFM.GBB_out_valid && top.Top.inst_SSCNN.HFM.GBB_out_ready )begin
    f_data = $psprintf("./dump/Frame%02d/Data%02d/data%02d.txt", frame_cnt, data_cnt, top.Top.inst_SSCNN.HFM.GBB_out_decoder_id);
    p_data = $fopen(f_data, "ab+");
    for(integer i = 0; i < 16; i = i + 1 )begin
      $fwrite(p_data, "%3d ", top.Top.inst_SSCNN.HFM.GBB_out_data[8*i +:8]);
      if( i %16 == 15 )$fwrite(p_data, "\n");
    end
    $fclose(p_data);
  end
end

always @ ( posedge Clk )begin
  if( top.Top.inst_SSCNN.HFM.GBFB_in_req && top.Top.inst_SSCNN.HFM.GBFB_out_ack )begin
    cmd = $psprintf("mkdir ./dump/Frame%02d/Flag%02d", frame_cnt, flag_cnt);
    //$display(cmd);
    $system(cmd);
  end
end

always @ ( posedge Clk )begin
  if( top.Top.inst_SSCNN.HFM.GBFB_out_valid && top.Top.inst_SSCNN.HFM.GBFB_out_ready )begin
    f_flag = $psprintf("./dump/Frame%02d/Flag%02d/data%02d.txt", frame_cnt, flag_cnt, top.Top.inst_SSCNN.HFM.GBB_out_decoder_id);
    p_flag= $fopen(f_flag, "ab+");
    for(integer i = 0; i < 16; i = i + 1 )begin
      $fwrite(p_flag, "%3d ", top.Top.inst_SSCNN.HFM.GBFB_out_data[8*i +:8]);
      if( i %16 == 15 )$fwrite(p_flag, "\n");
    end
    $fclose(p_flag);
  end
end

always @ ( posedge Clk or negedge rst_n )begin
  if( !rst_n )
    data_cnt <= 0;
  else if( top.DumpEnd )
    data_cnt <= 0;
  else if( top.Top.inst_SSCNN.HFM.GBB_out_valid && top.Top.inst_SSCNN.HFM.GBB_out_ready && top.Top.inst_SSCNN.HFM.GBB_out_last )
    data_cnt <= data_cnt + 1;
end

always @ ( posedge Clk or negedge rst_n )begin
  if( !rst_n )
    flag_cnt <= 0;
  else if( top.DumpEnd )
    flag_cnt <= 0;
  else if( top.Top.inst_SSCNN.HFM.GBFB_out_valid && top.Top.inst_SSCNN.HFM.GBFB_out_ready && top.Top.inst_SSCNN.HFM.GBFB_out_last )
    flag_cnt <= flag_cnt + 1;
end

always @ ( posedge Clk or negedge rst_n )begin
  if( !rst_n )
    frame_cnt <= 0;
  else if( top.DumpEnd )begin
    frame_cnt <= frame_cnt + 1;
    cmd = $psprintf("mkdir ./dump/Frame%02d", frame_cnt+1);
    //$display(cmd);
    $system(cmd);
  end
end
  
endmodule

`endif
