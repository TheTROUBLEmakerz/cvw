// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

`include "parameters.svh"

module controller(
        input   logic [1:0]   IEUAdr,
        input   logic [6:0]   Op, Funct7,
        input   logic         Lt, Eq,
        input   logic [4:0]   Immbits,
        input   logic [2:0]   Funct3, Funct3E,
        input   logic         MSB,
        output  logic [1:0]   ALUResultSrc, ResultSrc,
        // output  logic [3:0]   WriteByteEn,
        // output  logic         PCSrc,
        output  logic         RegWrite,
        output  logic [1:0]   ALUSrc,
        output  logic [2:0]   ImmSrc,
        output  logic [1:0]   ALUControl,
        output  logic         MemEn,MemWrite, IsMul, IsZba, IsZbb,
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
    logic [17:0] controls;


    assign BranchPr = (Op == 7'b1100011) && MSB;
    // Main decoder
    always_comb
        case(Op)
            // RegWrite_ImmSrc_ALUSrc_ALUOp_ALUResultSrc_MemWrite_ResultSrc_Branch_Jump_Load_IsMul_IsZba_IsZbb
            7'b0000011: controls = 18'b1_000_01_0_00_0_01_0_0_1_0_0_0; // lw
            7'b0100011: controls = 18'b0_001_01_0_00_1_00_0_0_1_0_0_0; // sw
            7'b0110011:
                case ({Funct7, Funct3})
                    {7'b0000001, 3'b000},
                    {7'b0000001, 3'b001},
                    {7'b0000001, 3'b010},
                    {7'b0000001, 3'b011}: controls = 18'b1_000_00_1_00_0_00_0_0_0_1_0_0; // mul group

                    {7'b0010000, 3'b010},
                    {7'b0010000, 3'b100},
                    {7'b0010000, 3'b110}: controls = 18'b1_000_00_1_00_0_00_0_0_0_0_1_0; // Zba

                    {7'b0000101, 3'b100},
                    {7'b0000101, 3'b101},
                    {7'b0000101, 3'b110},
                    {7'b0000101, 3'b111}: controls = 18'b1_000_00_1_10_0_00_0_0_0_0_0_1; // min/max

                    {7'b0100000, 3'b100},
                    {7'b0100000, 3'b110},
                    {7'b0100000, 3'b111}: controls = 18'b1_000_00_1_00_0_00_0_0_0_0_0_1; // xnor/orn/andn

                    // rol
                    {7'b0110000, 3'b001}: controls = 18'b1_000_00_1_00_0_00_0_0_0_0_0_1;

                    // ror
                    {7'b0110000, 3'b101}: controls = 18'b1_000_00_1_00_0_00_0_0_0_0_0_1;

                    //zexth
                    {7'b0000100, 3'b100}: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1;

                    default: controls = 18'b1_000_00_1_00_0_00_0_0_0_0_0_0; // normal R-type, including sub
                endcase
            7'b0010011:
                casez ({Funct7, Funct3})
                    {7'b0010100, 3'b101}: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1; // orc.b
                    {7'b0110100, 3'b101}: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1; // rev8
                    {7'b0110000, 3'b101}: controls = 18'b1_000_01_1_00_0_00_0_0_0_0_0_1; // rori
                    {7'b0110000, 3'b001}: begin
                        case (Immbits)
                            5'b00000: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1; // clz
                            5'b00001: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1; // ctz
                            5'b00010: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1; // cpop
                            5'b00100: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1; // sextb
                            5'b00101: controls = 18'b1_000_01_1_11_0_00_0_0_0_0_0_1; // sexth
                            default:  controls = 18'b1_000_01_1_00_0_00_0_0_0_0_0_1;
                        endcase
                    end
                    default:              controls = 18'b1_000_01_1_00_0_00_0_0_0_0_0_0; // normal I-type ALU
                endcase
            7'b1100011: controls = 18'b0_010_11_0_00_0_00_1_0_0_0_0_0; // b-type
            7'b1101111: controls = 18'b1_011_11_0_01_0_00_0_1_0_0_0_0; // jal
            7'b1100111: controls = 18'b1_000_01_0_01_0_00_0_1_0_0_0_0; // jalr
            7'b0110111: controls = 18'b1_111_00_0_00_0_10_0_0_0_0_0_0; // lui
            7'b0010111: controls = 18'b1_111_11_0_00_0_00_0_0_0_0_0_0; // auipc
            7'b1110011: controls = 18'b1_000_00_0_00_0_11_0_0_0_0_0_0; // CSR
            default: begin
                `ifdef DEBUG
                    controls = 18'bx_xxx_xx_x_xx_x_xx_x_x_x_x_x_x; // non-implemented instruction
                    if ((insn_debug !== 'x)) begin
                        $display("Instruction not implemented: %h", insn_debug);
                        $finish(-1);
                    end
                `else
                    controls = 18'b0; // non-implemented instruction
                `endif
            end
        endcase

    assign {RegWrite, ImmSrc, ALUSrc, ALUOp, ALUResultSrc, MemWrite,
        ResultSrc, Branch, Jump, MemEn, IsMul, IsZba, IsZbb} = controls;

    // ALU Control Logic
    assign Sub = ALUOp & ~IsZba &
             ( (((Funct3 == 3'b000) & Funct7[5] & Op[5]))  // sub
               | (Funct3 == 3'b010)                      // slt
               | (Funct3 == 3'b011)                    // sltu//assign Sub = ALUOp & ((Funct3 == 3'b000) & Funct7[5] & Op[5]);
               | IsZbb & Funct7[5]);
    assign ALUControl = {Sub, ALUOp};

endmodule
