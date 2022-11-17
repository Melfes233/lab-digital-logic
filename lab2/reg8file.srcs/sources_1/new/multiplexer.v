
module multiplexer (
	input  wire [2:0] rsel,
	input  wire [7:0] r0,r1,r2,r3,r4,r5,r6,r7,
	output reg  [7:0] q
);
    always @(*)begin
        case (rsel)
			3'd0: q=r0;
			3'd1: q=r1;
			3'd2: q=r2;
			3'd3: q=r3;
			3'd4: q=r4;
			3'd5: q=r5;
			3'd6: q=r6;
			3'd7: q=r7;
			default: q=8'b0;
		endcase
    end

endmodule