module decoder_38 (
	input  wire en,
	input  wire [2:0] wsel,
	output reg  [7:0] en_r
);

always @ (*) begin
	if (en == 1'b1) begin
	    case (wsel)
		    3'h0 : en_r = 8'b00000001;
			3'h1 : en_r = 8'b00000010;
			3'h2 : en_r = 8'b00000100;
			3'h3 : en_r = 8'b00001000;
			3'h4 : en_r = 8'b00010000;
			3'h5 : en_r = 8'b00100000;
			3'h6 : en_r = 8'b01000000;
			3'h7 : en_r = 8'b10000000;
			default : en_r = 8'h0;
		endcase
	end
	else en_r = 8'h0;
end

endmodule