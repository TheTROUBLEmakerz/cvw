// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

`include "parameters.svh"

module controller(
        input   logic [1:0]   IEUAdr,
        input   logic [6:0]   Op, Funct7,
        input   logic         Lt, Eq,
        input   logic [2:0]   Funct3, Funct3E,
        input   logic         MSB,
        output  logic         ALUResultSrc,
        output  logic [1:0]   ResultSrc,
        // output  logic [3:0]   WriteByteEn,
        // output  logic         PCSrc,
        output  logic         RegWrite,
        output  logic [1:0]   ALUSrc,
        output  logic [2:0]   ImmSrc,
        output  logic [1:0]   ALUControl,
        output  logic         MemEn,MemWrite, IsMul, IsZba, //IsZbs,
        output  logic         Jump, Branch,
        // output  logic         IsAdd, IsBranch, IsBranchTaken, IsJump, IsStore, IsLoad, IsLui, IsAuipc,
        // output  logic         IsMul,
        output  logic         BranchPr
        // input   logic         JumpE, BranchE
    `ifdef DEBUG
        , input   logic [31:0]  insn_debug
    `endif
    );
    logic Flag;

    logic Sub, ALUOp, IsZbs;
    logic [16:0] controls;


    assign BranchPr = (Op == 7'b1100011) && MSB;
    // Main decoder
    always_comb
        case(Op)
            // RegWrite_ImmSrc_ALUSrc_ALUOp_ALUResultSrc_MemWrite_ResultSrc_Branch_Jump_Load_IsMul_IsZba_IsZbb
            7'b0000011: controls = 17'b1_000_01_0_0_0_01_0_0_1_0_0_0; // lw
            7'b0100011: controls = 17'b0_001_01_0_0_1_00_0_0_1_0_0_0; // sw
            7'b0110011:
                case(Funct7)
                    7'b0000001: if(~Funct3[2]) controls = 17'b1_000_00_1_0_0_00_0_0_0_1_0_0; // Mul
                                else controls = 17'b1_000_00_1_0_0_00_0_0_0_0_0_0;
                    7'b0010000: controls = 17'b1_000_00_1_0_0_00_0_0_0_0_1_0; // Zba
                    //7'b0100100: controls = 17'b1_000_00_1_0_0_00_0_0_0_0_0_1;
                    //7'b0110100: controls = 17'b1_000_00_1_0_0_00_0_0_0_0_0_1;
                    //7'b0010100: controls = 17'b1_000_00_1_0_0_00_0_0_0_0_0_1;
                    7'b0000101: controls = 18'b1_000_00_1_10_0_00_0_0_0_0_0_1; // min / max
                        // for all the max/min --> comes from cmp unit appart from alu
                        // adding another input to the ALUResultMux - ALUResultSrc - 10
                    7'b0000100: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1; // zero ext.h
                        // ALUResultRrc - 11
                    7'b0100000: controls = 18'b1_000_00_1_00_0_00_0_0_0_0_0_1; // not - logic
                    7'b0110000: controls = 18'b1_000_00_1_00_0_00_0_0_0_0_0_1; // rotate
                    default: controls = 18'b1_000_00_1_00_0_00_0_0_0_0_0_0; // R-type
                endcase
            7'b0010011:
                case(Funct7)
                    //7'b0100100: controls = 17'b1_000_01_1_0_0_00_0_0_0_0_0_1;
                    //7'b0110100: controls = 17'b1_000_01_1_0_0_00_0_0_0_0_0_1;
                    //7'b0010100: controls = 17'b1_000_01_1_0_0_00_0_0_0_0_0_1;
                    7'b0010100: controls = 17'b1_000_01_1_0_0_00_0_0_0_0_0_1; // orc.b   TODO
                    7'b0110000: controls = 17'b1_000_01_1_0_0_00_0_0_0_0_0_1; // count / sign-ext / rotateRi TODO
                    7'b0110100: controls = 17'b1_000_01_1_0_0_00_0_0_0_0_0_1; // byte-wise rev TODO
                    default: controls = 17'b1_000_01_1_0_0_00_0_0_0_0_0_0; // I-type ALU
                endcase
            7'b1100011: controls = 17'b0_010_11_0_0_0_00_1_0_0_0_0_0; // b-type
            7'b1101111: controls = 17'b1_011_11_0_1_0_00_0_1_0_0_0_0; // jal
            7'b1100111: controls = 17'b1_000_01_0_1_0_00_0_1_0_0_0_0; // jalr
            7'b0110111: controls = 17'b1_111_00_0_0_0_10_0_0_0_0_0_0; // lui
            7'b0010111: controls = 17'b1_111_11_0_0_0_00_0_0_0_0_0_0; // auipc
            7'b1110011: controls = 17'b1_000_00_0_0_0_11_0_0_0_0_0_0; // CSR
            default: begin
                `ifdef DEBUG
                    controls = 17'bx_xxx_xx_x_x_x_xx_x_x_x_x_x_x; // non-implemented instruction
                    if ((insn_debug !== 'x)) begin
                        $display("Instruction not implemented: %h", insn_debug);
                        $finish(-1);
                    end
                `else
                    controls = 17'b0; // non-implemented instruction
                `endif
            end
        endcase

    assign {RegWrite, ImmSrc, ALUSrc, ALUOp, ALUResultSrc, MemWrite,
        ResultSrc, Branch, Jump, MemEn, IsMul, IsZba, IsZbs} = controls;

    // ALU Control Logic
    assign Sub = ALUOp & ~IsZba &
             ( (((Funct3 == 3'b000) & Funct7[5] & Op[5]))  // sub
               | (Funct3 == 3'b010)                      // slt
               | (Funct3 == 3'b011)                    // sltu//assign Sub = ALUOp & ((Funct3 == 3'b000) & Funct7[5] & Op[5]);
               | IsZbb & Funct7[5]);
    assign ALUControl = {Sub, ALUOp};

endmodule
