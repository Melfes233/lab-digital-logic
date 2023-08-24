`timescale 1ns/1ps

module sequence_detection_sim();
	
	reg clk;
	reg rst;
	reg button;
	reg [7:0]switch;
	wire led;
	//wire [7:0] data;
	
	sequence_detection u_sequence_detection(
	.clk(clk),
	.rst(rst),
	.button(button),
	.switch(switch),
	.led(led)
	//.data(data)
	);
	
	initial begin
		clk=1'b0;rst=1'b1;button=1'b0;switch=8'b11010110;
		#10 rst=1'b0;
		#10 button=1'b1;
		#10 button=1'b0;
		#100 switch=8'b00010101;button=1'b1;
		#10 button=1'b0;
		#100 rst=1'b1;
	end
	
	always #5 clk=~clk;
endmodule