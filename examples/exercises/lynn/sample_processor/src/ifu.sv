// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

module ifu(
        input   logic           clk, reset,
        input   logic           PCSrcE, StallF,
        input   logic [31:0]    IEUAdrE,
        output  logic [31:0]    PC
    );

    logic [31:0] PCNextF, PCPlus4F;
    // next PC logic
    logic [31:0] entry_addr;

    initial begin
        // default
        entry_addr = '0;

        // override if provided
        void'($value$plusargs("ENTRY_ADDR=%h", entry_addr));

        $display("[TB] ENTRY_ADDR = 0x%h", entry_addr);
    end

    always_ff @(posedge (clk & StallF)) begin
    if (reset)  PC <= entry_addr;
    else        PC <= PCNextF;
    end

    adder pcadd4(PC, 32'd4, PCPlus4F);

    mux2 #(32) pcmux(PCPlus4F, {IEUAdrE[31:1], 1'b0}, PCSrcE, PCNextF);
endmodule
