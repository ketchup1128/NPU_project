`ifndef Retry_Generator
    `define Retry_Generator

    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_include.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_Package.sv"
class Retry_Generator;
    Retry_Package        blueprint;
    mailbox              gen2drv;
    event                drv2gen;

    int                  pack_size;

    extern function new( 
        input mailbox          gen2drv, 
        input event            drv2gen, 
        input int              pack_size
        );

    extern virtual task run();
    
endclass : Retry_Generator


function Retry_Generator::new(  
        input mailbox          gen2drv, 
        input event            drv2gen, 
        input int              pack_size
        );
    this.gen2drv      = gen2drv;
    this.drv2gen      = drv2gen;
    this.pack_size    = pack_size;


endfunction: new


task Retry_Generator:: run();

    Retry_Package conv_pack;
    conv_pack = new(pack_size);
    
    blueprint = new(pack_size);
    blueprint.run();
    $cast(conv_pack, blueprint.copy());
    gen2drv.put(conv_pack);
    @drv2gen;

    $display("gen data over");
endtask : run

`endif 