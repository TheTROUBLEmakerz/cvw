
`include "parameters.svh"

module lsu(
        input   logic           clk, reset,
        input   logic [31:0]    ReadData,
        output  logic [31:0]    IEUAdr, WriteData,
        output  logic [2:0]     Funct3M,

        input   logic [31:0]    FSrcBE, IEUResultE, IEUAdrE, MulResult,
        input   logic [2:0]     Funct3E,
        input   logic           RegWriteE, MemRWE, ValidE, IsMulE,
        input   logic [1:0]     ResultSrcE,
        input   logic           StallM, FlushM, StallW, FlushW,
        input   logic [31:0]    CSRE, ImmExtE,
        input   logic [4:0]     RdE,
        input   logic [3:0]     WriteByteEn,
        output  logic [31:0]    IEUResultW, ReadDataW,
        output  logic [4:0]     RdW,RdM,
        output  logic           RegWriteW, RegWriteM,
        output  logic [1:0]     ResultSrcW,
        output  logic           MemEn, ValidW, IsMulW,
        output  logic [31:0]    CSRW, ResultM, ImmExtW, MulResultW,
        output  logic [3:0]     WriteByteEnM
    );

    logic ValidM, IsMulM;
    logic [1:0]  ResultSrcM;

    logic [31:0] FSrcBM, ReadDataM, CSRM, ImmExtM, IEUResultM, MulResultM, extout;
    executereg executereg(.clk, .reset, .FlushM, .noStallM(~StallM), .RegWriteE, .MemRWE, .ResultSrcE, .IEUResultE, .IEUAdrE, .FSrcBE, .Funct3E, .RdE, .ImmExtE, .ImmExtM,
                        .RegWriteM, .ResultSrcM, .MemRWM(MemEn), .IEUResultM, .IEUAdrM(IEUAdr), .FSrcBM, .Funct3M, .RdM, .CSRE, .CSRM, .WriteByteEn, .WriteByteEnM, .ValidE, .ValidM,
                        .IsMulE, .IsMulM, .MulResult, .MulResultM);

    ext2 ext2(Funct3M, IEUAdr[2:0], ReadData, ReadDataM); // this is for load/store

    mux2 #(32) extmux(IEUResultM, MulResultM, IsMulM, extout);
    mux4 #(32) resultmuxM(extout, ReadDataM, ImmExtM, CSRM, ResultSrcM, ResultM);
    always_comb
    begin
        case(Funct3M[1:0])
            2'b10: WriteData = FSrcBM;
            2'b01: WriteData = {FSrcBM[15:0], FSrcBM[15:0]};
            2'b00: WriteData = {4{FSrcBM[7:0]}};
            default: WriteData = 32'b0;
        endcase
    end


    memoryreg memoryreg(.clk, .reset, .FlushW, .noStallW(~StallW), .RegWriteM, .ResultSrcM, .CSRM, .IEUResultM, .IsMulM, .MulResultM, .IsMulW, .MulResultW,
                        .ReadDataM, .RegWriteW, .ResultSrcW, .CSRW, .IEUResultW, .ReadDataW, .RdW, .RdM, .ImmExtM, .ImmExtW, .ValidM, .ValidW);

endmodule
