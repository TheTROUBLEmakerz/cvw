module multiplier (
    input  logic clk, reset,
    input  logic [31:0] R1,
    input  logic [31:0] R2,
    input  logic [2:0]  Funct3,
    input  logic [2:0]  Funct3M,
    output logic [31:0] MulResult,
    input  logic        FlushM, noStallM
);
    logic [31:0]    Aprime, Bprime;                       // lower bits of source A and B
    logic               MULH, MULHSU;                         // type of multiply
    logic [30:0]    PA, PB;                               // product of msb and lsbs
    logic               PP;                                   // product of msbs
    logic [63:0]  PP1E, PP2E, PP3E, PP4E;               // partial products
    logic [63:0]  PP1M, PP2M, PP3M, PP4M;               // registered partial proudcts
    logic [63:0]  QPP1, QPP2, QPP3, QPP4;
    logic [63:0]  ProdM;

    //////////////////////////////
    // Execute Stage: Compute partial products
    //////////////////////////////

    assign Aprime = {1'b0, R1[30:0]};
    assign Bprime = {1'b0, R2[30:0]};
    assign PP1E = Aprime * Bprime;
    assign PA = {(31){R1[31]}} & R2[30:0];
    assign PB = {(31){R2[31]}} & R1[30:0];
    assign PP = R1[31] & R2[31];

    // flavor of multiplication
    assign MULH   = (Funct3 == 3'b001);
    assign MULHSU = (Funct3 == 3'b010);

    // Select partial products, handling signed multiplication
    assign PP2E = {2'b00, (MULH | MULHSU) ? ~PA : PA, {(31){1'b0}}};
    assign PP3E = {2'b00, (MULH) ? ~PB : PB, {(31){1'b0}}};
    always_comb
    if (MULH)        PP4E = {1'b1, PP, {(29){1'b0}}, 1'b1, {(32){1'b0}}};
    else if (MULHSU) PP4E = {1'b1, ~PP, {(30){1'b0}}, 1'b1, {(31){1'b0}}};
    else             PP4E = {1'b0, PP, {(32*2-2){1'b0}}};

    //////////////////////////////
    // Memory Stage: Sum partial proudcts
    //////////////////////////////

    //flopenrc #(32*2) PP1Reg(clk, reset, FlushM, noStallM, PP1E, PP1M);
    //flopenrc #(32*2) PP2Reg(clk, reset, FlushM, noStallM, PP2E, PP2M);
    //flopenrc #(32*2) PP3Reg(clk, reset, FlushM, noStallM, PP3E, PP3M);
    //flopenrc #(32*2) PP4Reg(clk, reset, FlushM, noStallM, PP4E, PP4M);

    mux2 #(64) PP1mux(PP1M, (PP1E & {64{~FlushM}}), noStallM, QPP1);
    flopr #(64) PP1reg(.clk, .reset, .D(QPP1), .Q(PP1M));
    mux2 #(64) PP2mux(PP2M, (PP2E & {64{~FlushM}}), noStallM, QPP2);
    flopr #(64) PP2reg(.clk, .reset, .D(QPP2), .Q(PP2M));
    mux2 #(64) PP3mux(PP3M, (PP3E & {64{~FlushM}}), noStallM, QPP3);
    flopr #(64) PP3reg(.clk, .reset, .D(QPP3), .Q(PP3M));
    mux2 #(64) PP4mux(PP4M, (PP4E & {64{~FlushM}}), noStallM, QPP4);
    flopr #(64) PP4reg(.clk, .reset, .D(QPP4), .Q(PP4M));

    // add up partial products; this multi-input add implies CSAs and a final CPA
    assign ProdM = PP1M + PP2M + PP3M + PP4M; //R1 * R2;

    always_comb begin
        case (Funct3M)
            3'b000: MulResult = ProdM[31:0];   // mul
            default: MulResult = ProdM[63:32];  // mulh
        endcase
    end


endmodule
