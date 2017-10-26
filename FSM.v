module FSM(clk, reset, s, w, opcode, op, nsel,loada,loadb,loadc,vsel,write,loads,asel,bsel,reset_pc,load_pc,addr_sel,mem_cmd);
  input clk, reset, s;
  input [2:0] opcode;
  input [1:0] op;
  output w;
  output reg [2:0] nsel;
  output reg loada,loadb,loadc,loads,write,asel,bsel,load_pc,reset_pc,addr_sel;
  output reg [1:0] vsel, mem_cmd; 
  wire [2:0] state;
  reg load_s;
  reg [2:0] next_state;
  
  //State encoding for the FSM circuit 
  `define S0 3'b000
  `define S1 3'b001
  `define S2 3'b010
  `define S3 3'b011
  `define S4 3'b100

  assign w = load_s ? 1'b0:1'b1; //reset_state is 1 when reset is pressed and stays 1 until s is pressed
  assign state =  reset ? `S0:next_state;
  //Check reset state 
  always @(posedge clk) begin
    casex({reset,w,s,opcode,op,state})
	11'b1xxxxxxxxxx: {load_s, nsel, next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel} 
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //reset!
	{8'bx10xxxxx,`S0}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //keep waiting until s is set to 1 (reset state)
	{8'bx1111010,`S0}: {load_s, nsel, next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel} 
				= {1'b1,3'b001,`S1,1'b0,1'b0,1'b0,2'b10,1'b1,1'b0,1'b0,1'b0}; //s is set to 1, opcode = 110, op = 10, then we write
	{8'b00x11010,`S1}: {load_s, nsel, next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel} 
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //now we are done writing so we go back to waiting in reset state 
        {8'b01111000,`S0}: {load_s, nsel, next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel} 
				= {1'b1,3'b100,`S1,1'b0,1'b1,1'b0,2'b10,1'b0,1'b0,1'b0,1'b0}; //this is for Mov Rm value into Rd with shift, so start by placing Rm into b
	{8'b00x11000,`S1}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b000,`S2,1'b0,1'b0,1'b1,2'b00,1'b0,1'b0,1'b1,1'b0}; //now we store the value into C
	{8'b00x11000,`S2}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b010,`S3,1'b0,1'b0,1'b0,2'b00,1'b1,1'b0,1'b0,1'b0}; //now write to register Rd
	{8'b00x11000,`S3}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //back to reset_state
	{8'b01110100,`S0}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b001,`S1,1'b1,1'b0,1'b0,2'b10,1'b0,1'b0,1'b0,1'b0}; //This is for addition, place Rn to RegA
	{8'b00x10100,`S1}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b100,`S2,1'b0,1'b1,1'b0,2'b10,1'b0,1'b0,1'b0,1'b0}; //Now set RegA to Rm
	{8'b00x10100,`S2}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b000,`S3,1'b0,1'b0,1'b1,2'b00,1'b0,1'b0,1'b0,1'b0}; //Now we set it to RegC
	{8'b00x10100,`S3}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b010,`S4,1'b0,1'b0,1'b0,2'b00,1'b1,1'b0,1'b0,1'b0}; //Now we write it to Rd 
	{8'b00x10100,`S4}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //Now we go back to reset state
	{8'b01110101,`S0}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b001,`S1,1'b1,1'b0,1'b0,2'b10,1'b0,1'b0,1'b0,1'b0}; //This is for CMP, put Rn into RegA
	{8'b00x10101,`S1}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b100,`S2,1'b0,1'b1,1'b0,2'b10,1'b0,1'b0,1'b0,1'b0}; //Place Rm into RegB
	{8'b00x10101,`S2}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b000,`S3,1'b0,1'b0,1'b0,2'b00,1'b0,1'b1,1'b0,1'b0}; //Now do the subtraction
   	{8'b00x10101,`S3}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //Now reset_state
	{8'b01110110,`S0}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b001,`S1,1'b1,1'b0,1'b0,2'b10,1'b0,1'b0,1'b0,1'b0}; //This is for AND, put Rn into RegA
	{8'b00x10110,`S1}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b100,`S2,1'b0,1'b1,1'b0,2'b10,1'b0,1'b0,1'b0,1'b0}; //Now place Rm into RegB
	{8'b00x10110,`S2}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b000,`S3,1'b0,1'b0,1'b1,2'b00,1'b0,1'b0,1'b0,1'b0}; //Now we place the ANDed result into RegC
	{8'b00x10110,`S3}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b010,`S4,1'b0,1'b0,1'b0,2'b00,1'b1,1'b0,1'b0,1'b0}; //Place the value in RegC into Rd
	{8'b00x10110,`S4}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //Go back to reset state
	{8'b01110111,`S0}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b100,`S1,1'b0,1'b1,1'b0,2'b10,1'b0,1'b0,1'b1,1'b0}; //MVN, so set RegB to value of Rm
	{8'b00x10111,`S1}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b000,`S2,1'b0,1'b0,1'b1,2'b00,1'b0,1'b0,1'b1,1'b0}; //Place the new value into RegC
	{8'b00x10111,`S2}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b1,3'b010,`S3,1'b0,1'b0,1'b0,2'b00,1'b1,1'b0,1'b0,1'b0}; //Place that value into Rd
	{8'b00x10111,`S3}: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //go back to reset state
	default: {load_s,nsel,next_state,loada,loadb,loadc,vsel,write,loads,asel,bsel}
				= {1'b0,3'b000,`S0,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,1'b0}; //default sends it back to reset state
   endcase
  end
endmodule 
