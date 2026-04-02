// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

`include "parameters.svh"

module riscvsingle (
        input   logic           clk,
        input   logic           reset,

        output  logic [31:0]    PC,  // instruction memory target address
        input   logic [31:0]    Instr, // instruction memory read data

        output  logic [31:0]    IEUAdr,  // data memory target address
        input   logic [31:0]    ReadData, // data memory read data
        output  logic [31:0]    WriteData, // data memory write data

        output  logic           MemEn,
        output  logic           WriteEn,
        output  logic [3:0]     WriteByteEn  // strobes, 1 hot stating weather a byte should be written on a store
    );

    logic [31:0] PCPlus4, CSRout, PCE;
    logic PCSrcE, MemRWE;
    logic IsAdd, IsBranch, IsBranchTaken, IsJump, IsStore, IsLoad, IsLui, IsAuipc;
    logic [31:0] PCD;
    logic [31:0] InstrD;
    logic [31:0] IEUAdrE, IEUResultE, IEUResultM, IEUResultW, ReadDataW;
    // logic [31:0] Rd1D, Rd1E, Rd2D, Rs2E;
    logic StallF, FlushD, StallD, FlushE, StallE, FlushM, StallM, FlushW, StallW;
    logic [1:0] ForwardAE, ForwardBE;
    logic RegWriteW, RegWriteM, RegWriteE;
    logic [1:0] ResultSrcM, ResultSrcE, ResultSrcW;
    logic [4:0] RdW, RdE, RdM, Rs1E, Rs2E;
    logic [31:0] CSRW, CSRE;
    logic [31:0] FSrcBE;
    logic [2:0] Funct3M, Funct3E;

    ifu ifu(.clk, .reset, .PCSrcE, .IEUAdrE, .PC, .StallF);
    fetchreg fetchreg(.clk, .reset, .FlushD, .noStallD(~StallD), .PCF(PC), .InstrF(Instr), .PCD, .InstrD);
    ieu ieu(.clk, .reset, .StallE, .FlushE, .ForwardAE, .ForwardBE, .InstrD, .CSRout, .PCD, .PCSrcE, .WriteByteEn, .RegWriteW, .ResultSrcW, .IEUResultM, .IEUResultW, .ReadDataW, .RdW, .IEUAdrE, .IEUResultE, .ReadData, .CSRW, .MemRWE, .FSrcBE,
            .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc, .RdE, .Rs2E, .Rs1E, .Funct3E, .RegWriteE, .ResultSrcE, .CSRE);
    lsu lsu(.clk, .reset, .Funct3E, .IEUAdrE, .IEUResultE, .RdE, .RdM, .RegWriteM, .FSrcBE, .ReadData, .IEUAdr, .WriteData, .Funct3M, .RegWriteE, .MemRWE, .ResultSrcE, .StallM, .FlushM, .StallW, .FlushW, .CSRE, .IEUResultW, .ReadDataW, .RdW, .RegWriteW, .ResultSrcW, .MemEn, .CSRW, .IEUResultM);
    CSR CSRmodule(.clk, .reset, .CSRAddress(InstrD[31:20]), .CSRout, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc);
    assign WriteEn = |WriteByteEn;
    hazard hazard(.Rs1D(InstrD[19:15]), .Rs2D(InstrD[24:20]), .Rs1E, .Rs2E, .RdE, .PCSrcE, .ResultSrcE0(ResultSrcE[0]), .RdM, .RegWriteM, .RegWriteW, .StallF, .StallD, .FlushD, .FlushE, .ForwardAE, .ForwardBE, .FlushW, .StallW, .FlushM, .StallM, .StallE, .RdW);
endmodule
