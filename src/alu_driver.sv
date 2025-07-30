
`include "defines.sv"
class alu_driver;

  // Transaction object
  alu_transaction drv_trans;

  // Mailboxes
  mailbox #(alu_transaction) mbx_gd;
  mailbox #(alu_transaction) mbx_dr;

  // Virtual interface
  virtual alu_inf.DRV vif;
  int cmd_temp,mode_temp;
  int counter_16 = 0;
  bit waiting_for_16_cycles = 0;


  // Covergroup using the transaction handle
  covergroup c;
    INP_VALID : coverpoint drv_trans.INP_VALID { bins inp_valid[] = {0, 1, 2, 3}; }
    CMD       : coverpoint drv_trans.CMD       { bins cmd[]      = {[0:13]}; }
    CE        : coverpoint drv_trans.CE        { bins ce[]       = {0, 1}; }
    CIN       : coverpoint drv_trans.CIN       { bins cin[]      = {0, 1}; }
    MODE      : coverpoint drv_trans.MODE      { bins mode[]     = {0, 1}; }
    OPA_CP : coverpoint drv_trans.OPA {
     
      bins opa = {[0:`n]};
       }
    OPB_CP : coverpoint drv_trans.OPB {
    
      bins opb = {[0:`n]};
    }

    MODE_X_INP_V: cross MODE, INP_VALID;
    MODE_X_CMD: cross MODE, CMD;
    OPA_X_OPB : cross OPA_CP, OPB_CP;


  endgroup

  // Constructor
  function new(mailbox #(alu_transaction) mbx_gd,
               mailbox #(alu_transaction) mbx_dr,
               virtual alu_inf.DRV vif);
    this.mbx_gd = mbx_gd;
    this.mbx_dr = mbx_dr;
    this.vif = vif;
     this.c = new();
  endfunction

  function cycle_16_wait();
    if(drv_trans.INP_VALID ==2'b11)begin
      waiting_for_16_cycles=0;
      return 0;
    end
    else begin
      if(!(drv_trans.MODE && drv_trans.INP_VALID== 2'b01 && drv_trans.CMD inside {4, 5, 6, 7} || !drv_trans.MODE && drv_trans.INP_VALID ==2'b10 && drv_trans.CMD inside {6, 7, 8, 9, 10, 11}) && counter_16 <='d16) begin
        return 1;
      end
      else
        return 0;
    end
  endfunction
  function void drive_virtual_interface();
      vif.drv_cb.OPA        <= drv_trans.OPA;
      vif.drv_cb.OPB        <= drv_trans.OPB;
      vif.drv_cb.CIN        <= drv_trans.CIN;
      vif.drv_cb.MODE       <= drv_trans.MODE;
      vif.drv_cb.CMD        <= drv_trans.CMD;
      vif.drv_cb.INP_VALID  <= drv_trans.INP_VALID;
      vif.drv_cb.CE         <= drv_trans.CE;
    $display("driver OPA=%d, OPB=%d", drv_trans.OPA, drv_trans.OPB);
  endfunction

  task timing_control();
    if (drv_trans.MODE && (drv_trans.CMD inside {'d9, 'd10})) begin
      repeat(2) @(vif.drv_cb);
    end
    else begin
      @(vif.drv_cb);
    end
  endtask

  // Driver task
  task start();

    drv_trans = new();
    repeat(4) @(vif.drv_cb);
    for (int i = 0; i < `no_of_trans; i++) begin

      mbx_gd.get(drv_trans);
      c.sample();
    if(cycle_16_wait() && !waiting_for_16_cycles)begin
        waiting_for_16_cycles = 1;
        cmd_temp = drv_trans.CMD;
        mode_temp = drv_trans.MODE;
        counter_16 = 0;
      end


       if (waiting_for_16_cycles) begin
      vif.drv_cb.OPA        <= drv_trans.OPA;
      vif.drv_cb.OPB        <= drv_trans.OPB;
      vif.drv_cb.CIN        <= drv_trans.CIN;
      vif.drv_cb.MODE       <= mode_temp;
      vif.drv_cb.CMD        <= cmd_temp;
      vif.drv_cb.INP_VALID  <= drv_trans.INP_VALID;
      vif.drv_cb.CE         <= drv_trans.CE;

        drv_trans.CMD = cmd_temp;
        drv_trans.MODE = mode_temp;
        counter_16++;
        if (counter_16 >= 16) begin
          waiting_for_16_cycles = 0;
        end
      end
      else begin
        drive_virtual_interface();
      end

      timing_control();

       $display("Driver values to the interface : OPA=%0d, OPB=%0d, CIN=%0d, CE=%0d, MODE=%0d, CMD=%0d, INP_VALID=%0d",
               vif.drv_cb.OPA, vif.drv_cb.OPB, vif.drv_cb.CIN, vif.drv_cb.CE,
               vif.drv_cb.MODE, vif.drv_cb.CMD, vif.drv_cb.INP_VALID , $time);

      mbx_dr.put(drv_trans);
  $display("input coverage %d\n", c.get_coverage());

    end
  endtask

endclass
