module sequence_detection(
	input wire clk,
	input wire rst,
	input wire button,
	input wire [7:0] switch,
	output reg led
	//output reg [7:0] data
);
	parameter IDLE = 3'd0;
	parameter S0 = 3'd1;
	parameter S1 = 3'd2;
	parameter S2 = 3'd3;
	parameter S3 = 3'd4;
	parameter S4 = 3'd5;
	parameter S5 = 3'd6;
	
	reg [2:0]current_state;
	reg [2:0]next_state;
	
	reg [7:0]data;
	reg [2:0]cnt;
	reg cnt_inc=1'b0;
	assign cnt_end = cnt_inc & (cnt == 3'd7);
	assign input_seq = data[0];
	
	always @(posedge clk or posedge rst)begin
		if (rst)
			data <= 8'd0;
		else if(button)
			data <= switch;
		else if(cnt_end)
			data <= data;
		else if(cnt_inc)
			data <= data>>1;
		else
			data <= data;
	end
	
		always @(posedge clk or posedge rst)begin
		if (rst)
			cnt_inc <= 1'b0;
		else if(button)
			cnt_inc <= 1'b1;
		else
			cnt_inc <= cnt_inc;
	end
	
	always @(posedge clk or posedge rst)begin
		if (rst)
			cnt <= 3'd0;
		else if(button)
			cnt <= 3'd0;
		else if(cnt_end)
			cnt <= cnt;
		else if(cnt_inc)
			cnt <= cnt + 3'd1;
		else
			cnt <= cnt;
	end
	
	always @(posedge clk or posedge rst)begin
		if (rst) current_state <= IDLE;
		else current_state <= next_state;
	end
	
	always @(*)begin
		case(current_state)
			IDLE:	if(button) 		next_state = S0;
					else 			next_state = IDLE;
			S0 	: 	if(rst) 		next_state = IDLE;
					else if(button) next_state = S0;
					else if(input_seq)next_state = S0;
					else 			next_state = S1;
			S1 	: 	if(rst) 		next_state = IDLE;
					else if(button) next_state = S0;
					else if(input_seq)next_state = S2;
					else 			next_state = S1;
			S2 	: 	if(rst) 		next_state = IDLE;
					else if(button) next_state = S0;
					else if(input_seq)next_state = S0;
					else 			next_state = S3;
			S3 	: 	if(rst) 		next_state = IDLE;
					else if(button) next_state = S0;
					else if(input_seq)next_state = S4;
					else 			next_state = S1;
			S4 	: 	if(rst) 		next_state = IDLE;
					else if(button) next_state = S0;
					else if(input_seq)next_state = S5;
					else 			next_state = S3;
			S5 	: 	if(rst) 		next_state = IDLE;
					else if(button) next_state = S0;
					else if(input_seq)next_state = S5;
					else 			next_state = S5;
			default:				next_state = IDLE;
		endcase
	end
	
	always @(posedge clk or posedge rst)begin
		if (rst) led <= 1'b0;
		else begin
			case(current_state)
				S5 : led <= 1'b1;
				default : led <= 1'b0;
			endcase
		end
	end
	
endmodule