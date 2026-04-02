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
        output  logic [31:0]    IEUAdrE, FSrcBE, IEUResultE, //
        input   logic [31:0]    CSRout,
        input   logic           IsMul,
        input   logic           ALUResultSrcE, JumpE,//
        input   logic [1:0]     ALUSrcE, //

        input   logic [31:0]    IEUResultM, ResultW, //
        input   logic [1:0]     ForwardAE, ForwardBE //
    );

    logic [31:0] FSrcAE, SrcAE, SrcBE, PCLinkE, ALUResultE, AltResultE;
    logic [31:0] MulResult, CalcOut; //for mult unit
    logic [31:0] ExecResult;  // ALUResult with optional MUL override

    mux3 #(32) top3mux(Rd1E, ResultW, IEUResultM, ForwardAE, FSrcAE);
    mux3 #(32) bot3mux(Rd2E, ResultW, IEUResultM, ForwardBE, FSrcBE);
    cmp cmp(.R1(FSrcAE), .R2(FSrcBE), .unsignedCmp(Funct3E[1]), .Eq, .Lt);

    mux2 #(32) srcamux(FSrcAE, PCE, ALUSrcE[1], SrcAE);
    mux2 #(32) srcbmux(FSrcBE, ImmExtE, ALUSrcE[0], SrcBE);

    alu alu(.SrcA(SrcAE), .SrcB(SrcBE), .ALUControl(ALUControlE), .Funct3(Funct3E), .ALUResult(ALUResultE), .IEUAdr(IEUAdrE), .Funct7b5E);
    // multiplier multiplier(.R1(FSrcAE), .R2(FSrcBE), .funct3(Funct3E), .MulResult); // need to look later really wrong

    // mux2 #(32) ieuresultmux(ALUResult, PCPlus4, ALUResultSrc, IEUResult);
    // mux4 #(32) resultmux(CalcOut, ImmLoad, ImmExt, CSRout, ResultSrc, Result);

    adder pcadd4E(PCE, 32'd4, PCLinkE);
    mux2 #(32) altmux(ImmExtE, PCLinkE, JumpE, AltResultE);
    mux2 #(32) ieuresultmux(ALUResultE, AltResultE, ALUResultSrcE, IEUResultE);



/////////////////////////////////
    // mux2 #(32) mulmux(ALUResult, MulResult, IsMul, ExecResult); // look later


    // move this part to ieu
    // mux4 #(32) resultmux(CalcOut, ImmLoad, ImmExt, CSRout, ResultSrc, Result);
    // ext2 ext2(Funct3, IEUAdr[2:0], ReadData, ImmLoad); // this is for load/store
    // assign WriteData = FSrcBE;
    // load store unit stuff need to be fixed
endmodule
