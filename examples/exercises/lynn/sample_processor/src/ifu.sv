// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020 kacassidy@hmc.edu 2025

module ifu(
        input   logic           clk, reset,
        input   logic           StallF, MisPredictE, PCSrcE,
        input   logic [31:0]    IEUAdrE, PCLinkE,PCD, Instr,
        output  logic [31:0]    PC, ImmExt,
        output  logic           BranchPr
    );

    logic [2:0]  ImmSrc;
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

    // mux2 #(32) PCmux(PC, PCD, BranchPr, PCAdd);
    // mux2 #(32) Immmux(32'd4, ImmExt, BranchPr, ImmAdd);
    assign BranchPr = (Instr[6:0] == 7'b1100011) && Instr[31];
    // mux2 #(32) PCmux(PC, PCNextF, (Instr[6:0] == 7'b1100011) && Instr[31], PCAdd);
    mux2 #(32) Immmux(32'd4, ImmExt, BranchPr, ImmAdd);

    adder pcadd4(PC, ImmAdd, NewPC);

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
    always_comb
        case(Instr[6:2])
            // RegWrite_ImmSrc_ALUSrc_ALUOp_ALUResultSrc_MemWrite_ResultSrc_Branch_Jump_Load
            5'b00000: ImmSrc = 3'b000; // lw
            5'b01000: ImmSrc = 3'b001; // sw
            5'b01100: ImmSrc = 3'b000; // R-type
            5'b00100: ImmSrc = 3'b000; // I-type ALU
            5'b11000: ImmSrc = 3'b010; // b-type
            5'b11011: ImmSrc = 3'b011; // jal
            5'b11001: ImmSrc = 3'b000; // jalr
            5'b01101: ImmSrc = 3'b111; // lui
            5'b00101: ImmSrc = 3'b111; // auipc
            5'b11100: ImmSrc = 3'b000; // CSR
            default:    ImmSrc = 3'b0;

        endcase

    extend ext(.Instr(Instr[31:7]), .ImmSrc(ImmSrc), .ImmExt(ImmExt));

    endmodule
