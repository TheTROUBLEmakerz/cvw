// pipelined register that takes in a FlushE and stall input

module decodereg(
        input  logic        clk, reset,
        input  logic        FlushE, noStallE, ValidD,
        input  logic        RegWrite, MemRW, ALUResultSrc, Jump,
        input  logic [1:0]  ResultSrc, ALUSrc, ALUControl,
        input  logic [31:0] PCD, Rd1, Rd2, ImmExt, CSRD,
        input  logic [2:0]  Funct3,
        input  logic        Funct7b5, Branch, MemWrite,
        input  logic [4:0]  RdD,Rs1D, Rs2D,
        output logic        RegWriteE, MemRWE, ALUResultSrcE, JumpE,MemWriteE,
        output logic [1:0]  ALUSrcE, ALUControlE, ResultSrcE,
        output logic [31:0] PCE, Rd1E, Rd2E, ImmExtE, CSRE,
        output logic [2:0]  Funct3E,
        output logic        Funct7b5E, BranchE, ValidE,
        output logic [4:0]  RdE, Rs1E, Rs2E
    );

    logic QRegWrite, QMemRW, QALUResultSrc, QJump, QFunct7, QBranch, QMemWrite, QValid;
    logic [1:0] QResultSrc, QALUSrc, QALUControl;
    logic [31:0] QPC, QRd1, QRd2, QImmExt, QCSR;
    logic [2:0] QFunct3;
    logic [4:0] QRd, QRs1, QRs2;


    mux2 #(1) MemWritemux(MemWriteE, (MemWrite & ~FlushE), noStallE, QMemWrite);
    flopr #(1) MemWritereg(.clk, .reset, .D(QMemWrite), .Q(MemWriteE));

    mux2 #(1) RegWritemux(RegWriteE, (RegWrite & ~FlushE), noStallE, QRegWrite);
    flopr #(1) RegWritereg(.clk, .reset, .D(QRegWrite), .Q(RegWriteE));

    mux2 #(1) Validmux(ValidE, (ValidD & ~FlushE), noStallE, QValid);
    flopr #(1) Validreg(.clk, .reset, .D(QValid), .Q(ValidE));

    mux2 #(1) Branchmux(BranchE, (Branch & ~FlushE), noStallE, QBranch);
    flopr #(1) Branchreg(.clk, .reset, .D(QBranch), .Q(BranchE));

    mux2 #(1) MemRWmux(MemRWE, (MemRW & ~FlushE), noStallE, QMemRW);
    flopr #(1) MemRWreg(.clk, .reset, .D(QMemRW), .Q(MemRWE));

    mux2 #(1) ALUResultSrcmux(ALUResultSrcE, (ALUResultSrc & ~FlushE), noStallE, QALUResultSrc);
    flopr #(1) ALUResultSrcreg(.clk, .reset, .D(QALUResultSrc), .Q(ALUResultSrcE));

    mux2 #(1) Jumpmux(JumpE, (Jump & ~FlushE), noStallE, QJump);
    flopr #(1) Jumpreg(.clk, .reset, .D(QJump), .Q(JumpE));

    mux2 #(2) ALUControlmux(ALUControlE, (ALUControl & {2{~FlushE}}), noStallE, QALUControl);
    flopr #(2) ALUControlreg(.clk, .reset, .D(QALUControl), .Q(ALUControlE));

    mux2 #(2) ResultSrcmux(ResultSrcE, (ResultSrc & {2{~FlushE}}), noStallE, QResultSrc);
    flopr #(2) ResultSrcreg(.clk, .reset, .D(QResultSrc), .Q(ResultSrcE));

    mux2 #(2) ALUSrcmux(ALUSrcE, (ALUSrc & {2{~FlushE}}), noStallE, QALUSrc);
    flopr #(2) ALUSrcreg(.clk, .reset, .D(QALUSrc), .Q(ALUSrcE));

    mux2 #(32) PCmux(PCE, (PCD & {32{~FlushE}}), noStallE, QPC);
    flopr #(32) PCreg(.clk, .reset, .D(QPC), .Q(PCE));

    mux2 #(32) Rd1mux(Rd1E, (Rd1 & {32{~FlushE}}), noStallE, QRd1);
    flopr #(32) Rd1reg(.clk, .reset, .D(QRd1), .Q(Rd1E));

    mux2 #(32) Rd2mux(Rd2E, (Rd2 & {32{~FlushE}}), noStallE, QRd2);
    flopr #(32) Rd2reg(.clk, .reset, .D(QRd2), .Q(Rd2E));

    mux2 #(32) ImmExtmux(ImmExtE, (ImmExt & {32{~FlushE}}), noStallE, QImmExt);
    flopr #(32) ImmExtreg(.clk, .reset, .D(QImmExt), .Q(ImmExtE));

    mux2 #(32) CSRmux(CSRE, (CSRD & {32{~FlushE}}), noStallE, QCSR);
    flopr #(32) CSRreg(.clk, .reset, .D(QCSR), .Q(CSRE));

    mux2 #(3) Funct3mux(Funct3E, (Funct3 & {3{~FlushE}}), noStallE, QFunct3);
    flopr #(3) Funct3reg(.clk, .reset, .D(QFunct3), .Q(Funct3E));

    mux2 #(1) Funct7mux(Funct7b5E, (Funct7b5 & ~FlushE), noStallE, QFunct7);
    flopr #(1) Funct7reg(.clk, .reset, .D(QFunct7), .Q(Funct7b5E));

    mux2 #(5) Rdmux(RdE, (RdD & {5{~FlushE}}), noStallE, QRd);
    flopr #(5) Rdreg(.clk, .reset, .D(QRd), .Q(RdE));

    mux2 #(5) Rs1mux(Rs1E, (Rs1D & {5{~FlushE}}), noStallE, QRs1);
    flopr #(5) Rs1reg(.clk, .reset, .D(QRs1), .Q(Rs1E));

    mux2 #(5) Rs2mux(Rs2E, (Rs2D & {5{~FlushE}}), noStallE, QRs2);
    flopr #(5) Rs2reg(.clk, .reset, .D(QRs2), .Q(Rs2E));

endmodule
