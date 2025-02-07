`ifndef Package_Base_
    `define Package_Base_

virtual class Package_Base;
    static int count;
    int id;

    function new();
        id = count++;
    endfunction : new
    
    pure virtual function bit compare(input Package_Base to);
    pure virtual function Package_Base copy(input Package_Base to = null);
    // pure virtual function void display(input string prefix = "");

endclass : Package_Base


`endif 