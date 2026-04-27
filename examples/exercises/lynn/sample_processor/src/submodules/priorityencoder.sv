module priorityencoder(
    input logic[31:0] A,
    output logic[31:0] ZCount
    );

    logic [31:0] y;
    genvar i;

    logic [15:0] sixteens;
    logic [7:0] eights;
    logic [3:0] fours;
    logic [1:0] twos;
    logic [31:0] allZ, hasOne;

    assign allZ = 32;
    assign y[0] = A[0];
    for (i=1; i<32; i++) begin : poh
        assign y[i] = A[i] & ~|A[i-1:0];
    end
    assign hasOne[4] = ~|y[15:0];
    mux2 #(16) b4mux(y[15:0], y[31:16], hasOne[4], sixteens);
    mux2 #(8)  b3mux(sixteens[7:0], sixteens[15:8], ~|sixteens[7:0], eights);
    assign hasOne[3] = ~|sixteens[7:0];
    mux2 #(4)  b2mux(eights[3:0], eights[7:4], ~|eights[3:0], fours);
    assign hasOne[2] = ~|eights[3:0];
    mux2 #(2)  b1mux(fours[1:0], fours[3:2], ~|fours[1:0], twos);
    assign hasOne[1] = ~|fours[1:0];
    assign hasOne[0] = twos[1];
    assign hasOne[31:5] = 27'b0;

    assign ZCount = (A==32'b0) ? allZ : hasOne;
endmodule
