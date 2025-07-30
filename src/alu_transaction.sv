
 `include "defines.sv"
class alu_transaction;

rand logic[`n-1:0]OPA, OPB;
rand logic CIN;
rand  logic MODE;
rand  logic CE ;
rand logic[`m-1:0]CMD;
rand logic[1:0]INP_VALID ;

logic ERR,OFLOW,COUT,G,L,E;
bit [`n:0] RES;
constraint c1{if(MODE==1) CMD inside {[0:10]}; else CMD inside {[0:13]};}
constraint c2{MODE dist{1:=5, 0:=5};}
constraint c3{INP_VALID inside{[0:3]};}
virtual function alu_transaction copy();
copy = new();
copy.OPA=this.OPA;
copy.OPB=this.OPB;
copy.CIN=this.CIN;
copy.CE = this.CE;
copy.MODE= this.MODE;
copy.CMD=this.CMD;
copy.INP_VALID=this.INP_VALID;
return copy;
endfunction
endclass

class alu_transaction1 extends alu_transaction;
        constraint mode {MODE == 0;}
        constraint cmd {CMD inside {[6:11]};}
        virtual function alu_transaction1 copy();
                copy = new();
                copy.CE = this.CE;
                copy.MODE = this.MODE;
                copy.CMD = this.CMD;
                copy.INP_VALID = this.INP_VALID;
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.CIN = this.CIN;
                return copy;

        endfunction
endclass

class alu_transaction2 extends alu_transaction;
        constraint mode {MODE == 1;}
        constraint cmd {CMD inside {[4:7]};}
        constraint inp_valid{INP_VALID == 2'b11;}
        virtual function alu_transaction2 copy();
                copy = new();
                copy.CE = this.CE;
                copy.MODE = this.MODE;
                copy.CMD = this.CMD;
                copy.INP_VALID = this.INP_VALID;
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.CIN = this.CIN;

                return copy;

endfunction

endclass


class alu_transaction3 extends alu_transaction;
constraint mode{MODE == 0;}
        constraint cmd {CMD inside {[0:6]};}
        constraint inp_valid {INP_VALID == 2'b11;}
        virtual function alu_transaction3 copy();
                copy = new();
                copy.CE = this.CE;
                copy.MODE = this.MODE;
                copy.CMD = this.CMD;
                copy.INP_VALID = this.INP_VALID;
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.CIN = this.CIN;
                return copy;
        endfunction
endclass
class alu_transaction4 extends alu_transaction;
        constraint mode{MODE == 1;}
        constraint cmd {CMD inside {[0:3], 8};}
        constraint inp_valid {INP_VALID == 2'b11;}
        virtual function alu_transaction4 copy();
                copy = new();
                  copy.CE = this.CE;
                copy.MODE = this.MODE;
                copy.CMD = this.CMD;
                copy.INP_VALID = this.INP_VALID;
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.CIN = this.CIN;
                return copy;
        endfunction

endclass






