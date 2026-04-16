// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

//controller + datapath

`include "parameters.svh"

module ieu(
        input   logic           clk, reset,
        input   logic           StallE, FlushE, ValidD,
        input   logic [1:0]     ForwardAE, ForwardBE,
        input   logic [31:0]    InstrD, CSRout,
        input   logic [31:0]    PCD,
        output  logic           PCSrcE,
        output  logic [3:0]     WriteByteEnE,
        input   logic           RegWriteW, IsMulW,
        // input   logic [1:0]     ResultSrcW,
        input   logic [31:0]    ResultM, ResultW, // ReadDataW,
        input   logic [4:0]     RdW,
        output  logic [31:0]    IEUAdrE, IEUResultE,
        // input   logic [31:0]    ReadData, CSRW, ImmExtW, MulResultW,
        output  logic [31:0]    CSRE,ImmExtE,
        output  logic           MemRWE, RegWriteE, ValidE, IsMulE,
        // output  logic           IsAdd, IsBranch, IsBranchTaken, IsJump, IsStore, IsLoad, IsLui, IsAuipc,
        output  logic [4:0]     RdE, Rs1E, Rs2E,
        output  logic [2:0]     Funct3E,
        output  logic [1:0]     ResultSrcE,
        output  logic [31:0]    FSrcBE, FSrcAE
    );
    logic [31:0]    Rd1D, Rd1E, Rd2D, Rd2E;
    logic RegWrite, Jump, Branch, Eq, ALUResultSrc, Lt, JumpE, BranchE, IsMul;
    logic  [31:0] ImmExtD; // , extout;
    logic  [1:0]  ResultSrc;
    logic  [1:0]  ALUSrc;
    logic  [2:0]  ImmSrcD;
    logic  [1:0]  ALUControl;
    logic         Funct7b5E, MemWrite, MemWriteE, Flag; //IsMul,
    logic  [31:0] PCE;

    logic         MemEn, ALUResultSrcE;
    logic  [1:0]  ALUSrcE,ALUControlE;

    controller c(.JumpE, .BranchE, .IEUAdr(IEUAdrE[1:0]), .Op(InstrD[6:0]), .Funct3(InstrD[14:12]), .Funct7b5(InstrD[30]), .Eq, .Lt,
        .ALUResultSrc, .ResultSrc, .Funct7(InstrD[31:25]), .Jump, .Branch, .Funct3E, .MemWrite, // .WriteByteEn,
        .ALUSrc, .RegWrite, .ImmSrc(ImmSrcD), .ALUControl, .MemEn, .IsMul //, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsMul, .IsStore, .IsLoad, .IsLui, .IsAuipc
    `ifdef DEBUG
        , .insn_debug(InstrD)
    `endif
    );

    // register file logic
    regfile rf(.reset, .clk, .WE3(RegWriteW), .A1(InstrD[19:15]), .A2(InstrD[24:20]),
        .A3(RdW), .WD3(ResultW), .RD1(Rd1D), .RD2(Rd2D));

    // immediate extend unit
    extend ext(.Instr(InstrD[31:7]), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));


    decodereg decodereg(.BranchE, .Branch, .clk, .reset, .FlushE, .noStallE(~StallE), .RegWrite, .MemRW(MemEn), .ALUResultSrc, .Jump, .ALUControl, .ResultSrc, .ALUSrc, .PCD, .Rd1(Rd1D), .Rd2(Rd2D), .ImmExt(ImmExtD), .Funct3(InstrD[14:12]), .Funct7b5(InstrD[30]), .RdD(InstrD[11:7]), .Rs1D(InstrD[19:15]), .Rs2D(InstrD[24:20]),
                        .RegWriteE, .MemWrite, .MemWriteE, .ResultSrcE, .MemRWE, .ALUResultSrcE, .JumpE, .ALUControlE, .ALUSrcE, .PCE, .Rd1E, .Rd2E, .ImmExtE, .Funct3E, .Funct7b5E, .RdE, .Rs1E, .Rs2E, .CSRD(CSRout), .CSRE, .ValidD, .ValidE, .IsMul, .IsMulE);

    datapath dp(.clk, .reset, .Rd1E, .Rd2E, .ImmExtE, .Funct3E, .Funct7b5E, .ALUControlE, .Eq, .Lt, .PCE, .IEUAdrE, .FSrcAE, .FSrcBE, .IEUResultE, .ALUResultSrcE, .JumpE, .ALUSrcE, .ResultM, .ResultW, .ForwardAE, .ForwardBE); //IsMul,
    // mux2 #(32) extmux(IEUResultW, MulResultW, IsMulW, extout);
    // mux4 #(32) resultmux(ResultW, ReadDataW, ImmExtW, CSRW, ResultSrcW, ResultW);

    always_comb begin
        WriteByteEnE = 4'b0000;

        if (MemWriteE === 1'b1) begin
            casez ({Funct3E[1:0], IEUAdrE[1:0]})
                4'b10_??: WriteByteEnE = 4'b1111; // sw
                4'b01_0?: WriteByteEnE = 4'b0011; // sh
                4'b01_1?: WriteByteEnE = 4'b1100;
                4'b00_00: WriteByteEnE = 4'b0001; // sb
                4'b00_01: WriteByteEnE = 4'b0010;
                4'b00_10: WriteByteEnE = 4'b0100;
                4'b00_11: WriteByteEnE = 4'b1000;
                default: WriteByteEnE = 4'b0;
            endcase
        end
    end
    always_comb
    begin
        case(Funct3E[2:1])
            2'b00: Flag = (Funct3E[0] ^ Eq);
            2'b10: Flag = (Funct3E[0] ^ Lt);
            2'b11: Flag = (Funct3E[0] ^ Lt);
            default: Flag = 0;
        endcase
    end
    assign PCSrcE = (BranchE & Flag) | JumpE;
endmodule
