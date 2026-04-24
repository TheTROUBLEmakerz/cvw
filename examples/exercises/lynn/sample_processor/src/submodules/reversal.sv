module reversal #(parameter N=1) (
    input logic[31:0] A,
    output logic[31:0] revA
    );

    genvar i;

    for (i=0; i<32/N; i++) begin : rev
        assign revA[(i+1)*N-1 : i*N] = A[31-i*N: 31-((i+1)*N-1)];
    end
endmodule
