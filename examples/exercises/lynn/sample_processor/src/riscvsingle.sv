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
    logic [31:0] Rs1D, Rs1E, Rs2D, Rs2E;
    logic StallF, FlushD, StallD, FlushE, StallE, FlushM, StallM, FlushW, StallW;
    logic ForwardAE, ForwardBE;
    logic RegWriteW, ResultSrcW, RegWriteM, ResultSrcM, RegWriteE, ResultSrcE;
    logic [4:0] RdW, RdE, RdM;
    logic [31:0] MDUW, MDU;
    logic FSrcBE;
    logic [2:0] Funct3M;

    ifu ifu(.clk, .reset, .PCSrcE, .IEUAdrE, .PC, .StallF);
    fetchreg fetchreg(.clk, .reset, .FlushD, .noStallD(~StallD), .PCF(PC), .InstrF(Instr), .PCD, .InstrD);
    ieu ieu(.clk, .reset, .StallE, .FlushE, .ForwardAE, .ForwardBE, .InstrD, .CSRout, .PCD, .PCSrcE, .WriteByteEn, .RegWriteW, .ResultSrcW, .IEUResultM, .IEUResultW, .ReadDataW, .RdW, .IEUAdrE, .WriteData, .IEUResultE, .ReadData, .MDUW, .MemEn, .FSrcBE,
            .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc);
    memoryreg memoryreg(.clk, .reset, .FlushW, .noStallW(~StallW), .RegWriteM, .ResultSrcM, .MDU, .IEUResultM, .ReadDataM(ReadData), .RegWriteW, .ResultSrcW, .MDUW, .IEUResultW, .ReadDataW);
    lsu lsu(.clk, .reset, .ReadData, .IEUAdr, .WriteData, .Funct3M, .RegWriteE, .MemRWE, .ResultSrcE, .StallM, .FlushM, .StallW, .FlushW, .MDU, .IEUResultW, .ReadDataW, .RdW, .RegWriteW, .ResultSrcW, .MemEn, .MDUW);
    CSR CSR(.clk, .reset, .CSRAddress(Instr[31:20]), .CSRout, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc);
    assign WriteEn = |WriteByteEn;
    hazard hazard(.Rs1D, .Rs2D, .Rs1E, .Rs2E, .RdE, .PCSrcE, .ResultSrcE0(ResultSrcE), .RdM, .RegWriteM, .RegWriteW, .StallF, .StallD, .FlushD, .FlushE, .ForwardAE, .ForwardBE);
endmodule
