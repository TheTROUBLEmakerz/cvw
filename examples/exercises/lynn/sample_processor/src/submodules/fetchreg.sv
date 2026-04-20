// pipelined register that takes in a flush and stall input

module fetchreg(
        input  logic        clk, reset,
        input  logic        FlushD, noStallD, BranchPr,
        input  logic [31:0] PCF, InstrF, ImmExt,
        output logic [31:0] PCD, InstrD, ImmExtD,
        output logic        ValidD, BranchPrD
    );
    logic [31:0] Qmid1, Qmid2, QImmExt;
    logic QValid, QBranchPr;

    mux2 #(32) ImmExtmux(ImmExtD, (ImmExt & {32{~FlushD}}), noStallD, QImmExt);
    flopr #(32) ImmExtreg(.clk, .reset, .D(QImmExt), .Q(ImmExtD));

    mux2 #(32) PCmux(PCD, (PCF & {32{~FlushD}}), noStallD, Qmid1);
    flopr #(32) PCreg(.clk, .reset, .D(Qmid1), .Q(PCD));

    // pass Instr
    mux2 #(32) Instrmux(InstrD, (InstrF & {32{~FlushD}}), noStallD, Qmid2);
    flopr #(32) Instrreg(.clk, .reset, .D(Qmid2), .Q(InstrD));

    mux2 #(1) Validmux(ValidD, (~reset & ~FlushD), noStallD, QValid);
    flopr #(1) Validreg(.clk, .reset, .D(QValid), .Q(ValidD));

    mux2 #(1) BranchPrmux(BranchPrD, (BranchPr & ~FlushD), noStallD, QBranchPr);
    flopr #(1) BranchPrreg(.clk, .reset, .D(QBranchPr), .Q(BranchPrD));
endmodule
