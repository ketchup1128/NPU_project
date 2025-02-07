`ifndef Retry_ENV
    `define Retry_ENV

    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_include.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_TR_IF.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_Package.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_Generator.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_Driver.sv"
class Retry_ENV;
    Retry_Generator      gen;
    Retry_Driver         drv;
    mailbox              gen2drv;
    event                drv2gen;

    vTB_Tr              TrGrp_IF;

    int                 pack_size;

    // int       nPatch, nFilter;


    extern function new( vTB_Tr TrGrp_IF, int pack_size);
    extern virtual task reset();
    extern virtual function void build();
    extern virtual task run();
endclass : Retry_ENV


function Retry_ENV::new( vTB_Tr TrGrp_IF, int pack_size );

    this.TrGrp_IF   = TrGrp_IF;
    this.pack_size  = pack_size;

endfunction: new


task Retry_ENV::reset();
    $system("rm -rf ./trigger/*");
    // $system("rm -rf ./dump/*");

    TrGrp_IF.cbt_in.vld_req_in <= 0;

    // end
    top.rst_n <= 1'd0;
    repeat(180+$urandom%20) @ (posedge top.clk);
    top.rst_n <= 1'd1;
    repeat(200+$urandom%20) @ (posedge top.clk);
    top.rst_n <= 1'd0;
    repeat(10+$urandom%20) @ (posedge top.clk);
    top.rst_n <= 1'd1;
    repeat(30+$urandom%20) @ (posedge top.clk);

endtask


function void Retry_ENV::build();

    gen = new(gen2drv, drv2gen, pack_size);
    drv = new(gen2drv, drv2gen, TrGrp_IF, pack_size);
    gen2drv = new();
    // drv2gen = new();

    // foreach (basic_info[i]) begin
    //     gen2drv[i] = new();
    //     gen[i] = new(gen2drv[i], drv2gen[i], basic_info[i]);
    //     drv[i] = new(gen2drv[i], drv2gen[i], TrGrp_IF[i], basic_info[i]);
    // end

endfunction: build


task Retry_ENV::run ();

    fork  
        gen.run();
        drv.run();
    join_none

    wait fork;
endtask: run 


`endif
