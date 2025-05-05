`timescale 1ns / 1ps

import common::*;


module control(
    input clk,
    input reset_n,
    input instruction_type instruction, 
    output control_type control
);
    localparam logic [16:0] SLL_INSTRUCTION = {7'b0000000, 3'b001, 7'b0110011};
    localparam logic [16:0] SLLI_INSTRUCTION = {7'b0000000, 3'b001, 7'b0010011};
    localparam logic [16:0] SRL_INSTRUCTION = {7'b0000000, 3'b101, 7'b0110011};
    localparam logic [16:0] SRLI_INSTRUCTION = {7'b0000000, 3'b101, 7'b0010011};
    localparam logic [16:0] SRA_INSTRUCTION = {7'b0100000, 3'b101, 7'b0110011};
    localparam logic [16:0] SRAI_INSTRUCTION = {7'b0100000, 3'b101, 7'b0010011};

    localparam logic [16:0] ADD_INSTRUCTION = {7'b0000000, 3'b000, 7'b0110011};
    localparam logic [9:0] ADDI_INSTRUCTION = {3'b000, 7'b0010011};
    localparam logic [16:0] SUB_INSTRUCTION = {7'b0100000, 3'b000, 7'b0110011};
    localparam logic [6:0] LUI_INSTRUCTION = {7'b0110111};
    localparam logic [6:0] AUIPC_INSTRUCTION = {7'b0010111};

    localparam logic [16:0] XOR_INSTRUCTION = {7'b0000000, 3'b100, 7'b0110011};
    localparam logic [9:0] XORI_INSTRUCTION = {3'b100, 7'b0010011};
    localparam logic [16:0] OR_INSTRUCTION = {7'b0000000, 3'b110, 7'b0110011};
    localparam logic [9:0] ORI_INSTRUCTION = {3'b110, 7'b0010011};
    localparam logic [16:0] AND_INSTRUCTION = {7'b0000000, 3'b111, 7'b0110011};
    localparam logic [9:0] ANDI_INSTRUCTION = {3'b111, 7'b0010011};

    localparam logic [16:0] SLT_INSTRUCTION = {7'b0000000, 3'b010, 7'b0110011};
    localparam logic [9:0] SLTI_INSTRUCTION = {3'b010, 7'b0010011};
    localparam logic [16:0] SLTU_INSTRUCTION = {7'b0000000, 3'b011, 7'b0110011};
    localparam logic [9:0] SLTIU_INSTRUCTION = {3'b011, 7'b0010011};

    localparam logic [9:0] BEQ_INSTRUCTION = {3'b000, 7'b1100011};
    localparam logic [9:0] BNE_INSTRUCTION = {3'b001, 7'b1100011};
    localparam logic [9:0] BLT_INSTRUCTION = {3'b100, 7'b1100011};
    localparam logic [9:0] BGE_INSTRUCTION = {3'b101, 7'b1100011};
    localparam logic [9:0] BLTU_INSTRUCTION = {3'b110, 7'b1100011};
    localparam logic [9:0] BGEU_INSTRUCTION = {3'b111, 7'b1100011};

    localparam logic [9:0] JAL_INSTRUCTION = {3'b000, 7'b1101111};
    localparam logic [9:0] JALR_INSTRUCTION = {3'b000, 7'b1100111};

    localparam logic [9:0] LB_INSTRUCTION = {3'b000, 7'b0000011};
    localparam logic [9:0] LH_INSTRUCTION = {3'b001, 7'b0000011};
    localparam logic [9:0] LBU_INSTRUCTION = {3'b100, 7'b0000011};
    localparam logic [9:0] LHU_INSTRUCTION = {3'b101, 7'b0000011};
    localparam logic [9:0] LW_INSTRUCTION = {3'b010, 7'b0000011};


    localparam logic [9:0] SW_INSTRUCTION = {3'b010, 7'b0100011};
    localparam logic [9:0] SB_INSTRUCTION = {3'b000, 7'b0100011};
    localparam logic [9:0] SH_INSTRUCTION = {3'b001, 7'b0100011};
    
    
    always_comb begin
        control = '0;
        
        case (instruction.opcode)
            7'b0110011: begin//register calculation
                control.encoding = R_TYPE;
                control.reg_write = 1'b1;
            end
            
            7'b0000011: begin //load instructions
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;                
                control.mem_read = 1'b1;                
                control.mem_to_reg = 1'b1;                 
            end
            
            7'b0010011: begin//immediate calculation
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;              
            end
            
            7'b0100011: begin
                control.encoding = S_TYPE;
                control.alu_src = 1'b1;
                control.mem_write = 1'b1;                  
            end
            
            7'b1100011: begin
                control.encoding = B_TYPE;
                control.is_branch = 1'b1;            
            end

            7'b1101111: begin//JAL instruction
                control.encoding = J_TYPE;
                control.reg_write = 1'b1;
                control.is_branch = 1'b1;
            end

            7'b1100111: begin//JALR instruction
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.is_branch = 1'b1;
            end

            7'b0110111: begin//LUI instruction
                control.encoding = U_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;
            end

            7'b0010111: begin//AUIPC instruction
                control.encoding = U_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;
            end    

            default: begin
                control.encoding = I_TYPE;
                control.reg_write = 1'b0;
                control.alu_src = 1'b0;
                control.mem_read = 1'b0;
                control.mem_write = 1'b0;
                control.mem_to_reg = 1'b0;
                control.is_branch = 1'b0;                
            end

        endcase
        
        control.alu_op = ALU_ADD;

    // ============== R-type & Shift I-type (17 bits) ==============
    if ({instruction.funct7, instruction.funct3, instruction.opcode} == ADD_INSTRUCTION) begin
        control.alu_op = ALU_ADD;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SUB_INSTRUCTION) begin
        control.alu_op = ALU_SUB;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == AND_INSTRUCTION) begin
        control.alu_op = ALU_AND;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == OR_INSTRUCTION) begin
        control.alu_op = ALU_OR;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == XOR_INSTRUCTION) begin
        control.alu_op = ALU_XOR;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SLL_INSTRUCTION) begin
        control.alu_op = ALU_SLL;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SRL_INSTRUCTION) begin
        control.alu_op = ALU_SRL;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SRA_INSTRUCTION) begin
        control.alu_op = ALU_SRA;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SLT_INSTRUCTION) begin
        control.alu_op = ALU_SLT;
    end
    else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SLTU_INSTRUCTION) begin
        control.alu_op = ALU_SLTU;
    end

    // ============== I-type (普通算术逻辑，10 bits) ==============
    else if ({instruction.funct3, instruction.opcode} == ADDI_INSTRUCTION) begin
        control.alu_op = ALU_ADD;
    end
    else if ({instruction.funct3, instruction.opcode} == ANDI_INSTRUCTION) begin
        control.alu_op = ALU_AND;
    end
    else if ({instruction.funct3, instruction.opcode} == ORI_INSTRUCTION) begin
        control.alu_op = ALU_OR;
    end
    else if ({instruction.funct3, instruction.opcode} == XORI_INSTRUCTION) begin
        control.alu_op = ALU_XOR;
    end
    else if ({instruction.funct3, instruction.opcode} == SLTI_INSTRUCTION) begin
        control.alu_op = ALU_SLT;
    end
    else if ({instruction.funct3, instruction.opcode} == SLTIU_INSTRUCTION) begin
        control.alu_op = ALU_SLTU;
    end
    else if ({instruction.funct3, instruction.opcode} == LW_INSTRUCTION) begin
        control.alu_op = ALU_ADD; // address = base + offset
    end
    else if ({instruction.funct3, instruction.opcode} == LB_INSTRUCTION ||
             {instruction.funct3, instruction.opcode} == LH_INSTRUCTION ||
             {instruction.funct3, instruction.opcode} == LBU_INSTRUCTION||
             {instruction.funct3, instruction.opcode} == LHU_INSTRUCTION) begin
        control.alu_op = ALU_ADD; 
    end
    else if ({instruction.funct3, instruction.opcode} == SW_INSTRUCTION) begin
        control.alu_op = ALU_ADD;
    end
    else if ({instruction.funct3, instruction.opcode} == SB_INSTRUCTION ||
             {instruction.funct3, instruction.opcode} == SH_INSTRUCTION) begin
        control.alu_op = ALU_ADD;
    end

    // ============== Branch (10 bits) ==============
    else if ({instruction.funct3, instruction.opcode} == BEQ_INSTRUCTION) begin
        control.alu_op = ALU_SUB; // 用减法比较 zero
    end
    else if ({instruction.funct3, instruction.opcode} == BNE_INSTRUCTION ||
             {instruction.funct3, instruction.opcode} == BLT_INSTRUCTION ||
             {instruction.funct3, instruction.opcode} == BGE_INSTRUCTION ||
             {instruction.funct3, instruction.opcode} == BLTU_INSTRUCTION||
             {instruction.funct3, instruction.opcode} == BGEU_INSTRUCTION) begin
        control.alu_op = ALU_SUB; 
    end

    // ============== Jump / U-type ==============
    else if (instruction.opcode == JAL_INSTRUCTION) begin
        // PC + offset，常映射为 ALU_ADD（不过通常直接在取PC处加）
        control.alu_op = ALU_ADD; 
    end
    else if ({instruction.funct3, instruction.opcode} == JALR_INSTRUCTION) begin
        // rs1 + offset -> 也可视为 ALU_ADD
        control.alu_op = ALU_ADD;
    end
    else if (instruction.opcode == LUI_INSTRUCTION) begin
        // LUI: rd = imm << 12; 可在 ALU 中做 ALU_PASS_IMM 或简单用 ALU_PASS
        control.alu_op = ALU_PASS; 
    end
    else if (instruction.opcode == AUIPC_INSTRUCTION) begin
        // AUIPC: rd = PC + (imm << 12)，可当成 ALU_ADD
        control.alu_op = ALU_ADD;
    end


    end
    
endmodule
