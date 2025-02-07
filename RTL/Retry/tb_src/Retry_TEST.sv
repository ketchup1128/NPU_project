
`ifndef Retry_TEST
  `define Retry_TEST
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_Package.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_include.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_Generator.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_ENV.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_TR_IF.sv"
program automatic Retry_TEST(
    Retry_TR_IF.TB_Tr    Tr_if,  
    input bit clk
    );

    Retry_ENV env;

    // int               nPatch;
    // int               nFilter;
    // Layer_Basic_Info  basic_info[6];

    initial begin 

        env = new( Tr_if, 100 );
        env.reset();
        env.build();
        env.run();

    end 

    

endprogram

`endif
