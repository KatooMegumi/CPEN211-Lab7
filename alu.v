`define ADD 2'b00
`define CMP 2'b01
`define AND 2'b10
`define NOT 2'b11
/*Lab 6 Arithmetic Logic Unit (ALU)*/
module alu(ALUop,Ain,Bin,out,status);
  input [1:0] ALUop; 
  input [15:0] Ain, Bin;
  output reg [15:0] out;
  output [2:0] status;
  wire ovf;
  wire [15:0] sout;

  Addsub #(16) a(Ain, Bin, 1'b1, sout, ovf);
  assign status[2] = ((out == 16'b0) ? 1'b1:1'b0); //if it is zero
  assign status[1] = ovf; //overflow
  assign status[0] = out[15]; //negative
  //ALU will reevaluate whenever any of the inputs change 
  always @(*) begin
    case (ALUop)
      `ADD: out = Ain + Bin;
      `CMP: out = Ain - Bin; 
      `AND: out = Ain & Bin;
      `NOT: out = ~Bin;
      default: out = 16'bx;
    endcase	
  end
endmodule

//Taken from SS.6 
module Addsub(a,b,sub,s,ovf);
  parameter n = 8;
  input [n-1:0] a, b; //inputs 
  input sub ; //subtract if sub = 1, add otherwise 
  output [n-1:0] s;
  output ovf;  //ovf is 1 if overflow 
  wire c1, c2;

  assign ovf = c1 ^ c2; //overflow if signs don't match 

  //add non sign bits
  Adder1 #(n-1) ai(a[n-2:0],b[n-2:0]^{n-1{sub}},sub,c1,s[n-2:0]);
  //add sign bits
  Adder1 #(1) as(a[n-1],b[n-1]^sub,c1,c2,s[n-1]);
endmodule 

//Adder
module Adder1(a,b,cin,cout,s);
  parameter n = 8;
  input [n-1:0] a, b;
  input cin ;
  output [n-1:0] s;
  output cout;

  assign {cout, s} = a + b + cin;
endmodule

