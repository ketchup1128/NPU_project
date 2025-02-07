module counter_rst #(
    parameter MAX_NUM = 100

)(
    input clk, 
    input rst_n, 

    input                           clean, 
    input                           en, 

    output [$clog2(MAX_NUM)   -1:0] count, 
    output                          flag
);


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        count <= 0;
    end else if (clean) begin
        count <= 0;
    end else if (en) begin
        count <= count == MAX_NUM ? count : count + 1;
    end
end

assign flag = count == MAX_NUM;


    
endmodule