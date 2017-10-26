//Lab 5 Register Module 
/*If a register does not have a value assigned to it yet, it will
be void x, otherwise it will return a data_out that is equal to the 
number assigned to the register up to 2^16*/
module regfile(clk,write,writenum,readnum,data_in,data_out);
  input clk,write;
  input [2:0] writenum, readnum;
  input [15:0] data_in;
  output [15:0] data_out;

  wire [7:0] readout, writeout;
  wire [15:0] R7, R6, R5, R4, R3, R2, R1, R0;
  
  //Decode the readnum and writenum binary inputs to one hot codes 
  dec #(3,8) read_num(readnum, readout);
  dec #(3,8) write_num(writenum, writeout);
  
  /*There are 8 Registers with Load Enable, each will write on the rising edge of the clk
  iff write and write_num[i] of Ri is true*/
  vDFFE #(16) write_reg0(clk, (write & writeout[0]), data_in, R0);
  vDFFE #(16) write_reg1(clk, (write & writeout[1]), data_in, R1);
  vDFFE #(16) write_reg2(clk, (write & writeout[2]), data_in, R2);
  vDFFE #(16) write_reg3(clk, (write & writeout[3]), data_in, R3);
  vDFFE #(16) write_reg4(clk, (write & writeout[4]), data_in, R4);
  vDFFE #(16) write_reg5(clk, (write & writeout[5]), data_in, R5);
  vDFFE #(16) write_reg6(clk, (write & writeout[6]), data_in, R6);
  vDFFE #(16) write_reg7(clk, (write & writeout[7]), data_in, R7);

  //Read and return the value of the Register read according to read_num
  mux8 #(16) read_mux(R7, R6, R5, R4, R3, R2, R1, R0, readout, data_out);
endmodule

//Decoder binary to one-hot 
module dec(a,b);
  parameter n = 2;
  parameter m = 4;
  input [n-1:0] a;
  output [m-1:0] b;
  
  wire[m-1:0] b = 1<<a;
endmodule 

//Single Register with load enable and positive edge of clock 
module vDFFE(clk,en,in,out);
  parameter n = 3;
  input clk, en;
  input [n-1:0] in;
  output reg [n-1:0] out;
  wire [n-1:0] nextout;

  assign nextout = en ? in:out;
  always @(posedge clk)
    out = nextout;
  endmodule 

//8 Register Multiplexer Implementation 
module mux8(r7, r6, r5, r4, r3, r2, r1, r0, s, b);
  parameter k = 1;
  input [k-1:0] r7, r6, r5, r4, r3, r2, r1, r0;
  input [7:0] s;
  output [k-1:0] b;

  wire [k-1:0] b = ({k{s[0]}} & r0) |
		   ({k{s[1]}} & r1) |    
		   ({k{s[2]}} & r2) |
		   ({k{s[3]}} & r3) | 
		   ({k{s[4]}} & r4) |
		   ({k{s[5]}} & r5) |
		   ({k{s[6]}} & r6) |
		   ({k{s[7]}} & r7) ;
endmodule
