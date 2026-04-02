// pipelined register that takes in a FlushM and stall input

module executereg(
        input  logic        clk, reset,
        input  logic        FlushM, noStallMM,
        input  logic        RegWriteE, MemRWE,
        input  logic [1:0]  ResultSrcE,
        input  logic [31:0] IEUResultE, IEUAdrE, FSrcBE,
        input  logic [2:0]  Funct3E,
        input  logic [4:0]  RdE,
        output logic        RegWriteM, MemRWM,
        output logic [1:0]  ResultSrcM,
        output logic [31:0] IEUResultM, IEUAdrM, FSrcBM,
        output logic [2:0]  Funct3M,
        output logic [4:0]  RdM
    );
    logic QRegWrite, QMemRW;
    logic [1:0] QResultSrc;
    logic [31:0] QIEUResult, QIEUAdr, QFSrcB;
    logic [2:0] QFunct3;
    logic [4:0] QRd;

    mux2 #(1) RegWritemux(RegWriteM, (RegWriteE & ~FlushM), noStallM, QRegWrite);
    flopr #(1) RegWritereg(.clk, .reset, .D(QRegWrite), .Q(RegWriteM));

    mux2 #(1) MemRWmux(MemRWM, (MemRWE & ~FlushM), noStallM, QMemRW);
    flopr #(1) MemRWreg(.clk, .reset, .D(QMemRW), .Q(MemRWM));

    mux2 #(2) ResultSrcmux(ResultSrcM, (ResultSrcE & {2{~FlushM}}), noStallM, QResultSrc);
    flopr #(2) ResultSrcreg(.clk, .reset, .D(QResultSrc), .Q(ResultSrcM));

    mux2 #(32) IEUResultmux(IEUResultM, (IEUResultE & {32{~FlushM}}), noStallM, QIEUResult);
    flopr #(32) IEUResultreg(.clk, .reset, .D(QIEUResult), .Q(IEUResultM));

    mux2 #(32) IEUAdrmux(IEUAdrM, (IEUAdrE & {32{~FlushM}}), noStallM, QIEUAdr);
    flopr #(32) IEUAdrreg(.clk, .reset, .D(QIEUAdr), .Q(IEUAdrM));

    mux2 #(32) FSrcBmux(FSrcBM, (FSrcBE & {32{~FlushM}}), noStallM, QFSrcB);
    flopr #(32) FSrcBreg(.clk, .reset, .D(QFSrcB), .Q(FSrcBM));

    mux2 #(3) Funct3mux(Funct3M, (Funct3E & {3{~FlushM}}), noStallM, QFunct3);
    flopr #(3) Funct3reg(.clk, .reset, .D(QFunct3), .Q(Funct3M));

    mux2 #(5) Rdmux(RdM, (RdE & {5{~FlushM}}), noStallM, QRd);
    flopr #(5) Rdreg(.clk, .reset, .D(QRd), .Q(RdM));

endmodule
