// Code your design here
module datapath(eqz, ldA,ldB,ldP,clrP,decB, clk,data_in);
input ldA,ldB,ldP,clrP,decB, clk;
input [15:0] data_in;
output eqz;

wire [15:0] A_out, P_out, B_out, z;

// "A" register data_in nunchi data teeskoni, control signal activate ayitey, A_out istaadi
pipo1 g1(A_out, data_in,ldA,clk);
// "P" register "z" nunchi data teeskoni, control signal activate ayitey, P_out istaadi
pipo2 g2(P_out, z,ldP,clrP,clk);
// "B" register data_in nunchi data teeskoni, control signal activate ayitey, B_out istaadi
cntr g3(B_out, data_in,ldB,decB,clk);
// add A nd P
addr g4(z, A_out,P_out);
// "B_out" zero aaa kaada ani check cheyadaniki
cmprtrB g5(eqz, B_out);

endmodule

//--------------------
// 2. pipo1 design	|
//--------------------
module pipo1(dout, data, load, clk);
input [15:0] data;
input load, clk;
output reg [15:0] dout;

always@(posedge clk)
	if(load)
		dout <= data;
endmodule

//--------------------
// 3. pipo2 design	|
//--------------------
module pipo2(dout, data, load, clr, clk);
input [15:0] data;
input load, clr, clk;
output reg [15:0] dout;

always@(posedge clk)
	begin
	if(clr)
		dout <= 16'b0;
	else if(load)
		dout <= data;
	end
endmodule

//--------------------
// 3. adder design	|
//--------------------
module addr(a_out, in1, in2);
input [15:0] in1, in2;
output reg [15:0] a_out;

always@(*)
	a_out = in1 + in2;
endmodule

//------------------------
// 4. comparator design	|
//------------------------
module cmprtrB(c_out, in);
input [15:0] in;
output c_out;

assign c_out = ~|(in);
endmodule

//----------------------
// 5. counter design	|
//----------------------
module cntr(c_out, data,load,dec,clk);
input [15:0] data;
input load, dec, clk;
output reg [15:0] c_out;

always@(posedge clk)
	if(load)
		c_out <= data;
	else if(dec)
		c_out <= c_out-1;
endmodule

//----------------------------
// 6. control path design	|
//----------------------------
module controller(ldA,ldB,ldP,clrP,decB,done, clk,eqz,start);
input clk,eqz,start;
output reg ldA,ldB,ldP,clrP,decB,done;

reg [2:0] state;
parameter s0=3'b000, s1=3'b001, s2=3'b010, s3=3'b011, s4=3'b100;

always@(posedge clk)
	begin
	case(state)
		s0 : if(start) state <= s1;
		s1 : state <= s2;
		s2 : state <= s3;
		s3 : #2 if(eqz == 0) state <= s3;
			 else state <= s4;
	//	s3 : #2 if(eqz) state <= s4;	// illaga kuuda raayochu
		s4 : state <= s4;
		default : state <= s0;
	endcase
	end

always@(state)
	begin
	case(state)
		s0 : begin #1 ldA=0; ldB=0; ldP=0; clrP=0; decB=0; end
		s1 : begin #1 ldA=1; end
		s2 : begin #1 ldA=0; ldB=1; clrP=1; end
		s3 : begin #1 ldB=0; ldP=1; clrP=0; decB=1; end
		s4 : begin #1 ldP=0; decB=0; done=1; end
		default : begin #1 ldA=0; ldB=0; ldP=0; clrP=0; decB=0; end
	endcase
	end
endmodule