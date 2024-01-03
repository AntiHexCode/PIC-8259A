module RWLogic (
input [7:0] dataBus,
input A0,
input CS,
input WR,
input RD,
output wire wren,
output wire rden,
output reg ICW1,
output reg ICW2,
output reg ICW3,
output reg ICW4,
output reg OCW1,
output reg OCW2,
output reg OCW3);

/*
  -Write:  This block deals with the Command Words from the 8086, 
           Sequence goes like this: 8086 sends all it command words to be written
           by the read write logic, once written it raises a flag to the 
           control logic in order to parse the useful bits for other blocks to work, this block also supports
           circular write mode of command words, once command words are sent all states are reset for another round 
           of command words writing.
  -Read: Read IRR, ISR (OCW3) or IMR (A0)
*/


//Write and Read logic
//Assigning the flags
  reg Init;
  wire SNGL;
  wire ICW4Bit;

//1) Assigning the active low values
    wire WRBar = ~WR;
    wire RDBar = ~RD;
    wire CSBar = ~CS;

    //2) Checking for write and read command
    and(wren,WRBar,CSBar);
    and(RDen,RDBar,CSBar);

    //3)Changing states
    reg[3:0] statesReg;
    reg clk;
    initial begin
    clk = 1;
    forever #5 clk = ~clk; // Toggle the clock every 5 time units
    end
    
    //4)ICWs block
    always @(posedge clk) begin
        //Basis conditions
        if(SNGL && ~ICW4Bit)begin
          ICW4 <=0;
          ICW3 <=0;
          statesReg[2] <=0;
          statesReg[3] <=0;
        end
        else if(SNGL) begin
          ICW3 <=0;
          statesReg[2] <=0;
        end
        else if(~ICW4Bit)begin
          ICW4 <= 0;
          statesReg[3] <=0;
        end
        
        //ICW1 state
        if(~A0 && dataBus[4] && wren) begin
            ICW1 <=1;
            statesReg[0] <=1;
        end
        
        //ICW2 state
        else if(ICW1 && A0 && wren) begin
            //ICW2 <= (A0 & wren & ICW1Flag) ;
            ICW1 <= 0;
            ICW2 <=1;
            statesReg[1] <=1;
        end
        //ICW3 state
        else if(ICW2 && (~SNGL) && A0) begin
            ICW2 <= 0;
            ICW3 <= 1;
            statesReg[2] <=1;
        end
        //ICW4 in case ICW3 exists
        else if(ICW3 && A0 && ICW4Bit && ~dataBus[7] && ~dataBus[6] && ~dataBus[5])begin
            ICW3 <= 0;
            ICW4 <= 1 ;
            statesReg[3] <=1;
        end
        //ICW4 in case ICW3 is missing
        else if(ICW2 && SNGL && ICW4Bit && A0 && ~dataBus[7] && ~dataBus[6] && ~dataBus[5]) begin
            ICW2 <=0;
            ICW4 <=1;
            statesReg[3] <=1;
        end
        //Safety conditions
        if(ICW4)begin
          ICW4 <=0;
        end
        else if (~ICW4Bit && SNGL && ICW2)begin
          ICW2 <=0;
        end
        else if(~ICW4Bit && ~SNGL && ICW3)begin
          ICW3 <=0;
        end
    end
    
    //5)OCWs block
    always @(negedge clk)begin
      /*************Evaluating Init*************/
      //1)Only ICW1 and ICW2
      if(statesReg[0] && statesReg[1] && SNGL && ~ICW4Bit)begin
        Init <=1;
      end
      //2) All ICWs exist
      else if(statesReg[0] && statesReg[1] && statesReg[2] &&statesReg[3])
      begin
        Init <=1;
      end
      //3)ICW3 missing
      else if(statesReg[0] && statesReg[1] && statesReg[3] && SNGL)
      begin
        Init<=1;
      end
      //4) ICW4 missing
      else if(statesReg[0] && statesReg[1] && statesReg[2] && ~ICW4Bit)
      begin
        Init <=1;
      end
    end
    
    /**********Writing OCWs*****************/
    always @(posedge clk)begin 
      //1) OCW1
      if(A0 && Init)begin
        OCW1 <=1;
      end
      //2) OCW2
      else if(Init && ~A0 && ~dataBus[3] && ~dataBus[4] && OCW1)begin
        OCW1 <=0;
        OCW2<=1;
      end
      //3) OCW3
      else if(Init && ~A0 && ~dataBus[7] && ~dataBus[4] && dataBus[3] && OCW2 )begin
        OCW3 <=1;
        OCW2 <=0;
      end
      
      //Reset condition after all Command words are recieved to allow for another round of command words
      if(OCW3)begin
        OCW3 <=0;
        Init<=0;
        statesReg = 4'b0000;
      end
    end
    
    //Won't be deleted for legacy reasons
    DFlipFlop SNGLFF(ICW1,0,dataBus[1],SNGL);
    DFlipFlop ICW4FF(ICW1,0,dataBus[0],ICW4Bit);


endmodule 




module DFlipFlop(input wire clk,input wire reset ,input wire d,output reg q);
    always @(posedge clk,reset) begin
        if(reset) begin
            q <= 1'b0;
        end
        else begin
            q <=d;
        end
    end
endmodule




module RWLogicTB();
  reg A0,CS,WR;
  reg[7:0] dataBus;
  initial begin
    //ICW1
    A0 = 0;
    dataBus = 8'b00010001;
    CS = 0;
    WR = 0;
    #10
    //ICW2
    A0 = 1;
    dataBus = 8'b01000000;
    CS = 0;
    WR = 0;
    #10
    //ICW3 
    A0 = 1;
    dataBus = 8'b01000010;
    CS = 0;
    WR = 0;
    #10
    //ICW4
    A0 =1;
    dataBus = 8'b00010010;
    CS = 0;
    WR = 0;
    #10
    //OCW1
    A0 = 1;
    dataBus = 8'b00000011;
    #10
    //OCW2
    A0 = 0;
    dataBus = 8'b00000111;
    #10
    //OCW3
    A0 = 0;
    dataBus = 8'b01101010;
  end
  RWLogic RWL1(.A0(A0),.CS(CS),.WR(WR),.dataBus(dataBus));
endmodule
