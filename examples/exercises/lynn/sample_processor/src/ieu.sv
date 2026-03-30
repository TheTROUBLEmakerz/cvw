// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

//controller + datapath

`include "parameters.svh"

module ieu(
        input   logic           clk, reset,
        input   logic           StallE, FlushE,
        input   logic           ForwardAE, ForwardBE,
        input   logic [31:0]    InstrD, CSRout,
        input   logic [31:0]    PCD,
        output  logic           PCSrc,
        output  logic [3:0]     WriteByteEn,
        input   logic           RegWriteW,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData,
        output  logic           MemEn,
        output  logic           IsAdd, IsBranch, IsBranchTaken, IsJump, IsStore, IsLoad, IsLui, IsAuipc
    );


    logic RegWrite, Jump, Eq, ALUResultSrc, Lt;
    logic  [31:0] ImmExtD;
    logic  [1:0]  ResultSrc;
    logic  [1:0]  ALUSrc;
    logic  [2:0]  ImmSrcD;
    logic  [1:0]  ALUControl;
    logic         IsMul;

    logic         RegWriteE, MemRWE, ALUResultSrcE, JumpE, ALUControlE;
    logic  [1:0]  ResultSrcE, ALUSrcE;

    controller c(.IEUAdr(IEUAdr[1:0]), .Op(InstrD[6:0]), .Funct3(InstrD[14:12]), .Funct7b5(InstrD[30]), .Eq, .Lt,
        .ALUResultSrc, .ResultSrc, .WriteByteEn, .PCSrc, .Funct7(InstrD[31:25]), .IsMul,
        .ALUSrc, .RegWrite, .ImmSrc(ImmSrcD), .ALUControl, .MemEn, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc
    `ifdef DEBUG
        , .insn_debug(Instr)
    `endif
    );

    // register file logic
    regfile rf(.reset, .clk, .WE3(RegWriteW), .A1(InstrD[19:15]), .A2(InstrD[24:20]),
        .A3(InstrD[11:7]), .WD3(Result), .RD1(R1), .RD2(R2));

    // immediate extend unit
    extend ext(.Instr(InstrD[31:7]), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));

    decodereg decodereg(.clk, .reset, .FlushE, .noStallE, .RegWrite, .MemRW, .ALUResultSrc, .Jump, .ALUControl, .ResultSrc, .ALUSrc, .PCD, .Rd1, .Rd2, .ImmExtD, .Funct3, .RdD,
                        .RegWriteE, .ResultSrcE, .MemRWE, .ALUResultSrcE, .JumpE, .ALUControlE, .ALUSrcE, .PCE, .Rd1E, .Rd2E, .ImmExtE, .Funct3E, .RdE);

    datapath dp(.clk, .reset, .Funct3(Instr[14:12]),
        .ALUResultSrc, .ResultSrc, .ALUSrc, .RegWrite, .ImmSrc, .ALUControl, .Eq, .Lt, .IsMul,
        .PC, .PCPlus4, .Instr, .IEUAdr, .WriteData, .ReadData, .CSRout);
endmodule
