module led_display_ctrl(
	input wire clk,
	input wire rst,
	input wire [3:0]input_num_0,
	input wire [3:0]input_num_1,
	input wire [3:0]input_num_2,
	input wire [3:0]input_num_left,
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
	
	wire [7:0]led_num_0;
	wire [7:0]led_num_1;
	wire [7:0]led_num_2;
	wire [7:0]led_num_left;
	
	led u_led_0(.number(input_num_0),.seg_code(led_num_0));
	led u_led_1(.number(input_num_1),.seg_code(led_num_1));
	led u_led_2(.number(input_num_2),.seg_code(led_num_2));
	led u_led_left(.number(input_num_left),.seg_code(led_num_left));
	
	
	//2ms刷新计数
	reg cnt_refresh_inc = 1'b1;
	reg [17:0]cnt_refresh = 18'd0;
	//assign cnt_refresh_end = cnt_refresh_inc & (cnt_refresh == 18'd25000);
	assign cnt_refresh_end = cnt_refresh_inc & (cnt_refresh == 18'd1);
	
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
	
	
	//每隔0.25ms更新8个显像管，每2ms更新1个周期
	
	always @(posedge clk or posedge rst)begin
		if (rst)
			led_en <= ~8'd0;
		else if(cnt_refresh_end & led_en==~8'd0)
			led_en <= ~8'd1;
		else if(cnt_refresh_end)
			led_en <= {led_en[6:0],led_en[7]};
		else
			led_en <= led_en;
	end
		
	always @(posedge clk )begin
		case(~led_en)
			8'd1:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_num_0;
			8'd2:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_num_1;
			8'd4:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_num_2;
			8'd8:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_num_left;
			8'd16:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_num_left;
			8'd32:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_num_left;
			8'd64:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_num_left;
			8'd128:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= led_num_left;
			default:{led_ca,led_cb,led_cc,led_cd,led_ce,led_cf,led_cg,led_dp} <= 8'b00000011;
		endcase
	end
	
endmodule