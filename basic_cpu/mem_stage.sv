`timescale 1ns / 1ps

import common::*;


module mem_stage(
    input clk,
    input reset_n,
    input [31:0] alu_data_in,
    input [31:0] memory_data_in,
    input [2:0] func3,
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] memory_data_out,
    output logic [31:0] alu_data_out
);

logic [31:0] memory_data;
logic [7:0] load_byte;
logic [15:0] load_hword;



always_comb begin
    case(alu_data_in[1:0])
        2'b00: load_byte = memory_data[7:0];
        2'b01: load_byte = memory_data[15:8];
        2'b10: load_byte = memory_data[23:16];
        2'b11: load_byte = memory_data[31:24];
        default: load_byte = memory_data[7:0];
    endcase
    case(alu_data_in[1])
        1'b0: load_hword = memory_data[15:0];
        1'b1: load_hword = memory_data[31:16];
        default: load_hword = memory_data[31:16];
    endcase
end

always_comb begin
    case(func3)
	    F3_LB  : memory_data_out = {{(32-8) { load_byte  [7]}}, load_byte } ;  // Signed Load Byte
	    F3_LH  : memory_data_out = { { (32-16){load_hword[15]} }, load_hword} ;  // Signed Load Half-word
	    F3_LW  : memory_data_out = { memory_data } ;  // Signed Load Word
	    F3_LBU : memory_data_out = { { (32-8){1'b0} }, load_byte } ;  // Unsigned Load Byte
	    F3_LHU : memory_data_out = { { (32-16){1'b0} }, load_hword} ;  // Unsigned Load Half-word
	    default: memory_data_out = { memory_data } ;  // Signed Load Word
    endcase       

end
    data_memory inst_mem(
        .clk(clk),        
        .byte_address(alu_data_out[9:0]),
        .write_enable(control_in.mem_write),
        .write_data(memory_data_in),
        .read_data(memory_data)
    );
    

    assign alu_data_out = alu_data_in;    
    assign control_out = control_in;
    
endmodule
