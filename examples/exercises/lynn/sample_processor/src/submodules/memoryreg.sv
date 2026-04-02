// pipelined register that takes in a flush and stall input

module memoryreg(
        input  logic        clk, reset,
        input  logic        FlushW, noStallW,
        input  logic        RegWriteM,
        input  logic [1:0]  ResultSrcM,
        input  logic [31:0] CSR, IEUResultM, ReadDataM,
        output logic        RegWriteW,
        output logic [1:0]  ResultSrcW,
        output logic [31:0] CSRW, IEUResultW, ReadDataW
    );

    logic QRegWrite;
    logic [1:0] QResultSrc;
    logic [31:0] QCSR, QIEUResult, QReadData;

    mux2 #(1) RegWritemux(RegWriteW, (RegWriteM & ~flush), noStall, QRegWrite);
    flopr #(1) RegWritereg(.clk, .reset, .D(QRegWrite), .Q(RegWriteW));

    mux2 #(2) ResultSrcmux(ResultSrcW, (ResultSrcM & {2{~flush}}), noStall, QResultSrc);
    flopr #(2) ResultSrcreg(.clk, .reset, .D(QResultSrc), .Q(ResultSrcW));

    mux2 #(32) CSRmux(CSRW, (CSR & {32{~flush}}), noStall, QCSR);
    flopr #(32) CSRreg(.clk, .reset, .D(QCSR), .Q(CSRW));

    mux2 #(32) IEUResultmux(IEUResultW, (IEUResultM & {32{~flush}}), noStall, QIEUResult);
    flopr #(32) IEUResultreg(.clk, .reset, .D(QIEUResult), .Q(IEUResultW));

    mux2 #(32) ReadDatamux(ReadDataW, (ReadDataM & {32{~flush}}), noStall, QReadData);
    flopr #(32) ReadDatareg(.clk, .reset, .D(QReadData), .Q(ReadDataW));

endmodule
