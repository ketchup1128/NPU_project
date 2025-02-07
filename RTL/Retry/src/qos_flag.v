module qos_flag #(
    parameter QOS_CLASS_TYPE = 4

)(
    input clk, 
    input rst_n, 

    input                                  clean, 
    input                                  en, 
    input  [$clog2(QOS_CLASS_TYPE)   -1:0] qos_class, 

    output [QOS_CLASS_TYPE           -1:0] type_flag 
);

reg [QOS_CLASS_TYPE           -1:0] type_flag_reg; 
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        type_flag_reg <= 0;
    end else if (clean) begin
        type_flag_reg <= 0;
    end else if (en) begin
        for (integer i = 0; i < QOS_CLASS_TYPE; i = i + 1) begin
            type_flag_reg[i] <= 1 ? i == qos_class : 0;
        end
    end
end

assign type_flag = type_flag_reg;
// assign type_flag = type_flag_reg & {QOS_TYPE{mask}};
    
endmodule