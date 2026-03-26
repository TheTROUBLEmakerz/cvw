// pipelined register that takes in a flush and stall input

module pipeReg(
        input  logic        clk, reset,
        input  logic        flush, noStall,
        input  logic [31:0] D,
        output logic [31:0] Q
    );
    logic [31:0] Qmid;
    // a normal register
    flopr #(32) reg(.clk, .reset, .D(Qmid), .Q);
    mux2 #(32) mux(Q, (D & 32{~flush}), noStall, Qmid);

endmodule
