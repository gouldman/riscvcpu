module forward_unit(
    input logic [4:0] id_ex_rs1,
    input logic [4:0] id_ex_rs2,
    input logic [4:0] ex_mem_rd,
    input logic [4:0] mem_wb_rd,
    input logic ex_mem_reg_write,
    input logic mem_wb_reg_write,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin
        // Default values for forward_a and forward_b
        forward_a = 2'b00; // No forwarding
        forward_b = 2'b00; // No forwarding

        // Check for forwarding from EX/MEM stage to ID/EX stage
        if(ex_mem_reg_write && id_ex_rs1 == ex_mem_rd) begin
                forward_a = 2'b10; // Forward from EX/MEM stage
        end else if(mem_wb_reg_write && id_ex_rs1 == mem_wb_rd) begin
                forward_a = 2'b01; // Forward from MEM/WB stage
        end

        if(ex_mem_reg_write && id_ex_rs2 == ex_mem_rd) begin
                forward_b = 2'b10; // Forward from EX/MEM stage
        end else if(mem_wb_reg_write && id_ex_rs2 == mem_wb_rd) begin
                forward_b = 2'b01; // Forward from MEM/WB stage
        end


    end

endmodule