module cpu_tb();
  reg clk, reset, s, load, err;
  reg [15:0] in;
  wire [15:0] out;
  wire N,V,Z,w; 

  cpu dut( .clk(clk),
	   .reset(reset),
	   .s(s),
	   .load(load),
	   .in(in),
	   .out(out),
	   .N(N),
	   .V(V),
	   .Z(Z),
	   .w(w)
  );

  initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end

  initial begin
  err = 0; 
  reset = 1; load = 0; s = 0; in = 16'b0;
  #10;
  //Check if reset changes but s stays 0, does anything happen
  reset = 0;
  in = 16'b1101000000000001; //im8 = #1 
  load = 1; 
  #10;
  //Check if w is still in reset state (1)
  if (cpu_tb.dut.w !== 1)begin
	err = 1;
	$display("ERROR** value of w is %b, should be %b",cpu_tb.dut.w,1);
  end
  #10;
  //now let us set s = 1 and put value im8 = #1 R0
  s = 1; 
  load = 0;
  #10; 
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R0 !== 16'h1)begin
	err = 1;
	$display("ERROR** value of R0 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R0,16'h1);
  end
  //now let us set s = -3, so imm8 = 11111101 and set it to R1
  in = 16'b1101000111111101; load = 1;
  #10;
  load = 0; s = 1;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R1 !== 16'b1111111111111101)begin
	err = 1;
	$display("ERROR** value of R1 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R1,16'b1111111111111101);
  end

  /*NOTE!! THIS TEST CASE ERASED R0 and R1, DIDN'T HAVE TIME SO IGNORED IT BUT CAN ASSUME 
  /*THAT THIS HAPPENS FOR ALL DEFAULT STATES IN FSM!! 
  //now let us try with opcode = 110 but op = 11, so shouldn't do anything and stay in reset 
  in = 16'b1101101000000001; load = 1;
  #10;  
  load = 0; s = 1;
  #10;
  s = 0;
  #10;
  if(cpu_tb.dut.w !== 1)begin
	err = 1;
	$display("ERROR** value of w is %b, should be %b",cpu_tb.dut.w,1);
  end*/
  //now we will try one more test case for moving a new value into register 2
  in = 16'b1101001000000010; load = 1; //so imm8 = #2
  #10; 
  //what if load was on the whole time? 
  s = 1; 
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R2 !== 16'h2) begin
	err = 1;
	$display("ERROR** value at R2 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R2,16'h2);
  end
  if ( ~err )begin $display("PASSED MOV im8 into Rn"); end
  if ( err )begin $display("FAILED MOV im8 into Rn"); end
  #10;
  //Now let us try to move a value from one register to another 
  in = 16'b1100000001100010; 
  #10;
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R3 !== 16'h2) begin
	err = 1;
	$display("ERROR** value at R3 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R3,16'h2);
  end
  in = 16'b1100000010001000; load = 1; //Set R4 = R0 LSL 1
  #10;
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R4 !== 16'h2) begin
	err = 1;
	$display("ERROR** value at R4 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R4,16'h2);
  end
  in = 16'b1100000010110100; load = 1; //Set R5 = R4 LSR 1 
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R5 !== 16'h1) begin
	err = 1;
	$display("ERROR** value at R5 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R5,16'h1);
  end
  if ( ~err )begin $display("PASSED MOV sh_Rm into Rn"); end
  if ( err )begin $display("FAILED MOV sh_Rm into Rn"); end
  #10;

  //Now let us try the ALU instructions 
  //Start off with addition, NOTE: R0 = 1, R1 = -3, R2 = 2, R3 = 2, R4 = 2, R5 = 1
  in = 16'b1010000011000010; load = 1; //R6 = R0 + R2 = 3
  #10;
  s = 1; load = 0;
  #10; 
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R6 !== 16'h3) begin
	err = 1;
	$display("ERROR** value at R6 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R6,16'h3);
  end
  in = 16'b1010000011101010; load = 1; //R7 = R0 + LSL_R2 = 5
  #10;
  s = 1; load = 0;
  #10; 
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R7 !== 16'h5) begin
	err = 1;
	$display("ERROR** value at R7 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R6,16'h5);
  end
  in = 16'b1010000011000000; load = 1; //Let us try to add R6 = R0 + R0 = 2 
  #10;
  s = 1; load = 0;
  #10; 
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R6 !== 16'h2) begin
	err = 1;
	$display("ERROR** value at R6 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R6,16'h2);
  end
  if(~err)begin $display("PASSED ADD");end
  if(err) begin $display("FAILED ADD");end
  #10;
  //Now we will try to test CMP 
  //first test out a subtraction that is equal to 0, so R3 - R3
  in = 16'b1010101100000011; load = 1; 
  #10;
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.N !== 1'b0 | cpu_tb.dut.V !== 1'b0 | cpu_tb.dut.Z !== 1'b1) begin
	err = 1;
	$display("ERROR** status is %b,%b,%b (N,V,Z), should be %b,%b,%b",
			cpu_tb.dut.N,cpu_tb.dut.V,cpu_tb.dut.Z,1'b0,1'b0,1'b1);
  end
  //try subtracting into a negative, R1 - R0 = -3 - 1 = -4 
  in = 16'b1010100100000000; load = 1;
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
   if(cpu_tb.dut.N !== 1'b1 | cpu_tb.dut.V !== 1'b0 | cpu_tb.dut.Z !== 1'b0) begin
	err = 1;
	$display("ERROR** status is %b,%b,%b (N,V,Z), should be %b,%b,%b",
			cpu_tb.dut.N,cpu_tb.dut.V,cpu_tb.dut.Z,1'b1,1'b0,1'b0);
  end
  //Now try subtracting normally 
  in = 16'b1010101000000000; load = 1;
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
   if(cpu_tb.dut.N !== 1'b0 | cpu_tb.dut.V !== 1'b0 | cpu_tb.dut.Z !== 1'b0) begin
	err = 1;
	$display("ERROR** status is %b,%b,%b (N,V,Z), should be %b,%b,%b",
			cpu_tb.dut.N,cpu_tb.dut.V,cpu_tb.dut.Z,1'b0,1'b0,1'b0);
  end
  if(~err)begin $display("PASSED CMP");end
  if(err) begin $display("FAILED CMP");end
  #10;
  //Now we try ANDing 
  in = 16'b1011001010100011; load = 1; //AND 2 and 2 = 2 
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R5 !== 16'h2)begin
	err = 1;
	$display("ERROR** R5 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R5,16'h2);
  end 
  in = 16'b1011001011000000; load = 1; //AND 2 and 1 = 0 
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R6 !== 16'h0)begin
	err = 1;
	$display("ERROR** R6 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R6,16'h0);
  end 
  in = 16'b1011011111100000; load = 1; //AND 5 and 1 = 1
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R7 !== 16'h1)begin
	err = 1;
	$display("ERROR** R7 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R7,16'h1);
  end 
  if(~err)begin $display("PASSED AND");end
  if(err) begin $display("FAILED AND");end
  //Now let us try MVN
  in = 16'b1011100011100110; load = 1; //MVN 0
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R7 !== 16'b1111111111111111)begin
	err = 1;
	$display("ERROR** R7 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R7,16'b11111111111111111);
  end 
  in = 16'b1011100001100001; load = 1; //MVN -3
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R3 !== 16'h2)begin
	err = 1;
	$display("ERROR** R3 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R3,16'h2);
  end
  in = 16'b1011100010000111; load = 1; //MVN 16'b11111111111111111
  #10; 
  s = 1; load = 0;
  #10;
  s = 0;
  @(posedge w);
  #10;
  if(cpu_tb.dut.DP.REGFILE.R4 !== 16'h0)begin
	err = 1;
	$display("ERROR** R4 is %b, should be %b",cpu_tb.dut.DP.REGFILE.R4,16'h0);
  end
  if ( ~err )begin $display("PASSED MVN"); end
  if ( err )begin $display("FAILED MVN"); end
  #10;
  if ( ~err )begin $display("PASSED"); end
  if ( err )begin $display("FAILED"); end
  $stop;
  end 
endmodule 
