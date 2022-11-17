module flowing_water_lights(
	input wire clk,
	input wire rst,
	input wire button,
	input wire [1:0]freq_set,
	output reg [7:0]led
);
	reg [26:0] clk_div;
	reg [26:0] cnt;
	reg cnt_inc = 1'b0;
	
	wire cnt_end = cnt_inc & (cnt == clk_div);
	
	always @(*)begin
		case(freq_set)
			2'b00 : clk_div=27'd10000000;
			2'b01 : clk_div=27'd20000000;
			2'b10 : clk_div=27'd50000000;
			default : clk_div=27'd100000000;
		endcase
	end
	
	always @(posedge clk or posedge rst)begin
		if (rst) 			
			cnt_inc <= 1'b0;
		else if (button) 	
			cnt_inc <= 1'b1;
		else
		    cnt_inc <= cnt_inc;
	end
	
	always @(posedge clk or posedge rst)begin
		if (rst)			
			led <= 8'd1;
		else if(cnt_end)		 	
		    led <= {led[6:0],led[7]};
		else
		    led <= led;
	end
	
	always @(posedge clk or posedge rst)begin
		if (rst) 			
			cnt <= 27'd0;
		else if (cnt_end)
			cnt <= 27'd0;
		else if (cnt_inc) 	
			cnt <= cnt + 27'd1;
		else
		    cnt <= cnt;
	end
	
endmodule
	
	
	
	
	
	
	
	
	
	
		