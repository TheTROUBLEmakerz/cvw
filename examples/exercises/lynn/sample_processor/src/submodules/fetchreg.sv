// pipelined register that takes in a flush and stall input

module fetchreg(
        input  logic        clk, reset,
        input  logic        FlushD, noStallD,
        input  logic [31:0] PCF, InstrF,
        output logic [31:0] PCD, InstrD
    );
    logic [31:0] Qmid1, Qmid2;

    // pass PC
    mux2 #(32) PCmux(PCD, (PCF & {32{~flush}}), noStall, Qmid1);
    flopr #(32) PCreg(.clk, .reset, .D(Qmid1), .Q(PCD));

    // pass Instr
    mux2 #(32) Instrmux(InstrD, (InstrF & {32{~flush}}), noStall, Qmid2);
    flopr #(32) Instrreg(.clk, .reset, .D(Qmid2), .Q(InstrD));

endmodule
