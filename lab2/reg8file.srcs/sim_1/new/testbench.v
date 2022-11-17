`timescale 1ns/1ps

module reg8file_sim();

	reg clk;
	reg clr;
	reg en;
	reg [7:0]d;
	reg [2:0] wsel;
	reg [2:0] rsel;
	wire [7:0]q;
	
	reg8file reg_sim(.clk(clk),.clr(clr),.en(en),.d(d),.wsel(wsel),.rsel(rsel),.q(q));
	
	initial begin
		clk=1'b0;clr=1'b1;en=1'b0;d=8'd0;wsel=3'd0;rsel=3'd0;
		#10 clr=1'b0;en=1'b1;d=8'd0;wsel=3'd0;
		#10 d=8'd1;wsel=3'd1;
		#10 d=8'd2;wsel=3'd2;
		#10 d=8'd3;wsel=3'd3;
		#10 d=8'd4;wsel=3'd4;
		#10 d=8'd5;wsel=3'd5;
		#10 d=8'd6;wsel=3'd6;
		#10 d=8'd7;wsel=3'd7;
		#10 en=1'b0;rsel=3'd0;
		#10 rsel=3'd1;	
		#10 rsel=3'd2;
		#10 rsel=3'd3;
		#10 rsel=3'd4;
		#10 rsel=3'd5;	
		#10 rsel=3'd6;
		#10 rsel=3'd7;
		#10 clr=1'b1;
	end
	
	always #5 clk=~clk;

endmodule