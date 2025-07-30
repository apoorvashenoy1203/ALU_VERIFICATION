
`include "defines.sv"
class alu_monitor;

  alu_transaction mon_trans;
  mailbox #(alu_transaction) mbx_ms;
  virtual alu_inf.MON vif;

  // Covergroup definition
  covergroup mon_cg;
    ERR      : coverpoint mon_trans.ERR { bins err[] = {0, 1}; }
    COUT     : coverpoint mon_trans.COUT { bins cout[] = {0, 1}; }
    OFLOW    : coverpoint mon_trans.OFLOW { bins oflow[] = {0, 1}; }
    E        : coverpoint mon_trans.E { bins e[] = {0, 1}; }
    G        : coverpoint mon_trans.G { bins g[] = {0, 1}; }
    L        : coverpoint mon_trans.L { bins l[] = {0, 1}; }
    RES      : coverpoint mon_trans.RES { bins res[] = {[0:(1<<(`n+1))-1]}; }
  endgroup

  // Constructor
  function new(virtual alu_inf.MON vif,
               mailbox #(alu_transaction) mbx_ms);
    this.vif = vif;
    this.mbx_ms = mbx_ms;

    // Creating the object for covergroup
    mon_cg = new();
  endfunction

  // Monitor task
  task start();
    mon_trans = new();
    repeat(5) @(vif.mon_cb);
    for (int i = 0; i < `no_of_trans; i++) begin
if(vif.mon_cb.CMD inside { 'd9, 'd10 } && vif.mon_cb.MODE)begin
  repeat(2) @(vif.mon_cb)
      begin
        mon_trans.RES   = vif.mon_cb.RES;
        mon_trans.OFLOW = vif.mon_cb.OFLOW;
        mon_trans.COUT  = vif.mon_cb.COUT;
        mon_trans.G     = vif.mon_cb.G;
        mon_trans.L     = vif.mon_cb.L;
        mon_trans.E     = vif.mon_cb.E;
        mon_trans.ERR   = vif.mon_cb.ERR;
      end

      $display("MONITOR PASSING THE DATA TO SCOREBOARD RES=%d, OFLOW=%d, COUT=%d, G=%d, L=%d, E=%d, ERR=%d ",
               mon_trans.RES, mon_trans.OFLOW, mon_trans.COUT, mon_trans.G, mon_trans.L, mon_trans.E, mon_trans.ERR, $time);
end


   else begin
   repeat(1) @(vif.mon_cb)
      begin
        mon_trans.RES   = vif.mon_cb.RES;
        mon_trans.OFLOW = vif.mon_cb.OFLOW;
        mon_trans.COUT  = vif.mon_cb.COUT;
        mon_trans.G     = vif.mon_cb.G;
        mon_trans.L     = vif.mon_cb.L;
        mon_trans.E     = vif.mon_cb.E;
        mon_trans.ERR   = vif.mon_cb.ERR;
      end


      $display("MONITOR PASSING THE DATA TO SCOREBOARD RES=%d, OFLOW=%d, COUT=%d, G=%d, L=%d, E=%d, ERR=%d @%0t",
               mon_trans.RES, mon_trans.OFLOW, mon_trans.COUT, mon_trans.G, mon_trans.L, mon_trans.E, mon_trans.ERR, $time);
end
      // Putting the collected outputs to mailbox
      mbx_ms.put(mon_trans);

      // Sampling the covergroup
      mon_cg.sample();
    $display("output coverage %d", mon_cg.get_coverage());
    end
  endtask

endclass
