module multiplier (
    input  logic clk, reset,
    input  logic [31:0] R1,
    input  logic [31:0] R2,
    input  logic [2:0]  Funct3,
    input  logic [2:0]  Funct3M,
    output logic [31:0] MulResult,
    input  logic        FlushM, noStallM
);
    logic a_sign, b_sign;
    logic [32:0] a33, b33;
    logic signed [65:0] prod66;
    logic [32:0] QAout, QBout, a33M, b33M;

    // Execute Stage
    // Sign extend
    always_comb begin
    unique case (Funct3)
        3'b001: begin a_sign = R1[31]; b_sign = R2[31]; end // mulh
        3'b010: begin a_sign = R1[31]; b_sign = 1'b0;   end // mulhsu
        3'b011: begin a_sign = 1'b0;   b_sign = 1'b0;   end // mulhu
        default:begin a_sign = R1[31]; b_sign = R2[31]; end // mul
    endcase
    end
    assign a33 = {a_sign, R1};
    assign b33 = {b_sign, R2};

    mux2 #(33) Amux(a33M, (a33 & {33{~FlushM}}), noStallM, QAout);
    flopr #(33) Areg(.clk, .reset, .D(QAout), .Q(a33M));

    mux2 #(33) Bmux(b33M, (b33 & {33{~FlushM}}), noStallM, QBout);
    flopr #(33) Breg(.clk, .reset, .D(QBout), .Q(b33M));

    assign prod66 = $signed(a33M) * $signed(b33M);
    always_comb begin
        MulResult = (Funct3M == 3'b000) ? prod66[31:0] : prod66[63:32];
    end
endmodule
