// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module datapath(
        input   logic           clk, reset,//
        input   logic [31:0]    Rd1E, Rd2E, ImmExtE,//
        input   logic [2:0]     Funct3E,//
        input   logic [6:0]     Funct7E, //
        input   logic [1:0]     ALUControlE, //
        output  logic           Eq, Lt, //
        input   logic [31:0]    PCE, //
        output  logic [31:0]    IEUAdrE, FSrcBE, FSrcAE, IEUResultE, PCLinkE,//
        input   logic           IsZbaE, IsZbbE,
        input   logic           JumpE,//
        input   logic [1:0]     ALUResultSrcE, ALUSrcE, //
        input   logic [31:0]    extout, ResultW, //
        input   logic [1:0]     ForwardAE, ForwardBE //
    );

    logic [31:0] SrcAE, SrcBE, ALUResultE, AltResultE, shaddout, revCZ, revB8, ZeroCount, OnesCount, CZ, Count;
    logic [31:0] MulResult, CalcOut; //for mult unit
    logic [31:0] ExecResult, minmaxout;  // ALUResult with optional MUL override
    logic [2:0] ALUFunct3E;
    logic [31:0] orcb, sextb, sexth, zexth, extdbmu, izbbout;
    logic countsel;

    mux3 #(32) top3mux(Rd1E, ResultW, extout, ForwardAE, FSrcAE);
    mux3 #(32) bot3mux(Rd2E, ResultW, extout, ForwardBE, FSrcBE);
    cmp cmp(.R1(FSrcAE), .R2(FSrcBE), .unsignedCmp((Funct3E[1] & ~IsZbbE) | (IsZbbE & Funct3E[0])), .Eq, .Lt);
    // logic for selecting min / max
    mux2 #(32) minmaxmux(FSrcBE, FSrcAE, Funct3E[1]^Lt, minmaxout);
    mux3 #(32) shaddmux({FSrcAE[28:0], 3'b000}, {FSrcAE[29:0], 2'b00}, {FSrcAE[30:0], 1'b0}, ~Funct3E[2:1], shaddout);
    mux3 #(32) srcamux(FSrcAE, PCE, shaddout, {IsZbaE, ALUSrcE[1]}, SrcAE);
    mux2 #(32) srcbmux(FSrcBE, ImmExtE, ALUSrcE[0], SrcBE);

    assign ALUFunct3E = IsZbaE ? 3'b000 : Funct3E;
    alu alu(.SrcA(SrcAE), .SrcB(SrcBE), .ALUControl(ALUControlE), .Funct3(ALUFunct3E), .IsZbaE, .ALUResult(ALUResultE), .IEUAdr(IEUAdrE), .Funct7E, .IsZbbE);
    // multiplier multiplier(.R1(FSrcAE), .R2(FSrcBE), .funct3(Funct3E), .MulResult, .IsZbbE); // need to look later really wrong

    // mux2 #(32) ieuresultmux(ALUResult, PCPlus4, ALUResultSrc, IEUResult);
    // mux4 #(32) resultmux(CalcOut, ImmLoad, ImmExt, CSRout, ResultSrc, Result);

    adder pcadd4E(PCE, 32'd4, PCLinkE);
    mux2 #(32) altmux(ImmExtE, PCLinkE, JumpE, AltResultE);

    // reversals
    reversal #(1) revC(FSrcAE, revCZ); // reverse for clz instr
    reversal #(8) revB(FSrcAE, revB8); // rev8 instr

    assign CZ = ImmExtE[0] ? FSrcAE : revCZ;

    // count bits
    priorityencoder countzero(CZ, ZeroCount);
    cpop cpop(FSrcAE, OnesCount);

    mux2 #(32) countmux(ZeroCount, OnesCount, ImmExtE[1], Count);

    // extenders
    assign zexth = {16'b0, FSrcAE[15:0]};
    assign sextb = {{24{FSrcAE[7]}}, FSrcAE[7:0]};
    assign sexth = {{16{FSrcAE[15]}}, FSrcAE[15:0]};

    // combine bytes
    assign orcb = {{8{|FSrcAE[31:24]}}, {8{|FSrcAE[23:16]}}, {8{|FSrcAE[15:8]}}, {8{|FSrcAE[7:0]}}};

    mux4 #(32) extdmux(zexth, sextb, orcb, sexth, {ImmExtE[0],ImmExtE[1] ^ ImmExtE[2]}, extdbmu);

    assign countsel = (Funct3E == 3'b001) & ~ImmExtE[2];
    mux3 #(32) ibmumux(extdbmu, Count, revB8, {ImmExtE[3], countsel}, izbbout);

    // final big mux
    mux4 #(32) ieuresultmux(ALUResultE, AltResultE, minmaxout, izbbout, ALUResultSrcE, IEUResultE); // TODO - add minmaxout



/////////////////////////////////
    // mux2 #(32) mulmux(ALUResult, MulResult, IsMul, ExecResult); // look later


    // move this part to ieu
    // mux4 #(32) resultmux(CalcOut, ImmLoad, ImmExt, CSRout, ResultSrc, Result);
    // ext2 ext2(Funct3, IEUAdr[2:0], ReadData, ImmLoad); // this is for load/store
    // assign WriteData = FSrcBE;
    // load store unit stuff need to be fixed
endmodule
