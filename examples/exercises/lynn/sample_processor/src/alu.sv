module alu(
    input  logic [31:0] SrcA, SrcB,
    input  logic [1:0]  ALUControl,
    input  logic [2:0]  Funct3,
    input  logic [6:0]  Funct7E,
    input  logic        IsZbbE,IsZbaE,
    output logic [31:0] ALUResult, IEUAdr
);

    logic [31:0] CondInvb, Sum, SLT, CondInvb2;
    logic [31:0] AddSum, revSrcA, shiftSrcA, revALUResult, ALUFinal;
    logic       ALUOp, Sub, Overflow, Neg, LT;
    logic [2:0]  ALUFunct;
    logic [63:0] midALUResult;
    logic isShiftRight;

    assign {Sub, ALUOp} = ALUControl;

    // Always-add path for addresses/targets
    assign AddSum = SrcA + SrcB;
    assign IEUAdr = AddSum;

    // Add/sub path for ALUFinal when needed
    assign CondInvb = Sub ? ~SrcB : SrcB;
    assign CondInvb2 = Sub ? (~SrcB + 32'b1) : SrcB;
    assign Sum      = SrcA + CondInvb2;
    reversal #(1) revA(SrcA, revSrcA);
    // SLT (signed) based on subtraction result
    assign Overflow = Sub &
                  (SrcA[31] ^ SrcB[31]) &
                  (SrcA[31] ^ Sum[31]);
    assign Neg      = Sum[31];
    assign LT       = Neg ^ Overflow;
    assign SLT      = {31'b0, LT};

    assign shiftSrcA = (Funct3==3'b001) ? revSrcA: SrcA;

    assign ALUFunct = (Funct3 & {3{ALUOp}}); // ^ {1'b0, ~Funct7E[4] & IsZbbE & ALUOp & ~Funct3[0], 1'b0};
    //assign SrcA64 = {32'b0, SrcA};
    always_comb begin
        case (ALUFunct)
            3'b000: begin
                        ALUFinal = Sum;
                        midALUResult = 64'b0;
                    end
            3'b010: begin
                        ALUFinal = SLT;
                        midALUResult = 64'b0;
                    end
            3'b100: begin
                        ALUFinal = SrcA ^ CondInvb;
                        midALUResult = 64'b0;
                    end
            3'b110: begin
                        ALUFinal = SrcA | CondInvb;
                        midALUResult = 64'b0;
                    end
            3'b111: begin
                        ALUFinal =  SrcA & CondInvb;
                        midALUResult = 64'b0;
                    end
            3'b011: begin
                        ALUFinal = {31'b0, (SrcA < SrcB)};  // SLTU (unsigned)
                        midALUResult = 64'b0;
                    end
            3'b001, 3'b101: begin
                if (Funct7E[5] & ~Funct7E[4]) begin
                    // SRA: manual sign-fill (no reliance on >>>)
                    if (SrcB[4:0] == 0) begin
                        ALUFinal = shiftSrcA;
                        midALUResult = 64'b0;
                    end else begin
                        midALUResult = {32'b0, $signed(shiftSrcA) >>> SrcB[4:0]};
                        ALUFinal = (IsZbbE) ? midALUResult[63:32] | midALUResult[31:0] : midALUResult[31:0];
                        end
                    end else begin
                        // SRL
                        midALUResult = {shiftSrcA, 32'b0} >> SrcB[4:0];
                        ALUFinal = (IsZbbE) ? midALUResult[63:32] | midALUResult[31:0] : midALUResult[63:32];
                    end
                end
            default: begin
                        ALUFinal = '0; // (use 0 instead of 'x to avoid X-prop)
                        midALUResult = 64'b0;
                    end
        endcase
    end

    reversal #(1) revRes(ALUFinal, revALUResult);

    assign ALUResult = (ALUFunct==3'b001) ? revALUResult : ALUFinal;
    // assign ALUFinal = IsZbbE ? midALUResult[63:32] | midALUResult[31:0]
    //                     : ((Funct7E==7'b0) & (Funct3==3'b101) ? midALUResult[63:32] : midALUResult[31:0]); //choose top only if srl


    /* assign isShiftRight =
        ALUOp &&
        !IsZbbE &&
        !IsZbaE &&
        (Funct3 == 3'b101) &&
        !(Funct7E[5] & ~Funct7E[4]); // only SRL/SRLI uses upper half

    assign ALUFinal =
        IsZbbE ? (midALUResult[63:32] | midALUResult[31:0]) :
        isShiftRight ? midALUResult[63:32] :
        midALUResult[31:0]; */

    //assign ALUFinal = (Funct7E==7'b0 & Funct3==3'b101 ? midALUResult[63:32] : midALUResult[31:0]); //choose top only if srl
endmodule
