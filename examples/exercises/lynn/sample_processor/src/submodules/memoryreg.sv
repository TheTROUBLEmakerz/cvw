// pipelined register that takes in a FlushW and stall input

module memoryreg(
        input  logic        clk, reset,
        input  logic        FlushW, noStallW, ValidM,
        input  logic        RegWriteM, IsMulM,
        input  logic [1:0]  ResultSrcM,
        input  logic [11:0] CSRAddressM,
        input  logic [31:0] IEUResultM, ReadDataM,ImmExtM, MulResult,
        input  logic [4:0]  RdM,
        output logic        RegWriteW, ValidW, IsMulW,
        output logic [1:0]  ResultSrcW,
        output logic [11:0] CSRAddressW,
        output logic [31:0] IEUResultW, ReadDataW, ImmExtW, MulResultW,
        output logic [4:0]  RdW
    );

    logic QRegWrite, QValid, QIsMul;
    logic [4:0] QRd;
    logic [1:0] QResultSrc;
    logic [31:0] QIEUResult, QReadData, QImmExt, QMulResult;
    logic [11:0] QCSRAddress;

    mux2 #(5) Rdmux(RdW, (RdM & {5{~FlushW}}), noStallW, QRd);
    flopr #(5) Rdreg(.clk, .reset, .D(QRd), .Q(RdW));

    mux2 #(1) IsMulmux(IsMulW, (IsMulM & ~FlushW), noStallW, QIsMul);
    flopr #(1) IsMulreg(.clk, .reset, .D(QIsMul), .Q(IsMulW));

    mux2 #(1) RegWritemux(RegWriteW, (RegWriteM & ~FlushW), noStallW, QRegWrite);
    flopr #(1) RegWritereg(.clk, .reset, .D(QRegWrite), .Q(RegWriteW));

    mux2 #(1) Validmux(ValidW, (ValidM & ~FlushW), noStallW, QValid);
    flopr #(1) Validreg(.clk, .reset, .D(QValid), .Q(ValidW));

    mux2 #(2) ResultSrcmux(ResultSrcW, (ResultSrcM & {2{~FlushW}}), noStallW, QResultSrc);
    flopr #(2) ResultSrcreg(.clk, .reset, .D(QResultSrc), .Q(ResultSrcW));

    mux2 #(32) MulResultmux(MulResultW, (MulResult & {32{~FlushW}}), noStallW, QMulResult);
    flopr #(32) MulResultreg(.clk, .reset, .D(QMulResult), .Q(MulResultW));

    mux2 #(12) CSRAddressmux(CSRAddressW, (CSRAddressM & {12{~FlushW}}), noStallW, QCSRAddress);
    flopr #(12) CSRAddressreg(.clk, .reset, .D(QCSRAddress), .Q(CSRAddressW));

    mux2 #(32) IEUResultmux(IEUResultW, (IEUResultM & {32{~FlushW}}), noStallW, QIEUResult);
    flopr #(32) IEUResultreg(.clk, .reset, .D(QIEUResult), .Q(IEUResultW));

    mux2 #(32) ImmExtmux(ImmExtW, (ImmExtM & {32{~FlushW}}), noStallW, QImmExt);
    flopr #(32) ImmExtreg(.clk, .reset, .D(QImmExt), .Q(ImmExtW));

    mux2 #(32) ReadDatamux(ReadDataW, (ReadDataM & {32{~FlushW}}), noStallW, QReadData);
    flopr #(32) ReadDatareg(.clk, .reset, .D(QReadData), .Q(ReadDataW));

endmodule
