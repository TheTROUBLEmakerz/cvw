module alu(
    input  logic [31:0] SrcA, SrcB,
    input  logic [1:0]  ALUControl,
    input  logic [2:0]  Funct3,
    input  logic [6:0]  Funct7E,
    input  logic        IsZbbE,IsZbaE,
    output logic [31:0] ALUResult, IEUAdr
);

    logic [31:0] CondInvb, Sum, SLT, CondInvb2;
    logic [31:0] AddSum;
    logic       ALUOp, Sub, Overflow, Neg, LT;
    logic [2:0]  ALUFunct;
    logic [63:0] midALUResult;
    logic isShiftRight;

    assign {Sub, ALUOp} = ALUControl;

    // Always-add path for addresses/targets
    assign AddSum = SrcA + SrcB;
    assign IEUAdr = AddSum;

    // Add/sub path for ALUResult when needed
    assign CondInvb = Sub ? ~SrcB : SrcB;
    assign CondInvb2 = Sub ? (~SrcB + 32'b1) : SrcB;
    assign Sum      = SrcA + CondInvb2;

    // SLT (signed) based on subtraction result
    assign Overflow = Sub &
                  (SrcA[31] ^ SrcB[31]) &
                  (SrcA[31] ^ Sum[31]);
    assign Neg      = Sum[31];
    assign LT       = Neg ^ Overflow;
    assign SLT      = {31'b0, LT};

    assign ALUFunct = (Funct3 & {3{ALUOp}}) ^ {1'b0, ~Funct7E[4] & IsZbbE & ALUOp & ~Funct3[0], 1'b0};
    //assign SrcA64 = {32'b0, SrcA};
    always_comb begin
        case (ALUFunct)
            3'b000: midALUResult = {32'b0, Sum};
            3'b010: midALUResult = {32'b0, SLT};
            3'b100: midALUResult = {32'b0, SrcA ^ CondInvb};
            3'b110: midALUResult = {32'b0, SrcA | CondInvb};
            3'b111: midALUResult = {32'b0, SrcA & CondInvb};
            3'b001: midALUResult = {32'b0, SrcA} << SrcB[4:0];
            3'b011: midALUResult = {63'b0, (SrcA < SrcB)};  // SLTU (unsigned)
            3'b101: begin
                if (Funct7E[5] & ~Funct7E[4]) begin
                    // SRA: manual sign-fill (no reliance on >>>)
                    if (SrcB[4:0] == 0)
                        midALUResult = {32'b0, SrcA};
                    else
                        midALUResult = {32'b0, $signed(SrcA) >>> SrcB[4:0]};
                    end else begin
                        // SRL
                        midALUResult = {SrcA, 32'b0} >> SrcB[4:0];
                    end
                end
            default: midALUResult = '0; // (use 0 instead of 'x to avoid X-prop)
        endcase
    end

    // assign ALUResult = IsZbbE ? midALUResult[63:32] | midALUResult[31:0]
    //                     : ((Funct7E==7'b0) & (Funct3==3'b101) ? midALUResult[63:32] : midALUResult[31:0]); //choose top only if srl


    assign isShiftRight =
        ALUOp &&
        !IsZbbE &&
        !IsZbaE &&
        (Funct3 == 3'b101) &&
        !(Funct7E[5] & ~Funct7E[4]); // only SRL/SRLI uses upper half

    assign ALUResult =
        IsZbbE ? (midALUResult[63:32] | midALUResult[31:0]) :
        isShiftRight ? midALUResult[63:32] :
        midALUResult[31:0];

    //assign ALUResult = (Funct7E==7'b0 & Funct3==3'b101 ? midALUResult[63:32] : midALUResult[31:0]); //choose top only if srl
endmodule
