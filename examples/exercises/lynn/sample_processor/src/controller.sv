// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

`include "parameters.svh"

module controller(
        input   logic [1:0]   IEUAdr,
        input   logic [6:0]   Op, Funct7,
        input   logic         Lt, Eq,
        input   logic [2:0]   Funct3, Funct3E,
        input   logic         Funct7b5,
        output  logic         ALUResultSrc,
        output  logic [1:0]   ResultSrc,
        output  logic         RegWrite,
        output  logic [1:0]   ALUSrc,
        output  logic [2:0]   ImmSrc,
        output  logic [1:0]   ALUControl,
        output  logic         MemEn,MemWrite,
        output  logic         Jump, Branch,
        output  logic         IsMul,
        input   logic         JumpE, BranchE
    `ifdef DEBUG
        , input   logic [31:0]  insn_debug
    `endif
    );
    logic Flag;
    logic Sub, ALUOp;
    logic [13:0] controls;

    // Main decoder
    always_comb
        case(Op)
            // RegWrite_ImmSrc_ALUSrc_ALUOp_ALUResultSrc_MemWrite_ResultSrc_Branch_Jump_Load
            7'b0000011: controls = 14'b1_000_01_0_0_0_01_0_0_1; // lw
            7'b0100011: controls = 14'b0_001_01_0_0_1_00_0_0_1; // sw
            7'b0110011: controls = 14'b1_000_00_1_0_0_00_0_0_0; // R-type
            7'b0010011: controls = 14'b1_000_01_1_0_0_00_0_0_0; // I-type ALU
            7'b1100011: controls = 14'b0_010_11_0_0_0_00_1_0_0; // b-type
            7'b1101111: controls = 14'b1_011_11_0_1_0_00_0_1_0; // jal
            7'b1100111: controls = 14'b1_000_01_0_1_0_00_0_1_0; // jalr
            7'b0110111: controls = 14'b1_111_00_0_0_0_10_0_0_0; // lui
            7'b0010111: controls = 14'b1_111_11_0_0_0_00_0_0_0; // auipc
            7'b1110011: controls = 14'b1_000_00_0_0_0_11_0_0_0; // CSR
            default: begin
                `ifdef DEBUG
                    controls = 14'bx_xxx_xx_x_x_x_xx_x_x_x; // non-implemented instruction
                    if ((insn_debug !== 'x)) begin
                        $display("Instruction not implemented: %h", insn_debug);
                        $finish(-1);
                    end
                `else
                    controls = 14'b0; // non-implemented instruction
                `endif
            end
        endcase

    assign {RegWrite, ImmSrc, ALUSrc, ALUOp, ALUResultSrc, MemWrite,
        ResultSrc, Branch, Jump, MemEn} = controls;

    // ALU Control Logic
    assign Sub = ALUOp &
             ( (((Funct3 == 3'b000) & Funct7b5 & Op[5]))  // sub
               | (Funct3 == 3'b010)                      // slt
               | (Funct3 == 3'b011) );                   // sltu//assign Sub = ALUOp & ((Funct3 == 3'b000) & Funct7b5 & Op[5]);
    assign ALUControl = {Sub, ALUOp};

    always_comb begin
        if (Op    === 7'b0110011 && Funct7=== 7'b0000001 && Funct3[2] === 1'b0)
            IsMul = 1'b1;
        else
            IsMul = 1'b0;
    end
endmodule
