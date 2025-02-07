`ifndef CFG_INCLUDE
    `define CFG_INCLUDE 

// `define TOP_BW 64
// typedef struct {
//     // int channel_num; 
//     int layer_id; 
//     int Data_Pack;
//     // int port_id;
//     // int filter_Gp_id; 
//     string cfg_or_data;
//     string act_or_wei;
//     string data_or_flag;
// } Layer_Basic_Info;

// typedef struct {
//     bit [`TOP_BW - 1 : 0]data_mem[];
//     int pack_size; 
// } Data_Pack;

`define SRC_NODE_W  2
`define PAYLD_BW    8
`define CMD_ENTRY   32
`define RTY_ENTRY   32

`endif 

