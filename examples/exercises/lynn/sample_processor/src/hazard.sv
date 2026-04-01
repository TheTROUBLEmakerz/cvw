//hazard unit for pipelined processor

module hazard(
        input  logic [4:0]  Rs1D, Rs2D,Rs1E, Rs2E,
        input  logic [4:0]  RdE,
        input  logic        PCSrcE, ResultSrcE0,
        input  logic [4:0]  RdM, RdW,
        input  logic        RegWriteM, RegWriteW,
        output logic        StallF, StallD,
        output logic        FlushD, FlushE,
        output logic        StallE, StallM, FlushM, StallW, FlushW, //these are all hardwired to 0
        output logic [1:0]  ForwardAE, ForwardBE
    );
    logic lwStall;

    always_comb
    begin
        if (((Rs1E == RdM) & RegWriteM) & (Rs1E != 0))
            ForwardAE = 2'b10;
        else if (((Rs1E == RdW) & RegWriteW) & (Rs1E != 0))
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;
        if (((Rs2E == RdM) & RegWriteM) & (Rs2E != 0))
            ForwardBE = 2'b10;
        else if (((Rs2E == RdW) & RegWriteW) & (Rs2E != 0))
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end

    assign lwStall = ResultSrcE0 & ((Rs1D == RdE) | (Rs2D == RdE));
    assign StallF = lwStall;
    assign StallD = lwStall;
    assign StallE = 0;
    assign StallM = 0;
    assign FlushM = 0;
    assign StallW = 0;
    assign FlushW = 0;

    assign FlushD = PCSrcE; //
    assign FlushE = lwStall | PCSrcE;

endmodule
