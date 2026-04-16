// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

module ifu(
        input   logic           clk, reset,
        input   logic           BranchPr, StallF, MisPredictE, PCSrcE,
        input   logic [31:0]    IEUAdrE, PCPredict, PCPlus4E,
        output  logic [31:0]    PC, PCPlus4F
    );

    logic [31:0] PCNextF;
    // next PC logic
    logic [31:0] entry_addr;

    initial begin
        // default
        entry_addr = '0;

        // override if provided
        void'($value$plusargs("ENTRY_ADDR=%h", entry_addr));

        $display("[TB] ENTRY_ADDR = 0x%h", entry_addr);
    end

    always_ff @(posedge clk) begin
    if (reset)  PC <= entry_addr;
    else if (~StallF)       PC <= PCNextF;
    end

    adder pcadd4(PC, 32'd4, PCPlus4F);

    always_comb begin
        if (MisPredictE) begin
            if (PCSrcE)
                PCNextF = {IEUAdrE[31:1], 1'b0};
            else
                PCNextF = PCPlus4E;
        end
        else if (BranchPr) begin
            PCNextF = PCPredict;
        end
        else begin
            PCNextF = PCPlus4F;
        end
    end


    endmodule
