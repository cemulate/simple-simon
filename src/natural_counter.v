// This module is used to count things such as the number of rounds
// that have been won or the current position in the sequence
// If reset is high the counter will reset to 0
// If increment is high the counter will be incremented by 1
// NOTE: this module updates on the positive edge of the clock
module natural_counter (
	input clk,
	input increment,
	input reset,
	output reg [4:0] count
);

	initial begin
		count = 5'b00001;
	end
	
	always @(negedge clk) begin
		if (reset)
			count <= 5'b00001;
		else if (increment)
			count <= count + 5'b00001;
	end
endmodule
