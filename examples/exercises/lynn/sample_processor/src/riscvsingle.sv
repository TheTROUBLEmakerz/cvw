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
    logic PCSrc;
    logic IsAdd, IsBranch, IsBranchTaken, IsJump, IsStore, IsLoad, IsLui, IsAuipc;
    logic [31:0] PCF, PCD;
    logic [31:0] InstrF, InstrD;

    ifu ifu(.clk, .reset, .PCSrc, .IEUAdr, .PC, .PCPlus4);
    fetchreg fetchreg(.clk, .reset, .FlushD, .noStallD(~StallD), .PCF, .InstrF, .PCD, .InstrD);
    ieu ieu(.clk, .reset, .Instr, .PC, .PCPlus4, .PCSrc, .WriteByteEn,
            .IEUAdr, .WriteData, .ReadData, .MemEn, .CSRout, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc
        );
    memoryreg memoryreg(.clk, .reset, .FlushW, .noStallW, .RegWriteM, .ResultSrcM, .MDU, .IEUResultM, .ReadDataM, .RegWriteW, .ResultSrcW, .MDUW, .IEUResultW, .ReadDataW)
    CSR CSR(.clk, .reset, .CSRAddress(Instr[31:20]), .CSRout, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc);
    assign WriteEn = |WriteByteEn;
    hazard hazard(.Rs1D, .Rs2D, .Rs1E, .Rs2E, RdE, .PCSrcE, .ResultSrcE0, .RdM, .RegWriteM, .RegWriteW, .StallF, .StallD, .FlushD, .FlushE, .ForwardAE, .ForwardBE);
endmodule
