module reg8file(
	input wire clk,
	input wire clr,
	input wire en,
	input wire [7:0] d,
	input wire [2:0] wsel,
	input wire [2:0] rsel,
	output wire [7:0] q
);
	wire [7:0] r0,r1,r2,r3,r4,r5,r6,r7;
	wire [7:0] en_r;
	decoder_38 u_decoder38(en,wsel,en_r);
	dff u_dff_0(clk,clr,en_r[0],d,r0);
	dff u_dff_1(clk,clr,en_r[1],d,r1);
	dff u_dff_2(clk,clr,en_r[2],d,r2);
	dff u_dff_3(clk,clr,en_r[3],d,r3);
	dff u_dff_4(clk,clr,en_r[4],d,r4);
	dff u_dff_5(clk,clr,en_r[5],d,r5);
	dff u_dff_6(clk,clr,en_r[6],d,r6);
	dff u_dff_7(clk,clr,en_r[7],d,r7);
	multiplexer u_multiplexer(rsel,r0,r1,r2,r3,r4,r5,r6,r7,q);

endmodule
	
	
	