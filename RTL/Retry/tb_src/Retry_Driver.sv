`ifndef Retry_Driver
    `define Retry_Driver

`include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_TR_IF.sv"
`include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_Package.sv"

typedef class Retry_Driver;

class Driver_cbs;
    virtual task pre_tx(
        input Retry_Driver  drv, 
        input Retry_Package req_pack, 
        inout bit           drop );
    endtask

    virtual task post_tx(
        input Retry_Driver  drv, 
        input Retry_Package req_pack);
    endtask // post_tx
endclass : Driver_cbs


class Retry_Driver;
    mailbox          gen2drv;
    event            drv2gen;
    vTB_Tr           Tr;
    Driver_cbs       cbsq[$];
    int              pack_size;

    extern function new( 
        input mailbox          gen2drv, 
        input event            drv2gen, 
        input vTB_Tr           Tr, 
        input int              pack_size);

    extern task run();
    extern task send(input Retry_Package req_pack);

endclass : Retry_Driver

function Retry_Driver:: new( 
    input mailbox          gen2drv, 
    input event            drv2gen, 
    input vTB_Tr           Tr, 
    input int              pack_size);

    this.gen2drv    = gen2drv;
    this.drv2gen    = drv2gen;
    this.Tr         = Tr;
    this.pack_size  = pack_size;

endfunction : new
    
task Retry_Driver:: run();
    Retry_Package req_pack;
    bit drop = 0;

    req_pack = new(pack_size);


    forever begin
        gen2drv.peek(req_pack);
        begin: Tr
            foreach (cbsq[i]) begin
                cbsq[i].pre_tx(this, req_pack, drop);
                if (drop) begin
                    disable Tr;
                end
            end
        end

        send(req_pack);
        foreach (cbsq[i]) begin
            cbsq[i].post_tx(this, req_pack);
        end

        gen2drv.get(req_pack);
        ->drv2gen;
        // $display("drive done");
    end
endtask : run


//=====================================================
//================= send data to DUT ==================
//=====================================================
task Retry_Driver:: send(input Retry_Package req_pack);

    fork
        
        foreach (req_pack.data_mem[i]) begin
            do begin 

                {Tr.cbt_in.req_type, Tr.cbt_in.qos_type, Tr.cbt_in.src_id, Tr.cbt_in.payload_in} <= req_pack.data_mem[i];
                Tr.cbt_in.vld_req_in <= 1;

            end while(~(Tr.cbt_in.vld_req_in & Tr.cbt_in.rdy_req_in));
            
        end

        
    join
    
    
endtask : send


`endif





