module led_display_ctrl(
	input wire clk,
	input wire rst,
	input wire button,
	input wire counter,
	output reg  [7:0] led_en,
	output reg        led_ca,
	output reg        led_cb,
    output reg        led_cc,
	output reg        led_cd,
	output reg        led_ce,
	output reg        led_cf,
	output reg        led_cg,
	output reg        led_dp 
);
	
	//2ms刷新计数
	reg cnt_refresh_inc = 1'b0;
	reg [17:0]cnt_refresh = 18'd0;
	assign cnt_refresh_end = cnt_refresh_inc & (cnt_refresh == 18'd25000);
	//assign cnt_refresh_end = cnt_refresh_inc & (cnt_refresh == 18'd10);
	
	always @(posedge clk or posedge rst)begin
		if(rst)
			cnt_refresh_inc <= 1'b0;
		else if (button)
			cnt_refresh_inc <= 1'b1;
		else
			cnt_refresh_inc <= cnt_refresh_inc;
	end
	
	always @(posedge clk or posedge rst)begin
		if(rst)
			cnt_refresh <= 18'd0;
		else if(cnt_refresh_end)
			cnt_refresh <= 18'd0;
		else if(cnt_refresh_inc)
			cnt_refresh <= cnt_refresh + 18'd1;
		else
			cnt_refresh <= cnt_refresh;
	end
	
	//0-20计数
	wire [3:0]number_0,number_1;
	wire [7:0]led_counter_0,led_counter_1;
	counter20 u_counter20(.clk(clk),.rst(rst),.button(button),.number_0(number_0),.number_1(number_1));
	led u_led_counter_0(.number(number_0),.seg_code(led_counter_0));
	led u_led_counter_1(.number(number_1),.seg_code(led_counter_1));
	
	//学号班级
	reg [3:0]id_0 = 4'd3;
	reg [3:0]id_1 = 4'd0;
	reg [3:0]class_0 = 4'd2;
	reg [3:0]class_1 = 4'd0;
	wire [7:0]led_id_0,led_id_1,led_class_0,led_class_1;
	
	led u_led_id_0(.number(id_0),.seg_code(led_id_0));
	led u_led_id_1(.number(id_1),.seg_code(led_id_1));
	led u_led_class_0(.number(class_0),.seg_code(led_class_0));
	led u_led_class_1(.number(class_1),.seg_code(led_class_1));
	
	
	// 按键计数
	wire [3:0]button_number_0,button_number_1;
	wire [7:0]led_button_0,led_button_1;
	buttoncounter u_buttoncounter(.clk(clk),.rst(rst),.button(button),.counter(counter),.button_number_0(button_number_0),.button_number_1(button_number_1));
	led u_led_button_0(.number(button_number_0),.seg_code(led_button_0));
	led u_led_button_1(.number(button_number_1),.seg_code(led_button_1));
	
	
	//每隔0.25ms更新8个显像管，每2ms更新1个
	reg [7:0]my_led_en = ~8'd0;
	
	always @(*)begin
		led_en = my_led_en;
	end
	
	always @(posedge clk or posedge rst)begin
		if(rst)
			my_led_en <= ~8'd0;
		else if (button)
			my_led_en <= ~8'd1;
		else if (cnt_refresh_end)
			my_led_en <= {my_led_en[6:0],my_led_en[7]};
		else
			my_led_en <= my_led_en;
	end
		
	always @(posedge clk )begin
		case(~my_led_en)
			8'd1:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_id_0;
			8'd2:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_id_1;
			8'd4:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_class_0;
			8'd8:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_class_1;
			8'd16:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_button_0;
			8'd32:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_button_1;
			8'd64:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_counter_0;
			8'd128:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_counter_1;
			default:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= 8'd0;
		endcase
		//{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_button_1;
	end
	
endmodule