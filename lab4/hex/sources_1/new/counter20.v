module counter20(
	input wire clk,
	input wire rst,
	input wire button,
	output reg [3:0]number_0,
	output reg [3:0]number_1
);
	reg [5:0]cnt;//0-h20数字
	reg cnt_inc = 1'b0;//增加信号
	reg [24:0] cnt_origin;//底层计数器
	assign cnt_end_origin = cnt_inc & (cnt_origin == 25'd20000000);//0.2s终止信号
	assign cnt_end = cnt_end_origin & (cnt == 6'd32);//0-h20终止信号
	
	//增加信号的赋值
	always @(posedge clk or posedge rst)begin
		if (rst) 
			cnt_inc <= 1'b0;
		else if (button)
			cnt_inc <= 1'b1;
		else
			cnt_inc <= cnt_inc;
	end
	
	//底层计数器
	always @(posedge clk or posedge rst)begin
		if (rst) 
			cnt_origin <= 25'd0;
		else if (cnt_end_origin)
			cnt_origin <= 25'd0;
		else if (cnt_inc)
			cnt_origin <= cnt_origin + 25'd1;
		else
			cnt_origin <= cnt_origin;
	end
	
	//0到20计数器
	always @(posedge clk or posedge rst)begin
		if (rst)
			cnt <= 6'd0;
		else if (cnt_end)
			cnt <= 6'd0;
		else if (cnt_end_origin)
			cnt <= cnt + 6'd1;
		else
			cnt <= cnt;
	end
	
	//将cnt转换成十进制下的十位数字和个位数
	always @(*)begin
		if(cnt>=6'd32)begin
			number_0 = 4'h0;
			number_1 = 4'h2;
		end
		else if (cnt>6'd16)begin
			number_0 = cnt-6'd16;
			number_1 = 4'h1;
		end
		else begin
			number_0 = cnt;
			number_1 = 4'h0;
		end
	end
	
endmodule
		
	