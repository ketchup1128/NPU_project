`ifndef Conv_pack_
    `define Conv_pack_ 

    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Retry_include.sv"
    `include "/workspace/home/liumin/Code/RetryEngine/tb_src/Package_Base.sv"
class Retry_Package extends Package_Base;

    //=====================================================
    //========== define the data package port  ============
    //=====================================================
    bit [`PAYLD_BW+`SRC_NODE_W+4+1 - 1 : 0]data_mem[$] = {};
    int pack_size;


    extern function new (input int pack_size);
    extern virtual function bit compare (input Package_Base to); 
    extern virtual function Package_Base copy(input Package_Base to = null); 
    // extern virtual function void display(input string prefix = ""); 
    extern virtual function void copy_data (input Retry_Package copy); 
    //=====================================================
    //============== user-defined function ================
    //=====================================================
    // extern virtual task run_cfg ( Layer_Basic_Info basic_info ); 
    extern virtual task run (); 
    
endclass : Retry_Package

function Retry_Package::new(input int pack_size);
    super.new();
    self.pack_size = pack_size;
endfunction: new


function bit Retry_Package::compare( input Package_Base to );
    Retry_Package gb_pack;
    gb_pack = new(pack_size);

    $cast(gb_pack, to);
    if (this.data_mem  != gb_pack.data_mem ) return 0;
    // if (this.pack_size != gb_pack.pack_size) return 0;
    return 1;
endfunction: compare


function void Retry_Package::copy_data( input Retry_Package copy );
    copy.data_mem  = this.data_mem;
    // copy.pack_size = this.pack_size;
endfunction: copy_data


function Package_Base Retry_Package::copy( input Package_Base to=null );
    Retry_Package des;
    des = new(pack_size);

    if (to == null) 
        des = new(pack_size);
    else 
        $cast(des, to);
       
    copy_data(des);
    return des;
endfunction: copy



//=====================================================
//===== generate the cfg/data package for DUT =========
//=====================================================

task Retry_Package::run();

    bit                         req_type; // 0: not allow retry; 1: allow retry
    bit  [3                 :0] qos_type; 
    bit  [`SRC_NODE_W     -1:0] src_id; 
    bit  [`PAYLD_BW       -1:0] payload_in;

    string  f;
    integer p;
    

    for (int i = 0; i < pack_size; i++) begin

        req_type   = {$random}%2;
        qos_type   = {$random}%16;
        src_id     = {$random}%4;
        payload_in = i;

        data_mem.push_back({req_type, qos_type, src_id, payload_in});

        f = $psprintf("./Trigger_data.txt");
        p = $fopen(f, "ab+");
        $fwrite(p, "%3d ", req_type);
        $fwrite(p, "%3d ", qos_type);
        $fwrite(p, "%3d ", src_id);
        $fwrite(p, "%3d ", payload_in);
        $fwrite(p, "\n");
        $fclose(p);

    end


endtask: run

`endif


