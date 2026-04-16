module multiplier (
    input  logic clk, reset,
    input  logic [31:0] R1,
    input  logic [31:0] R2,
    input  logic [2:0]  Funct3,
    input  logic [2:0]  Funct3M,
    output logic [31:0] MulResult,
    input  logic        FlushM, noStallM
);

    logic        [63:0] a_s;
    logic        [63:0] b_s;
    logic        [63:0] a_u;
    logic        [63:0] b_u;
    // logic        [63:0] prod, prodM, Qprod;
    logic        [63:0] prod, AoutM, BoutM, QAout, QBout;
    logic        [63:0] Aout, Bout;

    // Execute Stage
    // Sign extend
    assign    a_s = {{32{R1[31]}}, R1};   // sign-extend R1 to 64
    assign    b_s = {{32{R2[31]}}, R2};   // sign-extend R2 to 64
    assign    a_u = {{32{1'b0}}, R1};              // zero-extend R1 to 64
    assign    b_u = {{32{1'b0}}, R2};              // zero-extend R2 to 64

    mux2  #(64) muxA(a_s,a_u,(Funct3 == 3'b011),Aout);
    mux2  #(64) muxB(b_s,b_u,(Funct3[1] == 1),Bout);

    // mux2 #(64) RegPmux(prodM, (prod & {64{~FlushM}}), noStallM, Qprod);
    // flopr #(64) RegPreg(.clk, .reset, .D(Qprod), .Q(prodM));

    mux2 #(64) Amux(AoutM, (Aout & {64{~FlushM}}), noStallM, QAout);
    flopr #(64) Areg(.clk, .reset, .D(QAout), .Q(AoutM));

    mux2 #(64) Bmux(BoutM, (Bout & {64{~FlushM}}), noStallM, QBout);
    flopr #(64) Breg(.clk, .reset, .D(QBout), .Q(BoutM));

    assign prod = AoutM * BoutM;

    // Memory Stage
    always_comb begin

        case (Funct3M)
            3'b000: MulResult = prod[31:0];   // mul
            default: MulResult = prod[63:32];  // mulh
        endcase
    end
endmodule
