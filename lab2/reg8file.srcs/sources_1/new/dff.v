module dff(
	input wire clk,
	input wire clr,
	input wire en,
	input wire [7:0]d,
	output reg [7:0]r
);
	
	always@(posedge clk or posedge clr)begin
		if (clr)
			r <= 8'b0;
		else if (en)
			r <= d;
		else
			r <= r;
	end
endmodule

