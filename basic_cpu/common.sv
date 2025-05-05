package common;

   localparam [2:0] F3_ADDX  = 3'b000 ;
   localparam [2:0] F3_SUB   = 3'b000 ;
   localparam [2:0] F3_SLTX  = 3'b010 ;
   localparam [2:0] F3_SLTUX = 3'b011 ;
   localparam [2:0] F3_XORX  = 3'b100 ;
   localparam [2:0] F3_ORX   = 3'b110 ;
   localparam [2:0] F3_ANDX  = 3'b111 ;
   localparam [2:0] F3_SLLX  = 3'b001 ;
   localparam [2:0] F3_SRXX  = 3'b101 ;

   localparam [2:0] F3_JALR = 3'b000 ;
   localparam [2:0] F3_BEQ  = 3'b000 ;
   localparam [2:0] F3_BNE  = 3'b001 ;
   localparam [2:0] F3_BLT  = 3'b100 ;
   localparam [2:0] F3_BGE  = 3'b101 ;  
   localparam [2:0] F3_BLTU = 3'b110 ;
   localparam [2:0] F3_BGEU = 3'b111 ;

   localparam [2:0] F3_LB   = 3'b000 ;
   localparam [2:0] F3_LH   = 3'b001 ;
   localparam [2:0] F3_LW   = 3'b010 ;
   localparam [2:0] F3_LBU  = 3'b100 ;
   localparam [2:0] F3_LHU  = 3'b101 ;
   localparam [2:0] F3_SB   = 3'b000 ;
   localparam [2:0] F3_SH   = 3'b001 ;
   localparam [2:0] F3_SW   = 3'b010 ;

    typedef enum logic [3:0] 
    {
        ALU_ADD  = 4'b0000 , 
        ALU_SUB  = 4'b0001 , 
        ALU_SLT  = 4'b0100 , 
        ALU_SLTU = 4'b0110 , 
        ALU_XOR  = 4'b1000 , 
        ALU_OR   = 4'b1100 , 
        ALU_AND  = 4'b1110 , 
        ALU_SLL  = 4'b0010 , 
        ALU_SRL  = 4'b1010 , 
        ALU_SRA  = 4'b1011 , 
        ALU_PASS = 4'b1111 
    } alu_op_type;
    
    
    typedef enum logic [2:0]
    {
        R_TYPE,
        I_TYPE,
        S_TYPE,
        B_TYPE,
        U_TYPE,
        J_TYPE
    } encoding_type;
    
    
    typedef struct packed
    {
        alu_op_type alu_op;
        encoding_type encoding;
        logic alu_src;
        logic mem_read;
        logic mem_write;
        logic reg_write;
        logic mem_to_reg;
        logic is_branch;
    } control_type;

    
    typedef struct packed
    {
        logic [6:0] funct7;
        logic [4:0] rs2;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] rd;
        logic [6:0] opcode;
    } instruction_type;
    
        
    typedef struct  packed
    {
        logic [31:0] pc;
        instruction_type instruction;
    } if_id_type;
    
    
    typedef struct packed
    {
        logic [4:0] reg_rd_id;
        logic [4:0] rs1;
        logic [4:0] rs2;
        logic [31:0] data1;
        logic [31:0] data2;
        logic [31:0] immediate_data;
        logic [2:0] funct3;
        control_type control;
    } id_ex_type;
    

    typedef struct packed
    {
        logic [4:0] reg_rd_id;
        logic [2:0] funct3;
        control_type control;
        logic [31:0] alu_data;
        logic [31:0] memory_data;
        
    } ex_mem_type;
    
    
    typedef struct packed
    {
        logic [4:0] reg_rd_id;
        logic [31:0] memory_data;
        logic [31:0] alu_data;
        logic [2:0] funct3;
        control_type control;
    } mem_wb_type;


    function [31:0] immediate_extension(instruction_type instruction, encoding_type inst_encoding);
        case (inst_encoding)
            I_TYPE: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
            S_TYPE: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rd} };
            B_TYPE: immediate_extension = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
            U_TYPE: immediate_extension = { instruction[31:12], 12'b0 };
            J_TYPE: immediate_extension = { {11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0 };

            default: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
        endcase 
    endfunction
    
endpackage
