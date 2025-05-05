`timescale 1ns / 1ps

import common::*;

module hazard_detect_unit(
    input if_id_type if_id_reg,
    input id_ex_type id_ex_reg,
    output logic hazard
);

always_comb begin
    if(id_ex_reg.control.mem_read && ((id_ex_reg.reg_rd_id == if_id_reg.instruction.rs1) || (id_ex_reg.reg_rd_id == if_id_reg.instruction.rs2)))
        hazard = 1;
    else    
        hazard = 0;

end
endmodule