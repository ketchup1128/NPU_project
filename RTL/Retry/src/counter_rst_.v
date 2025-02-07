module counter_rst #(
    parameter MAX_NUM = 100
)(
    input clk, 
    input rst_n, 

    input                           clean, 
    input                           en, 

    // output [$clog2(MAX_NUM)   -1:0] count, 
    output                          flag
);

reg [$clog2(MAX_NUM)   :0] count_reg;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        count_reg <= 0;
    end else if (clean) begin
        count_reg <= 0;
    end else if (en) begin
        count_reg <= count_reg == MAX_NUM ? count_reg : count_reg + 1;
    end
end

assign flag = (count_reg == MAX_NUM);
// assign count = count_reg;


endmodule