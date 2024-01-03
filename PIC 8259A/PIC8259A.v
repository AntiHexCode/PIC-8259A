module PIC8259A(
input CS,
input WR,
input RD,
input [7:0] DBus,
input [2:0] CASBus,
input GND,
input SPEN,
input [7:0] IRBus,
input INTA, 
input A0, 
input VCC,
output wire INT);



	wire [7:0] internalBus;

	
	wire rden;
	wire ICW1Flag, ICW2Flag, ICW3Flag, ICW4Flag;
	wire OCW1Flag, OCW2Flag, OCW3Flag;

	wire LTIM, SNGL, SFNM, AEOI, R, SL, EOI;
	wire [4:0] TReg;
	wire [7:0] SReg;
	wire [7:0] MReg;
  wire readIRR;
  wire readISR;
  wire readIMR;

  wire AR = (R && ~SL && EOI) || (R && ~SL && ~EOI) || (~R && ~SL && ~EOI) || (R && SL && EOI);
  wire decInterruptLocation;
  wire interruptLocation;


	/*
		!!!!!!!!!!!!!!!!! REMEMBER THAT !!!!!!!!!!!!!!!
		- input to an instance -> wire or reg
		- output from an instance -> wire
		- lookout for active low signals
		!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	*/




	RWLogic RWLInstance (
	.dataBus(DBus),         // input (external)
	.A0(A0),                // input (external)
	.CS(CS),                // input (external) (active low)
	.WR(WR),                // input (external) (active low)
	.RD(RD),                // input (external) (active low)
	.rden(rden),            // output (internal) (active low)
	.ICW1(ICW1Flag),        // output (internal)
	.ICW2(ICW2Flag),        // output (internal)
	.ICW3(ICW3Flag),        // output (internal)
	.ICW4(ICW4Flag),        // output (internal)
	.OCW1(OCW1Flag),        // output (internal)
	.OCW2(OCW2Flag),        // output (internal)
	.OCW3(OCW3Flag)         // output (internal)
	);




	controlLogic CLInstance (
	.A0(A0),                                   // input (internal)
	.rden(rden),                               // input (external)
	.ICW1flag(ICW1Flag),                       // input (internal)
	.ICW2flag(ICW2Flag),                       // input (internal)
	.ICW3flag(ICW3Flag),                       // input (internal)
	.ICW4flag(ICW4Flag),                       // input (internal)
	.OCW1flag(OCW1Flag),                       // input (internal)
	.OCW2flag(OCW2Flag),                       // input (internal)
	.OCW3flag(OCW3Flag),                       // input (internal)
	.DBus(DBus),                               // input (external)
	.LTIM(LTIM),                               // output (internal)
	.SNGL(SNGL),                               // output (internal)
	.TReg(TReg),                               // output (internal)
	.SReg(SReg),                               // output (internal)
	.SFNM(SFNM),                               // output (internal)
	.AEOI(AEOI),                               // output (internal)
	.MReg(MReg),                               // output (internal)
	.R(R),                                     // output (internal)
	.SL(SL),                                   // output (internal)
	.EOI(EOI),                                 // output (internal)
	.readIRR(readIRR),                         // output (internal)
	.readISR(readISR),                         // output (internal)
	.readIMR(readIMR)                          // output (internal)
	);



InterruptLogic ILInstance(

	.IRBus(IRBus),
	.LTIM(LTIM),
	.SFNM(SFNM),
	.AR(AR),
	.AEOI(AEOI),
	.TReg(TReg),
	.IMR(MReg),
	.readIRR(readIRR),
	.readISR(readISR),
	.readIMR(readIMR),
	.INTA(INTA),
	.INT(INT),
	.internalBus(internalBus),
	.decInterruptLocation(decInterruptLocation),
	.interruptLocation(interruptLocation)

);


endmodule



module PIC8259ATB();

  reg CS, WR, RD;
	reg [7:0] IRBus;
	reg GND, VCC;
	reg [7:0] DBus;
	reg A0, SPEN;
	reg [2:0] CASBus;
	reg INTA;
	wire INT;


	initial begin

		INTA = 1;
		SPEN = 1;
		VCC = 1;
		GND = 0;

	  //ICW1
    CS = 0;
    WR = 0;
    RD = 1;
    A0 = 0;
    DBus = 8'b00010011;
    #10;

    //ICW2
    A0 = 1;
    DBus = 8'b10010000;  // TReg = 5'b10010
    #10;

    /* SNGL = 1 (no ICW3)
    //ICW3 
    DBus = 8'b01001110;
    #10;
    */

    //ICW4
    DBus = 8'b00000010; // AEOI = 1'b1
    #10;

    //OCW1
    DBus = 8'b00001111; // IMR = 8'b00001111
    #10;

    //OCW2
    A0 = 0;
    DBus = 8'b00000000;
    #10;

    //OCW3
    DBus = 8'b00001011; // read ISR when RD and CS are active
    #10;

    IRBus = 8'b10101010;
    #10;

    INTA = 0;
    #5;
    INTA = 1;
    #5;
    INTA = 0;
    #5;
    INTA =1;
    #10;

  	// Read ISR (remembering OCW3)
    WR = 1;
    RD = 0;
    #10;

    //Stop
    CS = 1;
    RD = 1;
    #10;

	end	

	PIC8259A PICInstance(
	.CS(CS),
	.WR(WR),
	.RD(RD),
	.DBus(DBus),
	.CASBus(CASBus),
	.GND(GND),
	.SPEN(SPEN),
	.IRBus(IRBus),
	.INTA(INTA), 
	.A0(A0), 
	.VCC(VCC),
	.INT(INT)); 

endmodule 