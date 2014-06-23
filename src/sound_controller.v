module sound_controller(clk, on, pitch, out);

	input clk, on;
	input [3:0] pitch;
	output reg out;
	
	reg [31:0] counter;
	reg [31:0] maxCounter;
	
	initial begin
		counter = 32'd0;
		maxCounter = 32'd113636;
		out = 0;
	end
	
	always @ (pitch) begin
		case (pitch)
			4'b0000: maxCounter <= 32'd113636; // A   3
			4'b0001: maxCounter <= 32'd101215; // B
			4'b0010: maxCounter <= 32'd90253;  // C#
			4'b0011: maxCounter <= 32'd85034;  // D
			4'b0100: maxCounter <= 32'd75758;  // E
			4'b0101: maxCounter <= 32'd67568;  // F#
			4'b0110: maxCounter <= 32'd60241;  // G#
			4'b0111: maxCounter <= 32'd56818;  // A   4
			4'b1000: maxCounter <= 32'd50607;  // B
			4'b1001: maxCounter <= 32'd45126;  // C#
			4'b1010: maxCounter <= 32'd42589;  // D
			4'b1011: maxCounter <= 32'd37936;  // E
			4'b1100: maxCounter <= 32'd33784;  // F#
			4'b1101: maxCounter <= 32'd30084;  // G#
			4'b1110: maxCounter <= 32'd28409;  // A   5
			4'b1111: maxCounter <= 32'd28409;  // A   5
		endcase
	end
	
	always @ (posedge clk) begin
		if (counter >= maxCounter)
			begin
				if (on)
					out <= ~out;
				else
					out <= 0;
				counter <= 32'd0;
			end
		else
			counter <= counter + 32'd1;
	end
	
endmodule 