`timescale 1ns/1ps

module lock_sim();
	
	reg clk;
	reg rst;//S1
	reg setcode;//S2
	reg validcode;//S3
	reg confirmcode;//S5
	reg [3:0]row;
	wire [3:0]col;
	wire [7:0] led_en;
	wire led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp;
	wire [2:0]wrongcode;
	wire codesetted;//GLD0
	wire rightcode;
	
	lock u_lock(
		.clk(clk),
		.rst(rst),
		.setcode(setcode),
		.validcode(validcode),
		.confirmcode(confirmcode),
		.row(row),
		.col(col),
		.led_en(led_en),
		.led_ca(led_ca),
		.led_cb(led_cb),
		.led_cc(led_cc),
		.led_cd(led_cd),
		.led_ce(led_ce),
		.led_cf(led_cf),
		.led_cg(led_cg),
		.led_dp(led_dp),
		.wrongcode(wrongcode),
		.codesetted(codesetted),
		.rightcode(rightcode)
	);
	
	
	reg [7:0] keycase_cnt;   //按键个数计数

	parameter CNT_THRESHOLD=40-1;

	counter #(CNT_THRESHOLD, 24) u_test_counter(     //用于生成时序匹配的row信号
		.clk(clk), 
		.reset(rst), 
		.cnt_inc(1), 
		.cnt_end(cnt_end)
	);
	
	
	initial begin 
		clk=1'b0;rst=1'b1;setcode=1'b0;validcode=1'b0;confirmcode=1'b0;row=4'b1111;
		#500 rst=1'b0;
		#500 setcode=1'b1;
		#200 setcode=1'b0;
		#3800//5000
		#100 confirmcode=1'b1;
		#100 confirmcode=1'b0;
		#100 validcode=1'b1;
		#100 validcode=1'b0;//5400
		#5600//11000
		#200 confirmcode=1'b1;
		#200 confirmcode=1'b0;
		#1000 rst=1'b1;//0 12400
		#500 rst=1'b0;
		#500 setcode=1'b1;
		#200 setcode=1'b0;
		#3800//5000
		#100 confirmcode=1'b1;
		#100 confirmcode=1'b0;
		#50 validcode=1'b1;
		#50 validcode=1'b0;//5200
		#9800//15000
		#100 confirmcode=1'b1;
		#100 confirmcode=1'b0;
		#100 validcode=1'b1;
		#100 validcode=1'b0;//15400
		#4800//20200
		#100 confirmcode=1'b1;
		#100 confirmcode=1'b0;
		#100 validcode=1'b1;
		#100 validcode=1'b0;//20600
		#4400//25000
		#200 confirmcode=1'b1;
		#200 confirmcode=1'b0;
		#1000 rst=1'b1;
	end
	
	always #5 clk=~clk;
	
	reg keycase_inc = 1'b0;
	always @(posedge clk, posedge rst)begin
		if(rst) 
			keycase_inc <= 1'b0;
		else if(confirmcode) 
			keycase_inc <= 1'b0;
		else if(setcode || validcode) 
			keycase_inc <= 1'b1;
		else 
			keycase_inc <= keycase_inc;
	end

	always @(posedge clk, posedge rst) begin
		if (rst) keycase_cnt <= 8'd0;
		else if (keycase_inc & cnt_end) keycase_cnt <= keycase_cnt + 8'd1;
	end
		
	always @(*) begin
		case(keycase_cnt[7:2])  //每轮4次扫描，去掉低2位即第几个测试用例计数
			8'b0000_00:
				if(col==4'b0111) row = 4'b0111;  //set
				else row = 4'b1111;
			8'b0000_01: 
				if(col==4'b1011) row = 4'b0111;
				else row = 4'b1111;
			8'b0000_10:
				if(col==4'b1101) row = 4'b0111; //123
				else row = 4'b1111;
			8'b0000_11: 
				if(col==4'b0111) row = 4'b0111;  //right
				else row = 4'b1111;      
			8'b0001_00:                           
				if(col==4'b1011) row = 4'b0111;
				else row = 4'b1111;
			8'b0001_01:
				if(col==4'b1101) row = 4'b0111; //123
				else row = 4'b1111;
			8'b0001_10: 
				if(col==4'b1011) row = 4'b0111;  //wrong1
				else row = 4'b1111;      
			8'b0001_11:                           
				if(col==4'b0111) row = 4'b0111;
				else row = 4'b1111;
			8'b0010_00:
				if(col==4'b1011) row = 4'b0111; //212
				else row = 4'b1111;
			8'b0010_01: 
				if(col==4'b0111) row = 4'b0111;  //wrong2
				else row = 4'b1111;      
			8'b0010_10:                           
				if(col==4'b1101) row = 4'b0111;
				else row = 4'b1111;
			8'b0010_11:
				if(col==4'b1011) row = 4'b0111; //132
				else row = 4'b1111;
			8'b0011_00: 
				if(col==4'b0111) row = 4'b0111;  //wrong3
				else row = 4'b1111;      
			8'b0011_01:                           
				if(col==4'b1101) row = 4'b0111;
				else row = 4'b1111;
			8'b0011_10:
				if(col==4'b0111) row = 4'b0111; //131
				else row = 4'b1111;

			default:
				row = 4'b1111; 
		endcase
	end

endmodule
		
		
		
		