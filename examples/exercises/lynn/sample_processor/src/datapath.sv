// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module datapath(
        input   logic           clk, reset,//
        input   logic [31:0]    Rd1E, Rd2E, ImmExtE,//
        input   logic [2:0]     Funct3E,//
        input   logic           Funct7b5E, //
        input   logic [1:0]     ALUControlE, //
        output  logic           Eq, Lt, //
        input   logic [31:0]    PCE, //
        output  logic [31:0]    IEUAdrE, FSrcBE, FSrcAE, IEUResultE, PCLinkE,//
        input   logic           IsZbaE,
        input   logic           ALUResultSrcE, JumpE,//
        input   logic [1:0]     ALUSrcE, //
        input   logic [31:0]    extout, ResultW, //
        input   logic [1:0]     ForwardAE, ForwardBE //
    );

    logic [31:0] SrcAE, SrcBE, ALUResultE, AltResultE, shaddout;
    logic [31:0] MulResult, CalcOut; //for mult unit
    logic [31:0] ExecResult, minmaxout;  // ALUResult with optional MUL override
    logic [2:0] ALUFunct3E;

    mux3 #(32) top3mux(Rd1E, ResultW, extout, ForwardAE, FSrcAE);
    mux3 #(32) bot3mux(Rd2E, ResultW, extout, ForwardBE, FSrcBE);
    cmp cmp(.R1(FSrcAE), .R2(FSrcBE), .unsignedCmp(Funct3E[1] | (IsZbbE & Funct3E[0])), .Eq, .Lt);
    // logic for selecting min / max
    mux2 #(32) minmaxmux(FSrcBE, FSrcAE, Funct3E[1]^Lt, minmaxout);
    mux3 #(32) shaddmux({FSrcAE[28:0], 3'b000}, {FSrcAE[29:0], 2'b00}, {FSrcAE[30:0], 1'b0}, ~Funct3E[2:1], shaddout);
    mux3 #(32) srcamux(FSrcAE, PCE, shaddout, {IsZbaE, ALUSrcE[1]}, SrcAE);
    mux2 #(32) srcbmux(FSrcBE, ImmExtE, ALUSrcE[0], SrcBE);

    assign ALUFunct3E = IsZbaE ? 3'b000 : Funct3E;
    alu alu(.SrcA(SrcAE), .SrcB(SrcBE), .ALUControl(ALUControlE), .Funct3(ALUFunct3E), .ALUResult(ALUResultE), .IEUAdr(IEUAdrE), .Funct7b5E);
    // multiplier multiplier(.R1(FSrcAE), .R2(FSrcBE), .funct3(Funct3E), .MulResult); // need to look later really wrong

    // mux2 #(32) ieuresultmux(ALUResult, PCPlus4, ALUResultSrc, IEUResult);
    // mux4 #(32) resultmux(CalcOut, ImmLoad, ImmExt, CSRout, ResultSrc, Result);

    adder pcadd4E(PCE, 32'd4, PCLinkE);
    mux2 #(32) altmux(ImmExtE, PCLinkE, JumpE, AltResultE);
    mux2 #(32) ieuresultmux(ALUResultE, AltResultE, ALUResultSrcE, IEUResultE); // TODO - add minmaxout



/////////////////////////////////
    // mux2 #(32) mulmux(ALUResult, MulResult, IsMul, ExecResult); // look later


    // move this part to ieu
    // mux4 #(32) resultmux(CalcOut, ImmLoad, ImmExt, CSRout, ResultSrc, Result);
    // ext2 ext2(Funct3, IEUAdr[2:0], ReadData, ImmLoad); // this is for load/store
    // assign WriteData = FSrcBE;
    // load store unit stuff need to be fixed
endmodule
