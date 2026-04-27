// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

`include "parameters.svh"

module riscvsingle (
        input   logic           clk,
        input   logic           reset,

        output  logic [31:0]    PC,
        input   logic [31:0]    Instr,

        output  logic [31:0]    IEUAdr,
        input   logic [31:0]    ReadData,
        output  logic [31:0]    WriteData,

        output  logic           MemEn,
        output  logic           WriteEn,
        output  logic [3:0]     WriteByteEn
    );

    logic [31:0] CSRout, PCE, extout;
    logic PCSrcE, MemRWE, BranchPrD, MisPredictE;
    logic [31:0] PCD;
    logic [31:0] InstrD;
    logic [31:0] IEUAdrE, IEUResultE, IEUResultW, ReadDataW;
    logic StallF, FlushD, StallD, FlushE, StallE, FlushM, StallM, FlushW, StallW, IsMul, IsMulE, IsMulW;
    logic [1:0] ForwardAE, ForwardBE;
    logic RegWriteW, RegWriteM, RegWriteE, ValidE, ValidW, InsnRetired;
    logic [1:0] ResultSrcM, ResultSrcE, ResultSrcW;
    logic [4:0] RdW, RdE, RdM, Rs1E, Rs2E;
    logic [31:0] FSrcAE, FSrcBE, ImmExtE, ImmExtW, ImmExtD, MulResult, MulResultW, PCLinkE;
    logic [2:0] Funct3M, Funct3E;
    logic [3:0] WriteByteEnE;
    logic [11:0] CSRAddressE, CSRAddressW;

    ifu ifu(.clk, .reset, .PCSrcE, .IEUAdrE, .PC, .PCLinkE, .StallF, .BranchPr(BranchPrD), .MisPredictE, .PCD, .ImmExtD);
    ieu ieu(.clk, .reset, .StallE, .StallD, .FlushD, .Instr, .PC, .PCD, .IsMulE, .PCLinkE, .ImmExtD, .ImmExtE, .FlushE, .ForwardAE, .ForwardBE, .CSRout, .PCSrcE,
            .WriteByteEnE, .RegWriteW, .ResultSrcW, .extout, .IEUResultW, .ReadDataW, .RdW, .IEUAdrE, .IEUResultE, .ReadData, .MemRWE, .FSrcAE, .FSrcBE,
            .RdE, .Rs2E, .Rs1E, .Funct3E, .MulResultW, .IsMulW, .RegWriteE, .ResultSrcE, .ValidE, .ImmExtW, .BranchPrD, .MisPredictE, .CSRAddressE, .InstrD);
    lsu lsu(.clk, .MulResult, .reset, .MulResultW, .IsMulE, .IsMulW, .Funct3E, .ImmExtE, .IEUAdrE, .ImmExtW, .IEUResultE, .RdE, .RdM, .RegWriteM, .FSrcBE,
            .ReadData, .IEUAdr, .WriteData, .Funct3M, .RegWriteE, .MemRWE, .ResultSrcE, .StallM, .FlushM, .StallW, .FlushW, .IEUResultW, .ReadDataW, .RdW,
            .RegWriteW, .ResultSrcW, .MemEn, .extout, .WriteByteEn(WriteByteEnE), .WriteByteEnM(WriteByteEn), .ValidW, .ValidE, .CSRAddressE, .CSRAddressW);

    assign InsnRetired = ValidW & ~StallW;
    CSR CSRmodule(.clk, .reset, .InsnRetired, .CSRAddress(CSRAddressW), .CSRout); //.IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc
    assign WriteEn = |WriteByteEn;
    multiplier mdu(.R1(FSrcAE), .R2(FSrcBE), .Funct3(Funct3E), .Funct3M, .MulResult, .noStallM(~StallM), .FlushM, .clk, .reset);
    hazard hazard(.Rs1D(InstrD[19:15]), .Rs2D(InstrD[24:20]), .Rs1E, .Rs2E, .RdE, .MisPredictE, .ResultSrcE, .RdM, .RegWriteM, .RegWriteW, .StallF, .BranchPrD, .StallD, .FlushD, .FlushE, .ForwardAE, .ForwardBE, .FlushW, .StallW, .FlushM, .StallM, .StallE, .RdW, .IsMulE);
endmodule
