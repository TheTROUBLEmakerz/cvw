// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

module ifu(
        input   logic           clk, reset,
        input   logic           BranchPr, StallF, MisPredictE, PCSrcE,
        input   logic [31:0]    IEUAdrE, PCLinkE,PCD, ImmExtD, //PCPredict,
        output  logic [31:0]    PC
    );

    logic [31:0] PCNextF, NewPC, PCAdd, ImmAdd;
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

    mux2 #(32) PCmux(PC, PCD, BranchPr, PCAdd);
    mux2 #(32) Immmux(32'd4, ImmExtD, BranchPr, ImmAdd);
    adder pcadd4(PCAdd, ImmAdd, NewPC);

    always_comb begin
        if (MisPredictE) begin
            if (PCSrcE)
                PCNextF = {IEUAdrE[31:1], 1'b0};
            else
                PCNextF = PCLinkE;
        end
        else
            PCNextF = NewPC;
    end


    endmodule
