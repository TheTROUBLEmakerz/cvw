// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

//controller + datapath

`include "parameters.svh"

module ieu(
        input   logic           clk, reset,
        input   logic [31:0]    Instr, CSRout,
        input   logic [31:0]    PC, PCPlus4,
        output  logic           PCSrc,
        output  logic [3:0]     WriteByteEn,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData,
        output  logic           MemEn,
        output  logic           IsAdd, IsBranch, IsBranchTaken, IsJump, IsStore, IsLoad, IsLui, IsAuipc
    );


    logic RegWrite, Jump, Eq, ALUResultSrc, Lt;
    logic [1:0] ResultSrc;
    logic [1:0] ALUSrc;
    logic [2:0] ImmSrc;
    logic [1:0] ALUControl;
    logic       IsMul;

    controller c(.IEUAdr(IEUAdr[1:0]), .Op(Instr[6:0]), .Funct3(Instr[14:12]), .Funct7b5(Instr[30]), .Eq, .Lt,
        .ALUResultSrc, .ResultSrc, .WriteByteEn, .PCSrc, .Funct7(Instr[31:25]), .IsMul,
        .ALUSrc, .RegWrite, .ImmSrc, .ALUControl, .MemEn, .IsAdd, .IsBranch, .IsBranchTaken, .IsJump, .IsStore, .IsLoad, .IsLui, .IsAuipc
    `ifdef DEBUG
        , .insn_debug(Instr)
    `endif
    );

    // register file logic
    regfile rf(.reset, .clk, .WE3(RegWrite), .A1(Instr[19:15]), .A2(Instr[24:20]),
        .A3(Instr[11:7]), .WD3(Result), .RD1(R1), .RD2(R2));

    // immediate extend unit
    extend ext(.Instr(Instr[31:7]), .ImmSrc, .ImmExt);

    decodereg decodereg(.clk, .reset, .FlushE, .noStallE, .RegWrite, .MemRW, .ALUResultSrc, .Jump, .ALUControl, .ResultSrc, .ALUSrc, .PCD, .Rd1, .Rd2, .ImmExt, .Funct3, .RdD,
                        .RegWriteE, .ResultSrcE, .MemRWE, .ALUResultSrcE, .JumpE, .ALUControlE, .ALUSrcE, .PCE, .Rd1E, .Rd2E, .ImmExtE, .Funct3E, .RdE);

    datapath dp(.clk, .reset, .Funct3(Instr[14:12]),
        .ALUResultSrc, .ResultSrc, .ALUSrc, .RegWrite, .ImmSrc, .ALUControl, .Eq, .Lt, .IsMul,
        .PC, .PCPlus4, .Instr, .IEUAdr, .WriteData, .ReadData, .CSRout);

    executereg executereg(.clk, .reset, .FlushM, .noStallM, .RegWriteE, .MemRWE, .ResultSrcE, .IEUResultE, .IEUAdrE, .FSrcBE, .Funct3E, .RdE,
                        .RegWriteM, .ResultSrcM, .MemRWM, .IEUResultM, .IEUAdrM, .FSrcBM, .Funct3M, .RdM);
endmodule
