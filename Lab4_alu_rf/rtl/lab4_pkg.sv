package lab4_pkg;

    // ALU operation codes
    typedef enum logic [5:0] {
        ALU_ADD = 6'b00_0010,
        ALU_SUB = 6'b00_0110,
        ALU_AND = 6'b00_0000,
        ALU_OR  = 6'b00_0001,
        ALU_XOR = 6'b00_1010,
        ALU_SLL = 6'b01_0000,
        ALU_SRL = 6'b10_0000,
        ALU_SRA = 6'b11_0000
    } alu_op_t;
endpackage
