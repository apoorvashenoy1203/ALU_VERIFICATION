
`include "defines.sv"
class alu_generator;
alu_transaction blueprint;
mailbox #(alu_transaction)mbx_gd;

function new(mailbox #(alu_transaction)mbx_gd);
 this.mbx_gd=mbx_gd;
 blueprint=new();
endfunction

task start();
for(int i=0; i<`no_of_trans; i++)
begin
  void'(blueprint.randomize());
  mbx_gd.put(blueprint.copy());
  $display("generator randomized transaction OPA = %d, OPB= %d, INP_VALID = %d, CMD = %d, CE =%d, CIN = %d", blueprint.OPA, blueprint.OPB, blueprint.INP_VALID, blueprint.CMD, blueprint.CE, blueprint.CIN, $time);
end
endtask
endclass

