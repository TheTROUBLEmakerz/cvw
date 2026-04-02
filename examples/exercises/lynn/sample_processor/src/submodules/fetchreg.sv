// pipelined register that takes in a flush and stall input

module fetchreg(
        input  logic        clk, reset,
        input  logic        FlushD, noStallD,
        input  logic [31:0] PCF, InstrF,
        output logic [31:0] PCD, InstrD,
        output logic        ValidD
    );
    logic [31:0] Qmid1, Qmid2;
    logic QValid;

    // pass PC
    mux2 #(32) PCmux(PCD, (PCF & {32{~FlushD}}), noStallD, Qmid1);
    flopr #(32) PCreg(.clk, .reset, .D(Qmid1), .Q(PCD));

    // pass Instr
    mux2 #(32) Instrmux(InstrD, (InstrF & {32{~FlushD}}), noStallD, Qmid2);
    flopr #(32) Instrreg(.clk, .reset, .D(Qmid2), .Q(InstrD));

    mux2 #(1) Validmux(ValidD, (~reset & ~FlushM), noStallM, QValid);
    flopr #(1) Validreg(.clk, .reset, .D(QValid), .Q(ValidD));
endmodule
