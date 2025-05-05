`timescale 1ns / 1ps

import common::*;


module execute_stage(
    input clk,
    input reset_n,
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] immediate_data,
    input [1:0] forward_a,
    input [1:0] forward_b,
    input [31:0] fwd_data_ex_mem,
    input [31:0] fwd_data_mem_wb,
    input [2:0] func3,
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data
);

    logic zero_flag;
    
    logic [31:0] left_operand;
    logic [31:0] right_operand;
    logic [31:0] rs2_data;
    
    logic [31:0] memory_SB_data;
    logic [31:0] memory_SH_data;
     
    always_comb begin: operand_selector
        left_operand = data1;
        right_operand = data2;
        rs2_data = data2;
        if(forward_b == 2'b10) begin
            rs2_data = fwd_data_ex_mem;
        end else if (forward_b == 2'b01) begin
            rs2_data = fwd_data_mem_wb;
         end    
        if (control_in.alu_src) begin
            right_operand = immediate_data;
        end else begin
            right_operand = rs2_data;
        end
        if(forward_a == 2'b10) begin
            left_operand = fwd_data_ex_mem;
        end else if (forward_a == 2'b01) begin
            left_operand = fwd_data_mem_wb;
        end        
    end
    
    
    alu inst_alu(
        .control(control_in.alu_op),
        .left_operand(left_operand), 
        .right_operand(right_operand),
        .zero_flag(zero_flag),
        .result(alu_data)
    );

        
    
    assign control_out = control_in;
//handle sw, sh and sb

    always_comb begin
        case(alu_data[1:0]) 
            2'b00: memory_SB_data = {{8'b00},{8'b00},{8'b00},rs2_data[7:0]};
            2'b01: memory_SB_data = {{8'b00},{8'b00},rs2_data[7:0],{8'b00}};
            2'b10: memory_SB_data = {{8'b00},rs2_data[7:0],{8'b00},{8'b00}};
            2'b11: memory_SB_data = {rs2_data[7:0],{8'b00},{8'b00},{8'b00}};
            default: memory_SB_data = {{8'b00},{8'b00},{8'b00},rs2_data[7:0]};
        endcase
        case(alu_data[1]) 
            1'b0: memory_SH_data = {{16'b0}, rs2_data[15:0]};
            1'b1: memory_SH_data = {rs2_data[15:0], {16'b0}};
            default: memory_SH_data = {{16'b0}, rs2_data[15:0]};
        endcase
    end

    always_comb begin
        case(func3)
            F3_SB: memory_data = memory_SB_data;
            F3_SH: memory_data = memory_SH_data;
            F3_SW: memory_data = rs2_data;
            default: memory_data = rs2_data;
        endcase
    end

    
endmodule
