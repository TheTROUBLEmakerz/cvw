// pipelined register that takes in a flush and stall input

module decodereg(
        input  logic        clk, reset,
        input  logic        FlushE, noStallE,
        input  logic        RegWrite, MemRW, ALUResultSrc, Jump, ALUControl,
        input  logic [1:0]  ResultSrc, ALUSrc,
        input  logic [31:0] PCD, Rd1, Rd2, ImmExt,
        input  logic [2:0]  Funct3,
        input  logic [4:0]  RdD,
        output logic        RegWriteE, ResultSrcE, MemRWE, ALUResultSrcE, JumpE, ALUControlE,
        output logic [1:0]  ALUSrcE,
        output logic [31:0] PCE, Rd1E, Rd2E, ImmExtE,
        output logic [2:0]  Funct3E,
        output logic [4:0]  RdE,
    );

    logic QRegWrite, QMemRW, QALUResultSrc, QJump, QALUControl;
    logic [1:0] QResultSrc, QALUSrc;
    logic [31:0] QPC, QRd1, QRd2, QImmExt;
    logic [2:0] QFunct3;
    logic [4:0] QRd;

    mux2 #(1) RegWritemux(RegWriteE, (RegWrite & ~flush), noStall, QRegWrite);
    flopr #(1) RegWritereg(.clk, .reset, .D(QRegWrite), .Q(RegWriteE));

    mux2 #(1) MemRWmux(MemRWE, (MemRW & ~flush), noStall, QMemRW);
    flopr #(1) MemRWreg(.clk, .reset, .D(QMemRW), .Q(MemRWE));

    mux2 #(1) ALUResultSrcmux(ALUResultSrcE, (ALUResultSrc & ~flush), noStall, QALUResultSrc);
    flopr #(1) ALUResultSrcreg(.clk, .reset, .D(QALUResultSrc), .Q(ALUResultSrcE));

    mux2 #(1) Jumpmux(JumpE, (Jump & ~flush), noStall, QJump);
    flopr #(1) Jumpreg(.clk, .reset, .D(QJump), .Q(JumpE));

    mux2 #(2) ALUControlmux(ALUControlE, (ALUControl & 2{~flush}), noStall, QALUControl);
    flopr #(2) ALUControlreg(.clk, .reset, .D(QALUControl), .Q(ALUControlE));

    mux2 #(2) ResultSrcmux(ResultSrcE, (ResultSrc & 2{~flush}), noStall, QResultSrc);
    flopr #(2) ResultSrcreg(.clk, .reset, .D(QResultSrc), .Q(ResultSrcE));

    mux2 #(2) ALUSrcmux(ALUSrcE, (ALUSrc & 2{~flush}), noStall, QALUSrc);
    flopr #(2) ALUSrcreg(.clk, .reset, .D(QALUSrc), .Q(ALUSrcE));

    mux2 #(32) PCmux(PCE, (PCD & 32{~flush}), noStall, QPC);
    flopr #(32) PCreg(.clk, .reset, .D(QPC), .Q(PCE));

    mux2 #(32) Rd1mux(Rd1E, (Rd1 & 32{~flush}), noStall, QRd1);
    flopr #(32) Rd1reg(.clk, .reset, .D(QRd1), .Q(Rd1E));

    mux2 #(32) Rd2mux(Rd2E, (Rd2 & 32{~flush}), noStall, QRd2);
    flopr #(32) Rd2reg(.clk, .reset, .D(QRd2), .Q(Rd2E));

    mux2 #(32) ImmExtmux(ImmExtE, (ImmExt & 32{~flush}), noStall, QImmExt);
    flopr #(32) ImmExtreg(.clk, .reset, .D(QImmExt), .Q(ImmExtE));

    mux2 #(3) Funct3mux(Funct3E, (Funct3 & 3{~flush}), noStall, QFunct3);
    flopr #(3) Funct3reg(.clk, .reset, .D(QFunct3), .Q(Funct3E));

    mux2 #(5) Rdmux(RdE, (RdD & 5{~flush}), noStall, QRd);
    flopr #(5) Rdreg(.clk, .reset, .D(QRd), .Q(RdE));

endmodule
