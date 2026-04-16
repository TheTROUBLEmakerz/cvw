//hazard unit for pipelined processor

module hazard(
        input  logic [4:0]  Rs1D, Rs2D,Rs1E, Rs2E,
        input  logic [4:0]  RdE,
        input  logic        MisPredictE, BranchPrD, IsMulE, IsMulM,
        input  logic [1:0]  ResultSrcE,
        input  logic [4:0]  RdM, RdW,
        input  logic        RegWriteM, RegWriteW,
        output logic        StallF, StallD,
        output logic        FlushD, FlushE,
        output logic        StallE, StallM, FlushM, StallW, FlushW, //these are all hardwired to 0
        output logic [1:0]  ForwardAE, ForwardBE
    );
    logic lwStall, mulStall;

    always_comb
    begin
        if (((Rs1E == RdM) & RegWriteM & !IsMulM) & (Rs1E != 0))
            ForwardAE = 2'b10;
        else if (((Rs1E == RdW) & RegWriteW) & (Rs1E != 0))
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;
        if (((Rs2E == RdM) & RegWriteM & !IsMulM) & (Rs2E != 0))
            ForwardBE = 2'b10;
        else if (((Rs2E == RdW) & RegWriteW) & (Rs2E != 0))
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end


    assign mulStall = (IsMulE && (RdE != 5'd0) && ((Rs1D == RdE) || (Rs2D == RdE))) ||
                        (IsMulM && (RdM != 5'd0) && ((Rs1D == RdM) || (Rs2D == RdM)));

    assign lwStall = (ResultSrcE == 2'b01) && (RdE != 5'd0) && ((Rs1D == RdE) || (Rs2D == RdE));
    assign StallF = lwStall || mulStall;
    assign StallD = lwStall || mulStall;
    assign StallE = 0;
    assign StallM = 0;
    assign FlushM = 0;
    assign StallW = 0;
    assign FlushW = 0;

    assign FlushD = MisPredictE | BranchPrD; //
    assign FlushE = lwStall | mulStall | MisPredictE;

endmodule
