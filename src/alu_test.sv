  class alu_test;
//PROPERTIES
  //virtual interfaces for drivEr, monitor and rEfErEnCE MODEL
  virtual alu_inf drv_vif;
  virtual alu_inf mon_vif;
  virtual alu_inf ref_vif;
  //DEcLarinG handLE for EnvironmEnt
  alu_environment env;

  //ExpLicitLy ovERRidinG thE constructor to connEct thE virtual interfaces
  //from drivEr, monitor and refErEnCE MODEL to test
  function new(virtual alu_inf drv_vif,
               virtual alu_inf mon_vif,
               virtual alu_inf ref_vif);
    this.drv_vif=drv_vif;
    this.mon_vif=mon_vif;
    this.ref_vif=ref_vif;
 endfunction



  task run();
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    env.start;
  endtask
endclass


class test1  extends alu_test;
 alu_transaction1 trans1;
  function new(virtual alu_inf drv_vif,virtual alu_inf mon_vif,virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
    trans1 = new();
    env.gen.blueprint= trans1;
    end
    env.start;
  endtask
endclass


class test2  extends alu_test;
 alu_transaction2 trans2;
  function new(virtual alu_inf drv_vif,virtual alu_inf mon_vif,virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
    trans2 = new();
    env.gen.blueprint= trans2;
    end
    env.start;
  endtask
endclass


  class test3  extends alu_test;
 alu_transaction3 trans3;
  function new(virtual alu_inf drv_vif,virtual alu_inf mon_vif,virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
    trans3 = new();
    env.gen.blueprint= trans3;
    end
    env.start;
  endtask
endclass


  class test4  extends alu_test;
 alu_transaction4 trans4;
  function new(virtual alu_inf drv_vif,virtual alu_inf mon_vif,virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
    begin
    trans4 = new();
    env.gen.blueprint= trans4;
    end
endtask
endclass


class test_regression extends alu_test;
 alu_transaction1  trans1;
 alu_transaction2 trans2;
 alu_transaction3 trans3;
 alu_transaction4 trans4;
  function new(virtual alu_inf drv_vif,virtual alu_inf mon_vif,virtual alu_inf ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env=new(drv_vif,mon_vif,ref_vif);
    env.build;
///////////////////////////////////////////////////////
    begin
    trans1 = new();
    env.gen.blueprint= trans1;
    end
    env.start;

///////////////////////////////////////////////////////
    begin
    trans2 = new();
    env.gen.blueprint= trans2;
    end
    env.start;

///////////////////////////////////////////////////////
    begin
    trans3 = new();
    env.gen.blueprint= trans3;
    end
    env.start;

///////////////////////////////////////////////////////
    begin
    trans4 = new();
    env.gen.blueprint= trans4;
    end
    env.start;
//////////////////////////////////////////////////////

  endtask
endclass
