
`include "parameters.svh"

module lsu(
        input   logic           clk, reset,
        input   logic [31:0]    ReadData,
        output  logic [31:0]    IEUAdr, WriteData,
        output  logic [2:0]     Funct3M,

        input   logic [31:0]    FSrcBE, RdE, IEUResultE,
        input   logic [2:0]     Funct3E,
        input   logic           RegWriteE, MemRWE,
        input   logic [1:0]     ResultSrcE,
        input   logic           StallM, FlushM, StallW, FlushW,

        output  logic [31:0]    IEUResultW, ReadDataW, RdW,
        output  logic           RegWriteW,
        output  logic [1:0]     ResultSrcW,

        // fill in
    );

    logic        RegWriteM, MemRWM;
    logic [1:0]  ResultSrcM;
    logic [31:0] IEUResultM, FSrcBM, ReadDataM, RdM;
    executereg executereg(.clk, .reset, .FlushM, .noStallM, .RegWriteE, .MemRWE, .ResultSrcE, .IEUResultE, .IEUAdrE, .FSrcBE, .Funct3E, .RdE,
                        .RegWriteM, .ResultSrcM, .MemRWM, .IEUResultM, .IEUAdr, .FSrcBM, .Funct3M, .RdM);

    ext2 ext2(Funct3M, IEUAdrM[2:0], ReadData, ReadDataM); // this is for load/store

    always_comb
    begin
        case(Funct3M[1:0])
            2'b10: WriteData = FSrcBM;
            2'b01: WriteData = {FSrcBM[15:0], FSrcBM[15:0]};
            2'b00: WriteData = {4{FSrcBM[7:0]}};
            default: WriteData = 32'b0;
        endcase
    end


    memoryreg memoryreg(.clk, .reset, .FlushW, .noStallW, .RegWriteM, .ResultSrcM, .MDU, .IEUResultM,
                        .ReadDataM, .RegWriteW, .ResultSrcW, .MDUW, .IEUResultW, .ReadDataW)

endmodule
