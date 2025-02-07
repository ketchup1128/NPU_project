module max_4to1 #(
    parameter NUM = 4, 
    parameter BW  = 4
) (
    input [NUM -1:0][BW -1:0]data_in, 

    output  [BW -1:0]max
);
    
wire [1:0][BW-1:0]max_tmp;

assign max_tmp[0] = data_in[0] > data_in[1] ? data_in[0] : data_in[1];
assign max_tmp[1] = data_in[2] > data_in[3] ? data_in[2] : data_in[3];

assign max = max_tmp[0] > max_tmp[1] ? max_tmp[0] : max_tmp[1];

endmodule