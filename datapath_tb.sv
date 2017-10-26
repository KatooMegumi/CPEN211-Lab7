/*Self Testing testbench for datapath*/
module datapath_tb();
  reg clk, loada, loadb, loadc, loads, asel, bsel, write, err; 
  reg [1:0] shift, ALUop, vsel; 
  reg [2:0] writenum, readnum;  
  reg [15:0] datapath_in,sximm8,sximm5;
  reg [7:0] PC;
  wire [2:0] status;
  wire [15:0] datapath_out;

  datapath dut(
	      .clk(clk),
	      .vsel(vsel),
	      .loada(loada),
	      .loadb(loadb),
	      .loadc(loadc),
	      .loads(loads),
	      .asel(asel),
	      .bsel(bsel),
	      .write(write),
	      .shift(shift),
	      .ALUop(ALUop),
	      .writenum(writenum),
	      .readnum(readnum),
	      .mdata(datapath_in),
	      .status(status),
	      .C(datapath_out),
	      .sximm8(sximm8),
	      .sximm5(sximm5),
	      .PC(PC)
  );

  initial begin 
    clk = 0; #5;
    forever begin //Rising edge of clock will be at every 10 starting at 5 ps (so 15 next one)
      clk = 1; #5;
      clk = 0; #5; 
    end
  end 

  initial begin
    //Let us first MOV R0, #7
    err = 1'b0;
    vsel = 2'b11;
    datapath_in = 16'b0000000000000111;
    writenum = 3'b000;
    write = 1'b1;
    sximm8 = {8'b0,8'b00000001};
    sximm5 = {11'b0,5'b00001};
    PC = 8'b0;
    #10; //wait for the rising edge of the clk at 5ps
    //check if the value is right at R0
    write = 1'b0; 
    readnum = 3'b000;
    #10;
    $display("Checking if the value at R0 is right");
    if( datapath_tb.dut.data_out !== 16'b0000000000000111 ) begin
	$display("ERROR ** R0 has a value of %b, expected is %b",
		  datapath_tb.dut.data_out, 16'b0000000000000111);
 	err = 1'b1;
    end
    //Now we will MOV R1, #2 
    datapath_in = 16'b0000000000000010;
    writenum = 3'b001;
    write = 1'b1;
    #10;
    //check if the value is right at R1
    write = 1'b0;
    readnum = 3'b001;
    #10;
    $display("Checking if the value at R1 is right");
    if( datapath_tb.dut.data_out !== 16'b0000000000000010 ) begin
	$display("ERROR ** R1 has a value of %b, expected is %b",
		  datapath_tb.dut.data_out, 16'b0000000000000010 );
	err = 1'b1;
    end
    //Now we will ADD R2, R1, R0, LSL #1 
    //which means we will add R1 + R0 (shifted left 1 unit)
    //so should be 2 + 2(7) = 16 and store to R2 
    
    //Let us start off by storing R1 in reg_A
    readnum = 3'b001;
    loada = 1'b1; 
    #10;
    $display("Checking if the value at Register A is right");
    if ( datapath_tb.dut.aout !== 16'b0000000000000010 ) begin
	$display("ERROR ** Reg_A has a value of %b, expected is %b",
		  datapath_tb.dut.aout, 16'b0000000000000010 );
	err = 1'b1;
    end
    //Now let us store R0 in reg_B and shift it left 1 bit 
    readnum = 3'b000;
    loada = 1'b0;
    loadb = 1'b1;
    shift = 2'b01;
    #10;
    $display("Checking if the value at Register B shifted is right");
    if ( datapath_tb.dut.bout_shift !== 16'b0000000000001110 ) begin
	$display("ERROR ** Reg_b_shifted has a value of %b, expected is %b",
		  datapath_tb.dut.bout_shift, 16'b0000000000001110 );
	err = 1'b1;
    end
    //Now let us store into asel and bsel, apply the ALUop and store in registerC
    loadb = 1'b0;
    asel = 1'b0;
    bsel = 1'b0; 
    ALUop = 2'b00;
    loadc = 1'b1;
    loads = 1'b1;
    #10;
    $display("Checking if the value at datapath_out is right");
    if( datapath_tb.dut.C !== 16'b0000000000010000 ) begin
	$display("ERROR ** datapath_out has a value of %b, expected is %b",
		  datapath_tb.dut.C, 16'b0000000000010000);
	err = 1'b1;
    end
    $display("Checking if the value at status is right");
    if( datapath_tb.dut.status !== 3'b000) begin
	$display("ERROR ** datapath_out has a value of %b, expected is %b",
		  datapath_tb.dut.status, 3'b000);
	err = 1'b1;
    end
    //Let us write this datapath_out into Register 2
    vsel = 2'b00;
    writenum = 3'b010;
    write = 1'b1;
    #10;
    $display("Checking if the value at R2 is right");
    readnum = 3'b010;
    #10;
    if( datapath_tb.dut.data_out !== 16'b0000000000010000 ) begin
	$display("ERROR ** Register 2 has a value of %b, expected is %b",
		  datapath_tb.dut.data_out, 16'b0000000000010000);
	err = 1'b1;
    end
    
    //Now let us test out how sximm8 works 
    vsel = 2'b10;
    writenum = 3'b101;
    write = 1'b1;
    #10;
    $display("Checking if the value at R5 is right");
    readnum = 3'b101;
    #10;
    if( datapath_tb.dut.data_out !== sximm8 ) begin
	$display("ERROR ** Register 5 has value %b, expected is %b",
		  datapath_tb.dut.data_out, sximm8);
	err = 1'b1;
    end

    //Now let us test out if PC works 
    vsel = 2'b01;
    writenum = 3'b110;
    write = 1'b1;
    #10; 
    $display("Checking if the value at R6 is right");
    readnum = 3'b110;
    #10;
    if( datapath_tb.dut.data_out !== {8'b0,PC} ) begin
	$display("ERROR ** Register 5 has value %b, expected is %b",
		  datapath_tb.dut.data_out, {8'b0,PC});
	err = 1'b1;
    end
    //Now let us confirm sximm5
    asel = 1'b1;
    bsel = 1'b1;
    ALUop = 2'b00;
    loadc = 1'b1;
    #10;
    $display("Checking if the value at datapath_out is right");
    if( datapath_tb.dut.C !== sximm5 ) begin
	$display("ERROR ** datapath_out has a value of %b, expected is %b",
		  datapath_tb.dut.C, sximm5);
	err = 1'b1;
    end
    if ( ~err )begin $display("PASSED"); end
    $stop;
  end
endmodule 
