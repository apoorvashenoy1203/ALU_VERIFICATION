 `include "defines.sv"
class alu_reference_model;

  mailbox #(alu_transaction) mbx_dr;
  mailbox #(alu_transaction) mbx_rs;

  alu_transaction trans;
  int temp_mult_res = 0;

  virtual alu_inf.REF_SB rf_inf;
  int waiting_for_16_cycles = 0;
  bit counter_16 = 0;
  int err_counter = 0;

  function new(mailbox #(alu_transaction) mbx_dr,
               mailbox #(alu_transaction) mbx_rs,
               virtual alu_inf.REF_SB rf_inf);
    this.mbx_dr = mbx_dr;
    this.mbx_rs = mbx_rs;
    this.rf_inf = rf_inf;
  endfunction

  function bit cycle_16_wait();
bit count;
count = (trans.INP_VALID == 2'b11) ||
         (trans.MODE && trans.INP_VALID == 2'b01 && trans.CMD inside {4,5}) ||
         (trans.INP_VALID == 2'b10 && trans.CMD inside {6,7}) ||
         (trans.MODE && trans.INP_VALID == 2'b01 && trans.CMD inside {6,8,10}) ||
         (trans.INP_VALID == 2'b10 && trans.CMD inside {7,9,11});

  if (count && (counter_16 <= 16))
    return 1;
  else
    return 0;
endfunction

  task start();
    trans = new();
    for (int i = 0; i < `no_of_trans; i++) begin
      mbx_dr.get(trans);
      if (rf_inf.ref_cb.RST == 1) begin
        trans.RES = 'bz;
        trans.OFLOW = 'bz;
        trans.COUT = 'bz;
        trans.G = 'bz;
        trans.L = 'bz;
        trans.E = 'bz;
        trans.ERR = 'bz;
        err_counter = 0;
      end else begin
        if (cycle_16_wait()) begin
          if (trans.CE) begin
            case (trans.INP_VALID)
              2'b01, 2'b10, 2'b11: begin
                if (trans.MODE == 1'b1) begin
                  case (trans.CMD)
                    `ADD:   begin
                      trans.RES = trans.OPA + trans.OPB;
                      trans.COUT = trans.RES[`n] ? 1 : 0;
                    end
                    `SUB: begin
                      trans.RES = trans.OPA - trans.OPB;
                      trans.OFLOW = (trans.OPA < trans.OPB) ? 1 : 0;
                    end
                    `ADD_CIN: begin
                      trans.RES = trans.OPA + trans.OPB + trans.CIN;
                      trans.COUT = trans.RES[`n] ? 1 : 0;
                    end
                    `SUB_CIN: begin
                      trans.RES = trans.OPA - trans.OPB - trans.CIN;
                      trans.OFLOW = (trans.OPA < trans.OPB) || ((trans.OPA - trans.OPB) < trans.CIN);
                    end
                    `INC_A: trans.RES = trans.OPA + 1;
                    `DEC_A: trans.RES = trans.OPA - 1;
                    `INC_B: trans.RES = trans.OPB + 1;
                    `DEC_B: trans.RES = trans.OPB - 1;
                    `CMP: begin
                      trans.E = (trans.OPA == trans.OPB);
                      trans.G = (trans.OPA > trans.OPB);
                      trans.L = (trans.OPA < trans.OPB);
                    end
                    `INC_MUL: trans.RES = (trans.OPA + 1) * (trans.OPB + 1);
                    `SHIFT_MUL: trans.RES = (trans.OPA << 1) * trans.OPB;
                    default: begin
                      trans.RES = 'bz;
                      trans.OFLOW = 'bz;
                      trans.COUT = 'bz;
                      trans.G = 'bz;
                      trans.L = 'bz;
                      trans.E = 'bz;
                      trans.ERR = 1'b1;
                    err_counter++;
                    end
                  endcase
                end else begin
                  case (trans.CMD)
                    `AND:  trans.RES = {1'b0, trans.OPA & trans.OPB};
                    `NAND: trans.RES = {1'b0, ~(trans.OPA & trans.OPB)};
                    `OR:   trans.RES = {1'b0, trans.OPA | trans.OPB};
                    `NOR:  trans.RES = {1'b0, ~(trans.OPA | trans.OPB)};
                    `XOR:  trans.RES = {1'b0, trans.OPA ^ trans.OPB};
                    `XNOR: trans.RES = {1'b0, ~(trans.OPA ^ trans.OPB)};
                    `NOT_A: trans.RES ={1'b0, ~trans.OPA};
                    `NOT_B: trans.RES ={1'b0, ~trans.OPB};
                    `SHR1_A: trans.RES ={1'b0, trans.OPA >> 1};
                    `SHL1_A: trans.RES = {1'b0,trans.OPA << 1};
                    `SHR1_B: trans.RES = {1'b0,trans.OPB >> 1};
                    `SHL1_B: trans.RES = {1'b0,trans.OPB << 1};
                    `ROR: begin
  if (trans.OPB >= `n) begin
    trans.RES = 0;
    trans.ERR = 1;
  end else begin
    trans.RES = {1'b0, ((trans.OPA >> trans.OPB) | (trans.OPA << (`n - trans.OPB))) & ((1 << `n) - 1)};
    trans.ERR = 0;
  end
end

`ROL: begin
  if (trans.OPB >= `n) begin
    trans.RES = 0;
    trans.ERR = 1;
  end else begin
    trans.RES = {1'b0, ((trans.OPA << trans.OPB) | (trans.OPA >> (`n - trans.OPB))) & ((1 << `n) - 1)};
    trans.ERR = 0;
  end
end

                    default: begin
                      trans.RES = 'bz;
                      trans.OFLOW = 'bz;
                      trans.COUT = 'bz;
                      trans.G = 'bz;
                      trans.L = 'bz;
                      trans.E = 'bz;
                      trans.ERR = 1'b1;

err_counter++;
                    end
                  endcase
                end
              end
              default: begin
                trans.RES = 0;
                trans.COUT = 0;
                trans.OFLOW = 0;
                trans.G = 0;
                trans.E = 0;
                trans.L = 0;
                trans.ERR = 1;
      err_counter++;
              end
            endcase
          end else begin
            trans.RES = 0;
            trans.COUT = 0;
            trans.OFLOW = 0;
            trans.G = 0;
            trans.E = 0;
            trans.L = 0;
            trans.ERR = 1;
err_counter++;
          end
        end
      end

      if (trans.MODE && trans.CMD inside {`INC_MUL, `SHIFT_MUL}) begin
        temp_mult_res = trans.RES;
        repeat (2) @(rf_inf.ref_cb);
        $display(" REFERENCE :  RES = [ %0d ] ", trans.RES, $time);
        trans.RES = temp_mult_res;
        mbx_rs.put(trans);
      end else begin
        @(rf_inf.ref_cb);
        mbx_rs.put(trans);
      end
 $display("[REF MODEL] Total Errors Detected: %0d", err_counter);
    end
  endtask

endclass

