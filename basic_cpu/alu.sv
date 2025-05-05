`timescale 1ns / 1ps

import common::*;


module alu(
    input wire [3:0] control,
    input wire [31:0] left_operand, 
    input wire [31:0] right_operand,
    output logic zero_flag,
    output logic [31:0] result 
);

    always_comb begin
        case (control)
            ALU_ADD: result = left_operand + right_operand;
            ALU_SUB: result = left_operand - right_operand;
            ALU_SLT: result = {{31{1'b0}}, signed'(left_operand) < signed'(right_operand)}; //set_less_than
            ALU_SLTU: result = {{31{1'b0}}, (left_operand) < (right_operand)}; // set less than unsigned
            ALU_XOR: result = left_operand ^ right_operand;
            ALU_OR: result = left_operand | right_operand;
            ALU_AND: result = left_operand & right_operand;
            ALU_SLL: result = left_operand << right_operand[4:0]; //shift left logical
            ALU_SRL: result = left_operand >> right_operand[4:0]; //shift right logical
            ALU_SRA: result = $signed(left_operand) >>> right_operand[4:0]; //shift right arithmetic
            ALU_PASS: result = left_operand; 
            default: result = left_operand + right_operand;
        endcase
    end
    
    
    assign zero_flag = 1'b1 ? result == 0 : 1'b0;

endmodule
