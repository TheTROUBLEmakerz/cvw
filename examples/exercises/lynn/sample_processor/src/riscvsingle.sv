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

    logic [31:0] PCPlus4, CSRout;
    logic PCSrc, MemRWE;
    logic IsAdd, IsBranch, IsBranchTaken, IsJump, IsStore, IsLoad, IsLui, IsAuipc;
    logic [31:0] PCD;
    logic [31:0] InstrD;
    logic StallF, FlushD, StallD, FlushE, StallE, FlushM, StallM, FlushW, StallW;
    logic ForwardAE, ForwardBE;

    ifu ifu(.clk, .reset, .PCSrcE, .IEUAdrE, .PC, .StallF);
    fetchreg fetchreg(.clk, .reset, .FlushD, .noStallD(~StallD), .PCF(PC), .InstrF(Instr), .PCD, .InstrD);
    ieu ieu(.clk, .reset, .Instr, .PC, .PCPlus4, .PCSrcE, .WriteByteEn,
            .IEUAdr, .WriteData, .ReadData, .MemEn(MemRWE), .CSRout, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc
        );
    memoryreg memoryreg(.clk, .reset, .FlushW, .noStallW, .RegWriteM, .ResultSrcM, .MDU, .IEUResultM, .ReadDataM, .RegWriteW, .ResultSrcW, .MDUW, .IEUResultW, .ReadDataW);
    lsu lsu(.clk, .reset, .ReadData, .IEUAdr, .WriteData, .Funct3M, .RegWriteE, .MemRWE, .ResultSrcE, .StallM, .FlushM, .StallW, .FlushW, .IEUResultW, .ReadDataW, .RdW, .RegWriteW, .ResultSrcW, .MemEn);
    CSR CSR(.clk, .reset, .CSRAddress(Instr[31:20]), .CSRout, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc);
    assign WriteEn = |WriteByteEn;
    hazard hazard(.Rs1D, .Rs2D, .Rs1E, .Rs2E, .RdE, .PCSrcE, .ResultSrcE0, .RdM, .RegWriteM, .RegWriteW, .StallF, .StallD, .FlushD, .FlushE, .ForwardAE, .ForwardBE);
endmodule
