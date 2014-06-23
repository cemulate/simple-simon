module round_win_anim(input clk, next, reset, output reg [3:0] sound, output light1, light2, light3, light4, done);
	
	reg [3:0] state, nState;
	
	initial begin
		state <= 4'b0000;
		sound <= 4'b0000;
	end
	
	always @ (negedge clk) begin
		
		state <= nState;
	
	end
	
	always @ (*) begin
		
		if (~reset) begin
			if (state == 4'b1111)
				nState = 4'b1111;
			else
				if (next)
					nState = state + 4'b0001;
				else
					nState = state;
		end
		else begin
			nState = 4'b0000;
		end
		
		if (state <= 4'b1000)
			sound = state;
		else
			sound = 4'b1000 - (state - 4'b1000);
		
	end
	
	assign light1 = state[0];
	assign light2 = ~state[0];
	assign light3 = state[0];
	assign light4 = ~state[0];
	
	assign done = (state == 4'b1111);

endmodule 