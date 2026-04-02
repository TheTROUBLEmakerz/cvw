// pipelined register that takes in a FlushW and stall input

module memoryreg(
        input  logic        clk, reset,
        input  logic        FlushW, noStallW,
        input  logic        RegWriteM,
        input  logic [1:0]  ResultSrcM,
        input  logic [31:0] CSRM, IEUResultM, ReadDataM,ImmExtM,
        input  logic [4:0]  RdM,
        output logic        RegWriteW,
        output logic [1:0]  ResultSrcW,
        output logic [31:0] CSRW, IEUResultW, ReadDataW, ImmExtW,
        output logic [4:0]  RdW
    );

    logic QRegWrite;
    logic [4:0] QRd;
    logic [1:0] QResultSrc;
    logic [31:0] QCSR, QIEUResult, QReadData, QImmExt;

    mux2 #(5) Rdmux(RdW, (RdM & ~FlushW), noStallW, QRd);
    flopr #(5) Rdreg(.clk, .reset, .D(QRd), .Q(RdW));

    mux2 #(1) RegWritemux(RegWriteW, (RegWriteM & ~FlushW), noStallW, QRegWrite);
    flopr #(1) RegWritereg(.clk, .reset, .D(QRegWrite), .Q(RegWriteW));

    mux2 #(2) ResultSrcmux(ResultSrcW, (ResultSrcM & {2{~FlushW}}), noStallW, QResultSrc);
    flopr #(2) ResultSrcreg(.clk, .reset, .D(QResultSrc), .Q(ResultSrcW));

    mux2 #(32) CSRmux(CSRW, (CSRM & {32{~FlushW}}), noStallW, QCSR);
    flopr #(32) CSRreg(.clk, .reset, .D(QCSR), .Q(CSRW));

    mux2 #(32) IEUResultmux(IEUResultW, (IEUResultM & {32{~FlushW}}), noStallW, QIEUResult);
    flopr #(32) IEUResultreg(.clk, .reset, .D(QIEUResult), .Q(IEUResultW));

    mux2 #(32) ImmExtmux(ImmExtW, (ImmExtM & {32{~FlushW}}), noStallW, QImmExt);
    flopr #(32) ImmExtreg(.clk, .reset, .D(QImmExt), .Q(ImmExtW));

    mux2 #(32) ReadDatamux(ReadDataW, (ReadDataM & {32{~FlushW}}), noStallW, QReadData);
    flopr #(32) ReadDatareg(.clk, .reset, .D(QReadData), .Q(ReadDataW));

endmodule
