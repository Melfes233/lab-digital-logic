module buttoncounter(
	input wire clk,
	input wire rst,
	input wire button,
	input wire counter,
	output reg [3:0]button_number_0,
	output reg [3:0]button_number_1
);
	wire pos_edge;
	edgedetector u_edgedetector(.clk(clk),.rst(rst),.button(button),.counter(counter),.pos_edge(pos_edge));
	
	reg [3:0]cnt_0 = 4'd0;//个位数
	reg [3:0]cnt_1 = 4'd0;//十位数
	assign cnt_end_0 = pos_edge && (cnt_0==4'd9);//个位数
	assign cnt_end_1 = cnt_end_0 && (cnt_1==4'd9);//十位数
	
	always @(posedge clk or posedge rst)begin
		if(rst)
			cnt_0 <= 4'd0;
		else if(cnt_end_0)
			cnt_0 <= 4'd0;
		else if(pos_edge)
			cnt_0 <= cnt_0 + 4'd1;
		else
			cnt_0 <= cnt_0;
	end
	
	always @(posedge clk or posedge rst)begin
		if(rst)
			cnt_1 <= 4'd0;
		else if(cnt_end_1)
			cnt_1 <= 4'd0;
		else if(cnt_end_0)
			cnt_1 <= cnt_1 + 4'd1;
		else
			cnt_1 <= cnt_1;
	end
	
	always @(*)begin
        button_number_0 = cnt_0;
        button_number_1 = cnt_1;
    end

endmodule