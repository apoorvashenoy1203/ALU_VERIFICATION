`include "alu_design.sv"
`include "alu_pkg.sv"
`include "alu_interface.sv"

  module top();
  import alu_pkg ::*;

  bit CLK = 0;
  bit RST;

  // Clock generation
  always #5 CLK = ~CLK;

  // Reset sequence
  initial begin
    RST = 1;
    repeat(2) @(posedge CLK);
    RST = 0;
  end

  // Interface instance
  alu_inf intrf(CLK, RST);

  ALU_DESIGN DUV (
    .OPA(intrf.OPA),
    .OPB(intrf.OPB),
    .CIN(intrf.CIN),
  .RST(intrf.RST),
.CLK(intrf.CLK),

    .CE(intrf.CE),
    .MODE(intrf.MODE),
    .INP_VALID(intrf.INP_VALID),
    .CMD(intrf.CMD),
    .RES(intrf.RES),
    .OFLOW(intrf.OFLOW),
    .COUT(intrf.COUT),
    .G(intrf.G),
    .L(intrf.L),
    .E(intrf.E),
    .ERR(intrf.ERR)
  );

  // Test instance
   alu_test tb= new(intrf.DRV,intrf.MON,intrf.REF_SB);
     test1 tb1= new(intrf.DRV,intrf.MON,intrf.REF_SB);
  test2 tb2= new(intrf.DRV,intrf.MON,intrf.REF_SB);
  test3 tb3= new(intrf.DRV,intrf.MON,intrf.REF_SB);
    test4 tb4= new(intrf.DRV,intrf.MON,intrf.REF_SB);
     test_regression tb_regression= new(intrf.DRV,intrf.MON,intrf.REF_SB);
  initial begin
   // tb = new(intrf, intrf, intrf );  // Pass the whole interface
tb_regression.run();
tb.run();
    $finish;
  end

endmodule

