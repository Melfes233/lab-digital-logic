module lock(
	input wire clk,
	input wire rst,//S1
	input wire setcode,//S2
	input wire validcode,//S3
	input wire confirmcode,//S5
	input wire [3:0]row,
	output reg [3:0]col,
	output reg [7:0] led_en,
	output reg led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp,
	output reg [2:0]wrongcode,
	output reg codesetted,//GLD0
	output reg rightcode
);
	parameter S0=3'd0;//初始状态
	parameter S1=3'd1;//设置密码状态
	parameter S2=3'd2;//密码设置完成待验证状态
	parameter S3=3'd3;//密码错误0次状态
	parameter S4=3'd4;//系统解锁
	parameter S5=3'd5;//密码错误1次状态
	parameter S6=3'd6;//密码错误2次状态	
	parameter S7=3'd7;//系统被锁
	
	parameter ORICODE = 4'd14;//默认初始密码为14，确保不会被输入 	
	parameter NONUM = 4'd10;//不显示数字
	parameter CNT_THRESHOLD=40;
	
	reg [3:0]input_num_0 = 4'd0;
	reg [3:0]input_num_1 = 4'd0;
	reg [3:0]input_num_2 = 4'd0;
	reg [3:0]input_num_left = 4'd0;
	reg [1:0]input_state=2'd0;
	reg [3:0]code_0;
	reg [3:0]code_1;
	reg [3:0]code_2;
	
	
	//以下为状态机模块
		
	reg [2:0]current_state = S0;
	reg [2:0]next_state = S0;
	
	always @(posedge clk or posedge rst)begin
		if(rst)
			current_state <= S0;
		else
			current_state <= next_state;
	end
	
	assign code_setting = (input_state >= 2'd3) & confirmcode;
	assign code_matching = (input_num_0 == code_0) & (input_num_1 == code_1) & (input_num_2 == code_2);
	reg [1:0]wrongcode;
	
	always @(*)begin
		if(rst)
			next_state = S0;
		else begin
			case(current_state)
				S0: if(setcode) next_state=S1;
					else		next_state=S0;
				S1: if(code_setting)	next_state=S2;
					else				next_state=S1;
				S2: if(validcode & wrongcode==3'd0)	     next_state=S3;
					else if(validcode & wrongcode==3'b001) next_state=S5;
					else if(validcode & wrongcode==3'b011) next_state=S6;
					else 			next_state=S2;
				S3: if(code_matching & confirmcode) 		next_state=S4;
					else if(confirmcode & ~code_matching) 	next_state=S2;
					else 								next_state=S3;
				S4: if(setcode) next_state=S1;
					else		next_state=S4; 
				S5: if(code_matching & confirmcode) 		next_state=S4;
					else if(confirmcode & ~code_matching)	next_state=S2;
					else 								next_state=S5;
				S6: if(code_matching & confirmcode) 		next_state=S4;
					else if(confirmcode & ~code_matching) 	next_state=S7;
					else 								next_state=S6;
				S7: next_state=S7;
				default: next_state=S0;
			endcase
		end
	end
	
	//输入使能
	reg input_en;
	always @(posedge clk or posedge rst)begin
		if(rst)
			input_en <= 1'b0;
		else begin
			case(current_state)
				S1,S3,S5,S6:input_en<=1'b1;
				default:input_en<=1'b0;
			endcase
		end
	end
	
	//以下为键盘模块和显示模块
	wire [3:0]keyboard_num;
	wire keyboard_en;
	wire [15:0] keyboard_led;//无需使用
	wire [3:0]col_wire;
	always @(*)begin
		col = col_wire;
	end
	//下两行测试用******
	keyboard u_keyboard(
    .clk(clk), 
    .reset(rst), 
    .row(row), 
    .col(col_wire), 
    .keyboard_en(keyboard_en), 
    .keyboard_led(keyboard_led),   //按键DCBA#9630852*741对应GLD0-GLD7:YLD0-YLD7
    .keyboard_num(keyboard_num)    // 因只亮一个周期，直接送到led显示将看不到灯亮
	);
	
	
	//允许数据读入
	reg keyboard_getnum;
	always @(*)begin
		if(rst)
			keyboard_getnum = 1'b0;
		else if(keyboard_num <= 4'd3 && keyboard_num >=4'd1)//输入只取1,2,3
			keyboard_getnum = input_en & keyboard_en;
		else
			keyboard_getnum = 1'b0;
	end	

	assign input_save_en = keyboard_getnum;
	
	parameter input0 = 2'd0;
	parameter input1 = 2'd1;
	parameter input2 = 2'd2;
	parameter input3 = 2'd3;
	
	//输入状态
	always @(posedge clk or posedge rst)begin
		if(rst)
			input_state <= input0;
		else begin
			case(current_state)
				S1,S3,S5,S6:	
					if(input_save_en & input_state==input3)
						input_state <= input3;
					else if(input_save_en)
						input_state <= input_state+2'd1;
				default: input_state <= input0;
			endcase
		end
	end
			
	//存储键盘输入
	always @(posedge clk or posedge rst)begin
		if(rst)begin//重置
			input_num_0 <= 4'd0;
			input_num_1 <= 4'd0;
			input_num_2 <= 4'd0;
			input_num_left <= 4'd0;
		end
		else begin
			case(current_state)
				S1,S3,S5,S6:	
						begin
							if(input_state==input0 & ~input_save_en)begin//没有任何输入时
								input_num_0 <= NONUM;
								input_num_1 <= NONUM;
								input_num_2 <= NONUM;
								input_num_left <= NONUM;
							end
							else if(input_save_en)begin
								input_num_0 <= keyboard_num;
								input_num_1 <= input_num_0;
								input_num_2 <= input_num_1;
								input_num_left <= input_num_left;
							end
						end
				S7:begin
					input_num_0 <= 4'hf;
					input_num_1 <= 4'hf;
					input_num_2 <= 4'hf;
					input_num_left <= 4'hf;
				end
				default:begin
							input_num_0 <= 4'd0;
							input_num_1 <= 4'd0;
							input_num_2 <= 4'd0;
							input_num_left <= 4'd0;
						end
			endcase
		end
	end
	
	//错误计数
	always @(posedge clk or posedge rst)begin	
		if(rst)
			wrongcode <= 3'd0;
		else begin
			case(current_state)
				S0,S4: wrongcode <= 3'd0;//初始为0，正确时也清零
				S3: if(next_state == S2) wrongcode <= 3'b001;
					else wrongcode <= 3'b000;
				S5: if(next_state == S2) wrongcode <= 3'b011;
					else wrongcode <= 3'b001;
				S6: wrongcode <= 3'b011;
				S7: wrongcode <= 3'b111;
				default: wrongcode <= wrongcode;
			endcase
		end
	end
		
	
	//led数字展示
	wire led_ca_wire,led_cb_wire,led_cc_wire,led_cd_wire,led_ce_wire,led_cf_wire,led_cg_wire,led_dp_wire;
	wire [7:0]led_en_wire;
	always @(*)begin
		{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} = {led_ca_wire,led_cb_wire,led_cc_wire,led_cd_wire,led_ce_wire,led_cf_wire,led_cg_wire,led_dp_wire};
		led_en = led_en_wire;
	end
	
	led_display_ctrl u_led_display_ctrl(
		.clk(clk),
		.rst(rst),
		.input_num_0(input_num_0),
		.input_num_1(input_num_1),
		.input_num_2(input_num_2),
		.input_num_left(input_num_left),
		.led_en(led_en_wire),
		.led_ca(led_ca_wire),
		.led_cb(led_cb_wire),
		.led_cc(led_cc_wire),
		.led_cd(led_cd_wire),
		.led_ce(led_ce_wire),
		.led_cf(led_cf_wire),
		.led_cg(led_cg_wire),
		.led_dp(led_dp_wire)
	);
		
	//密码存储
	always @(posedge clk or posedge rst)begin
		if(rst)begin//未设置时设为10
			code_0 <= ORICODE;
			code_1 <= ORICODE;
			code_2 <= ORICODE;
		end
		else begin
			case(current_state)
				S1:	begin//只有输入3位才能进入下一状态，所以可以直接读取
						code_0 <= input_num_0;
						code_1 <= input_num_1;
						code_2 <= input_num_2;
					end
				S4:	begin
						code_0 <= ORICODE;
						code_1 <= ORICODE;
						code_2 <= ORICODE;
					end
				default:begin
							code_0<=code_0;
							code_1<=code_1;
							code_2<=code_2;
						end
			endcase
		end
	end
	
	//led显示
	always @(posedge clk or posedge rst)begin
		if(rst)begin
			rightcode <= 1'b0;
			codesetted <= 1'b0;
		end
		else begin
			case(current_state)
				S2: begin
					codesetted<=1'b1;
					rightcode<=1'b0;
				end
				S4: begin
					rightcode<=1'b1;
					codesetted<=1'b1;
				end
				S5: begin
					rightcode<=1'b0;
					codesetted<=1'b1;
				end
				S6: begin
					rightcode<=1'b0;
					codesetted<=1'b1;
				end
				S7:begin
					rightcode<=1'b0;
					codesetted<=1'b1;
				end
				default:begin
							rightcode <= rightcode;
							codesetted <= codesetted;	
					    end
			endcase
		end
	end

	
	
endmodule	
		
			