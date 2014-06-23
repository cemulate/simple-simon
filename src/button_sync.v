// This module is used for sycronizing the keys to the clock.
// The key input is active low, like the keys on the board.
// This module inverts the buttons so that the pressed output is active high
// button_down is high if any of the buttons are pressed
module button_sync (
	input clk,
	input [3:0] key,
	output button_down,
	output reg [3:0] pressed
);
	// used to avoid metastability
	reg [3:0] key1; 
	
	assign button_down = |pressed;
	
	always @(posedge clk) begin
		pressed <= key1;
		key1 <= key;
	end
endmodule
