
 `include "defines.sv"
class alu_scoreboard;

alu_transaction ref2sb_trans, mon2sb_trans;

mailbox #(alu_transaction) mbx_rs;
mailbox #(alu_transaction) mbx_ms;

int res_match, oflow_match,cout_match,g_match,l_match,e_match,err_match;
int res_mismatch,oflow_mismatch,cout_mismatch,g_mismatch,l_mismatch,e_mismatch,err_mismatch;
int overall_match, overall_mismatch;
function new(mailbox #(alu_transaction) mbx_rs,mailbox #(alu_transaction) mbx_ms);
        this.mbx_rs=mbx_rs;
        this.mbx_ms=mbx_ms;
endfunction

task start();
  for(int i=0; i<`no_of_trans; i++)
      begin
         ref2sb_trans=new();
         mon2sb_trans=new();
      fork
      begin
               mbx_rs.get(ref2sb_trans);
         $display("----------------------------------------------------------------------------------");

        $display("Reference model values at scoreboard @   %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,ref2sb_trans.OPA,ref2sb_trans.OPB,ref2sb_trans.CIN,ref2sb_trans.CE,ref2sb_trans.MODE,ref2sb_trans.CMD,ref2sb_trans.INP_VALID,ref2sb_trans.RES,ref2sb_trans.ERR,ref2sb_trans.OFLOW,ref2sb_trans.G,ref2sb_trans.L,ref2sb_trans.E);
         $display("----------------------------------------------------------------------------------");
      end
      begin
      mbx_ms.get(mon2sb_trans);
         $display("----------------------------------------------------------------------------------");

                  $display("Monitor values at scoreboard @ %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,mon2sb_trans.OPA,mon2sb_trans.OPB,mon2sb_trans.CIN,mon2sb_trans.CE,mon2sb_trans.MODE,mon2sb_trans.CMD,mon2sb_trans.INP_VALID,mon2sb_trans.RES,mon2sb_trans.ERR,mon2sb_trans.OFLOW,mon2sb_trans.G,mon2sb_trans.L,mon2sb_trans.E);
     $display("----------------------------------------------------------------------------------");

end
              join
      compare_report();
      end
endtask

task compare_report();
  #0;
begin
  fork
   begin
     if(mon2sb_trans.RES==ref2sb_trans.RES)
      begin
       res_match++;
        $display("Result Match SucCEssful: Monitor RES=%0d,Reference model RES=%0d",mon2sb_trans.RES,ref2sb_trans.RES);
      end
     else
       begin
        res_mismatch++;
         $display("Result Match Unsuccessful: Monitor RES=%0d,Reference model RES=%0d",mon2sb_trans.RES,ref2sb_trans.RES);
       end
   end

   begin
     if(mon2sb_trans.ERR==ref2sb_trans.ERR)
      begin
       err_match++;
        $display("Error Match Successful: Monitor ERR=%0d,Reference model ERR=%0d",mon2sb_trans.ERR,ref2sb_trans.ERR);
      end
     else
       begin
        err_mismatch++;
         $display("Error Match Unsuccessful: Monitor ERR=%0d,Reference model ERR=%0d",mon2sb_trans.ERR,ref2sb_trans.ERR);
       end
   end

   begin
     if(mon2sb_trans.COUT==ref2sb_trans.COUT)
      begin
       cout_match++;
        $display("Carry out Match Successful: Monitor COUT=%0d,Reference model COUT=%0d",mon2sb_trans.COUT,ref2sb_trans.COUT);
      end
     else
       begin
        cout_mismatch++;
         $display("Carry out Match Unsuccessful: Monitor COUT=%0d,Reference model COUT=%0d",mon2sb_trans.COUT,ref2sb_trans.COUT);
       end
   end

   begin
     if(mon2sb_trans.OFLOW==ref2sb_trans.OFLOW)
      begin
       oflow_match++;
        $display("Overflow Match Successful: Monitor OFLOW=%0d,Reference model OFLOW=%0d",mon2sb_trans.OFLOW,ref2sb_trans.OFLOW);
      end
     else
       begin
        oflow_mismatch++;
         $display("Overflow Match Unsuccessful: Monitor OFLOW=%0d,Reference model OFLOW=%0d",mon2sb_trans.OFLOW,ref2sb_trans.OFLOW);
       end
   end

   begin
     if(mon2sb_trans.G==ref2sb_trans.G)
      begin
       g_match++;
        $display("Greater Match Successful: Monitor G=%0d,Reference model G=%0d",mon2sb_trans.G,ref2sb_trans.G);
      end
     else
       begin
        g_mismatch++;
         $display("Greater Match Unsuccessful: Monitor G=%0d,Reference model G=%0d",mon2sb_trans.G,ref2sb_trans.G);
       end
   end

   begin
     if(mon2sb_trans.L==ref2sb_trans.L)
      begin
       l_match++;
        $display("Lesser Match Successful: Monitor L=%0d,Reference model L=%0d",mon2sb_trans.L,ref2sb_trans.L);
      end
     else
       begin
        l_mismatch++;
         $display("Lesser Match Unsuccessful: Monitor L=%0d,Reference model L=%0d",mon2sb_trans.L,ref2sb_trans.L);
       end
   end

   begin
     if(mon2sb_trans.E==ref2sb_trans.E)
      begin
       e_match++;
        $display("Equal Match Successful: Monitor E=%0d,Reference model E=%0d",mon2sb_trans.E,ref2sb_trans.E);
      end
     else
       begin
        e_mismatch++;
         $display("Equal Match Unsuccessful: Monitor E=%0d,Reference model E=%0d",mon2sb_trans.E,ref2sb_trans.E);
       end
   end
join

  if((mon2sb_trans.RES==ref2sb_trans.RES)&&(mon2sb_trans.ERR==ref2sb_trans.ERR)&&(mon2sb_trans.COUT==ref2sb_trans.COUT)&&(mon2sb_trans.OFLOW==ref2sb_trans.OFLOW)&&(mon2sb_trans.G==ref2sb_trans.G)&&(mon2sb_trans.L==ref2sb_trans.L)&&(mon2sb_trans.E==ref2sb_trans.E))
 begin
  overall_match++;
$display("----------------------------------------------------");
$display("----------------------------------------------------");
  $display("Overall Match Sucessfull %0d",overall_match);
$display("----------------------------------------------------");
$display("----------------------------------------------------");
 end
else
 begin
  overall_mismatch++;
$display("----------------------------------------------------");
  $display("Overall Match Unsucessfull %0d",overall_mismatch);
$display("------------------------------------------------------");
 end
$display("total match is %d",overall_match);
end

endtask

endclass

