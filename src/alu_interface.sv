interface alu_inf(input bit CLK,RST);
logic[`n-1:0] OPA, OPB;
logic[1:0]INP_VALID;
logic[`m-1:0]CMD;
logic CE, CIN,MODE;
logic ERR,OFLOW,COUT,G,L,E;
logic [`n:0] RES;

  property ppt_reset;
       @(posedge CLK) RST |=> ##[1:5] (RES === 9'bzzzzzzzz && ERR === 1'bz && E === 1'bz && G === 1'bz && L === 1'bz && COUT === 1'bz && OFLOW === 1'bz)
  endproperty

property ce_implication;
   @(posedge CLK) disable iff (RST)
      (CE == 1) |-> (INP_VALID inside {[0:3]});
  endproperty
  assert property (ce_implication)$display("assertion passed",$time);
    else $error("[ASSERTION FAILED] CE asserted but INP_VALID not set");

 assert property (@(posedge CLK) (INP_VALID == 2'b00) |=> ERR )$display("Error raised");
 else $info("ERROR NOT raised");


clocking drv_cb@(posedge CLK);
default input #0 output #0;
input RST;
output OPA, OPB, INP_VALID, CMD, CE, CIN, MODE;
endclocking

clocking mon_cb@(posedge CLK);
default input #0 output #0;
input ERR, OFLOW, COUT, G, L, E, RES, CMD, MODE;
endclocking


clocking ref_cb@(posedge CLK);
default input #0 output #0;
input RST;
endclocking

modport DRV(clocking drv_cb);
modport MON(clocking mon_cb);
modport REF_SB(clocking ref_cb);
endinterface
