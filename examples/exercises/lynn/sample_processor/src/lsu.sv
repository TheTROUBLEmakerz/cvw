`include "parameters.svh"

module lsu(
        input   logic           clk, reset,
        input   logic [31:0]    ReadData,
        output  logic [31:0]    IEUAdr, WriteData,
        output  logic [2:0]     Funct3M,
        input   logic [11:0]    CSRAddressE,
        input   logic [31:0]    FSrcBE, IEUResultE, IEUAdrE, MulResult,
        input   logic [2:0]     Funct3E,
        input   logic           RegWriteE, MemRWE, ValidE, IsMulE,
        input   logic [1:0]     ResultSrcE,
        input   logic           StallM, FlushM, StallW, FlushW,
        input   logic [31:0]    ImmExtE,
        input   logic [4:0]     RdE,
        input   logic [3:0]     WriteByteEn,
        output  logic [31:0]    IEUResultW, ReadDataW, extout,
        output  logic [4:0]     RdW,RdM,
        output  logic           RegWriteW, RegWriteM,
        output  logic [1:0]     ResultSrcW,
        output  logic           MemEn, ValidW, IsMulW,
        output  logic [31:0]    ImmExtW, MulResultW,
        output  logic [3:0]     WriteByteEnM,
        output  logic [11:0]    CSRAddressW
    );

    logic ValidM, IsMulM;
    logic [1:0]  ResultSrcM, ForwardSelM;
    logic [11:0] CSRAddressM;

    logic [31:0] FSrcBM, ReadDataM, ImmExtM, IEUResultM,extoutM;
    executereg executereg(.clk, .reset, .FlushM, .IsMulE, .IsMulM, .noStallM(~StallM), .RegWriteE, .MemRWE, .ResultSrcE, .IEUResultE,
                        .IEUAdrE, .FSrcBE, .Funct3E, .RdE, .ImmExtE, .ImmExtM, .RegWriteM, .ResultSrcM, .MemRWM(MemEn), .IEUResultM,
                        .IEUAdrM(IEUAdr), .FSrcBM, .Funct3M, .RdM, .WriteByteEn, .WriteByteEnM, .ValidE, .ValidM, .CSRAddressE, .CSRAddressM);

    ext2 ext2(Funct3M, IEUAdr[2:0], ReadData, ReadDataM);

    always_comb begin
        case (ResultSrcM)
            2'b10: extout = ImmExtM; // LUI → ImmExtM
            //2'b11: ForwardSelM = 2'b10; // CSR → CSRM
            default: extout = IEUResultM; // ALU
        endcase
    end

    always_comb
    begin
        case(Funct3M[1:0])
            2'b10: WriteData = FSrcBM;
            2'b01: WriteData = {FSrcBM[15:0], FSrcBM[15:0]};
            2'b00: WriteData = {4{FSrcBM[7:0]}};
            default: WriteData = 32'b0;
        endcase
    end

    memoryreg memoryreg(.clk, .reset, .FlushW, .noStallW(~StallW), .RegWriteM, .ResultSrcM, .IEUResultM, .MulResult, .MulResultW, .CSRAddressM, .CSRAddressW,
                        .ReadDataM, .RegWriteW, .IsMulM, .IsMulW, .ResultSrcW, .IEUResultW, .ReadDataW, .RdW, .RdM, .ImmExtM, .ImmExtW, .ValidM, .ValidW);

endmodule
