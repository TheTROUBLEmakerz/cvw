// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

//controller + datapath

`include "parameters.svh"

module ieu(
        input   logic           clk, reset,
        input   logic           StallE, FlushE,
        input   logic [1:0]     ForwardAE, ForwardBE,
        input   logic [31:0]    InstrD, CSRout,
        input   logic [31:0]    PCD,
        output  logic           PCSrcE,
        output  logic [3:0]     WriteByteEn,
        input   logic           RegWriteW,
        input   logic [1:0]     ResultSrcW,
        input   logic [31:0]    IEUResultM, IEUResultW, ReadDataW,
        input   logic [4:0]     RdW,
        output  logic [31:0]    IEUAdrE, IEUResultE, FSrcBE,
        input   logic [31:0]    ReadData, CSRW,
        output  logic           MemRWE,
        output  logic           IsAdd, IsBranch, IsBranchTaken, IsJump, IsStore, IsLoad, IsLui, IsAuipc,
        output  logic [4:0]     RdE, Rs1E, Rs2E
    );

    logic [31:0]    Rd1D, Rd1E, Rd2D, Rd2E;
    logic RegWrite, Jump, Eq, ALUResultSrc, Lt, JumpE, BranchE;
    logic  [31:0] ImmExtD, ImmExtE, ResultW;
    logic  [1:0]  ResultSrc;
    logic  [1:0]  ALUSrc;
    logic  [2:0]  ImmSrcD;
    logic  [2:0]  Funct3E;
    logic  [1:0]  ALUControl;
    logic         IsMul, Funct7b5E;
    logic  [31:0] PCE;

    logic         RegWriteE, MemEn, ALUResultSrcE, JumpE;
    logic  [1:0]  ResultSrcE, ALUSrcE,ALUControlE;

    controller c(.JumpE, ,BranchE, .IEUAdr(IEUAdrE[1:0]), .Op(InstrD[6:0]), .Funct3(InstrD[14:12]), .Funct7b5(InstrD[30]), .Eq, .Lt,
        .ALUResultSrc, .ResultSrc, .WriteByteEn, .PCSrc(PCSrcE), .Funct7(InstrD[31:25]), .IsMul, .Jump,
        .ALUSrc, .RegWrite, .ImmSrc(ImmSrcD), .ALUControl, .MemEn, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc
    `ifdef DEBUG
        , .insn_debug(InstrD)
    `endif
    );

    // register file logic
    regfile rf(.reset, .clk, .WE3(RegWriteW), .A1(InstrD[19:15]), .A2(InstrD[24:20]),
        .A3(RdW), .WD3(ResultW), .RD1(Rd1D), .RD2(Rd2D));

    // immediate extend unit
    extend ext(.Instr(InstrD[31:7]), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));


    decodereg decodereg(.clk, .reset, .FlushE, .noStallE(~StallE), .RegWrite, .MemRW(MemEn), .ALUResultSrc, .Jump, .ALUControl, .ResultSrc, .ALUSrc, .PCD, .Rd1(Rd1D), .Rd2(Rd2D), .ImmExt(ImmExtD), .Funct3(InstrD[14:12]), .Funct7b5(InstrD[30]), .RdD(InstrD[11:7]), .Rs1D(InstrD[19:15]), .Rs2D(InstrD[24:20]),
                        .RegWriteE, .ResultSrcE, .MemRWE, .ALUResultSrcE, .JumpE, .ALUControlE, .ALUSrcE, .PCE, .Rd1E, .Rd2E, .ImmExtE, .Funct3E, .Funct7b5E, .RdE, .Rs1E, .Rs2E);

    datapath dp(.clk, .reset, .Rd1E, .Rd2E, .ImmExtE, .Funct3E, .Funct7b5E, .ALUControlE, .Eq, .Lt, .PCE, .IEUAdrE, .FSrcBE, .IEUResultE, .CSRout, .IsMul, .ALUResultSrcE, .JumpE, .ALUSrcE, .IEUResultM, .ResultW, .ForwardAE, .ForwardBE);
    mux3 #(32) resultmux(IEUResultW, ReadDataW, CSRW, ResultSrcW, ResultW);

endmodule
